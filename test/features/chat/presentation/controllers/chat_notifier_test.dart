import 'dart:typed_data';
import 'package:card_recognizer/features/chat/domain/entities/chat_message.dart';

import 'package:card_recognizer/features/chat/domain/repositories/ai_repository.dart';
import 'package:card_recognizer/features/chat/domain/repositories/chat_repository.dart';

import 'package:card_recognizer/features/chat/presentation/controllers/chat_notifier.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Fakes ───────────────────────────────────────────────────────────────

class FakeAiRepository implements AiRepository {
  String identifyResult = '''{
      "card": {
  "name": "Pikachu VMAX",
  "set": "Vivid Voltage",
  "year": "2020",
  "rarity": "Secret Rare",
  "condition": "Mint",
  "lastSoldPrice": "\$125.50"
  }
}''';
  String priceResult =
      'Last sold: \$25.00 on eBay. Reference: pricecharting.com';
  String chatResult = 'I can help identify cards!';
  int identifyCallCount = 0;
  int priceCallCount = 0;
  int chatCallCount = 0;

  @override
  Future<String> identifyCard(Uint8List imageBytes) async {
    identifyCallCount++;
    return identifyResult;
  }

  @override
  Future<String> getLastSoldPrice(String cardName) async {
    priceCallCount++;
    return priceResult;
  }

  @override
  Future<String> chat(String message) async {
    chatCallCount++;
    return chatResult;
  }
}

class FakeChatRepository implements ChatRepository {
  List<ChatMessage> messages = [];
  int saveCallCount = 0;

  @override
  Future<List<ChatMessage>> loadChatHistory() async => List.from(messages);

  @override
  Future<void> saveChatMessage(ChatMessage message) async {
    saveCallCount++;
    messages.add(message);
  }

  @override
  Future<void> clearChatHistory() async => messages.clear();
}

// ── Tests ───────────────────────────────────────────────────────────────

void main() {
  late FakeAiRepository fakeAiRepo;
  late FakeChatRepository fakeChatRepo;
  late ChatNotifier notifier;

  setUp(() {
    fakeAiRepo = FakeAiRepository();
    fakeChatRepo = FakeChatRepository();

    notifier = ChatNotifier(
      chatRepository: fakeChatRepo,
      aiRepository: fakeAiRepo,
    );
  });

  group('ChatNotifier', () {
    test('initial state should have empty messages', () {
      expect(notifier.state.messages, isEmpty);
      expect(notifier.state.isLoading, false);
      expect(notifier.state.error, isNull);
    });

    test('loadHistory loads messages from repository', () async {
      fakeChatRepo.messages = [
        ChatMessage(
          id: '1',
          text: 'Old message',
          sender: MessageSender.user,
          timestamp: DateTime(2026, 1, 1),
        ),
      ];

      await notifier.loadHistory();

      expect(notifier.state.messages.length, 1);
      expect(notifier.state.messages.first.text, 'Old message');
    });

    test('sendTextMessage adds user and AI messages', () async {
      await notifier.sendTextMessage('Hello AI');

      // Should have 2 messages: user + AI response
      expect(notifier.state.messages.length, 2);
      expect(notifier.state.messages[0].sender, MessageSender.user);
      expect(notifier.state.messages[0].text, 'Hello AI');
      expect(notifier.state.messages[1].sender, MessageSender.ai);
      expect(notifier.state.messages[1].text, 'I can help identify cards!');
      expect(notifier.state.isLoading, false);
      expect(fakeAiRepo.chatCallCount, 1);
      // Both messages should be saved
      expect(fakeChatRepo.saveCallCount, 2);
    });

    test('sendTextMessage ignores empty text', () async {
      await notifier.sendTextMessage('');
      await notifier.sendTextMessage('   ');

      expect(notifier.state.messages, isEmpty);
      expect(fakeAiRepo.chatCallCount, 0);
    });

    test('sendImage adds user image message and AI card response', () async {
      final imageBytes = Uint8List.fromList([0xFF, 0xD8, 0xFF, 0xE0]);

      await notifier.sendImage(imageBytes, imagePath: '/tmp/card.jpg');

      expect(notifier.state.messages.length, 2);
      // User message
      expect(notifier.state.messages[0].sender, MessageSender.user);
      expect(notifier.state.messages[0].type, MessageType.image);
      expect(notifier.state.messages[0].imagePath, '/tmp/card.jpg');
      print(notifier.state.messages.toString());
      // AI response
      expect(notifier.state.messages[1].sender, MessageSender.ai);
      expect(notifier.state.messages[1].type, MessageType.card);
      expect(notifier.state.messages[1].showPriceButton, true);
      expect(notifier.state.messages[1].showBuyButton, true);
      expect(notifier.state.messages[1].cardName, isNotNull);
      expect(notifier.state.isLoading, false);
      expect(fakeAiRepo.identifyCallCount, 1);
    });

    test('askLastSoldPrice adds price query and response', () async {
      await notifier.askLastSoldPrice('Pikachu VMAX');

      expect(notifier.state.messages.length, 2);
      expect(notifier.state.messages[0].sender, MessageSender.user);
      expect(
        notifier.state.messages[0].text,
        contains('Ask the last sold price'),
      );
      expect(notifier.state.messages[1].sender, MessageSender.ai);
      expect(notifier.state.messages[1].text, contains('Last sold'));
      expect(notifier.state.messages[1].showBuyButton, true);
      expect(fakeAiRepo.priceCallCount, 1);
    });

    test('sendImage handles errors gracefully', () async {
      // Create a notifier with an AI repo that throws
      final errorAiRepo = _ThrowingAiRepository();
      final errorChatRepo = FakeChatRepository();
      final errorNotifier = ChatNotifier(
        chatRepository: errorChatRepo,
        aiRepository: errorAiRepo,
      );

      // Wait for loadHistory() to settle
      await Future.delayed(Duration.zero);

      await errorNotifier.sendImage(Uint8List.fromList([1, 2, 3]));

      // Should have user message + error message
      expect(errorNotifier.state.messages.length, 2);
      expect(errorNotifier.state.messages[1].text, contains('Error'));
      expect(errorNotifier.state.isLoading, false);
    });

    test('ChatState copyWith preserves unchanged fields', () {
      const state = ChatState(
        messages: [],
        isLoading: false,
        lastIdentifiedCard: 'Pikachu',
      );

      final updated = state.copyWith(isLoading: true);

      expect(updated.isLoading, true);
      expect(updated.lastIdentifiedCard, 'Pikachu');
      expect(updated.messages, isEmpty);
    });
  });
}

class _ThrowingAiRepository implements AiRepository {
  @override
  Future<String> identifyCard(Uint8List imageBytes) async {
    throw Exception('Network error');
  }

  @override
  Future<String> getLastSoldPrice(String cardName) async {
    throw Exception('Network error');
  }

  @override
  Future<String> chat(String message) async {
    throw Exception('Network error');
  }
}
