import 'dart:typed_data';
import 'package:card_recognizer/features/chat/domain/entities/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:card_recognizer/features/chat/domain/usecases/identify_card_usecase.dart';
import 'package:card_recognizer/features/chat/domain/usecases/get_last_sold_price_usecase.dart';
import 'package:card_recognizer/features/chat/domain/usecases/get_chat_history_usecase.dart';
import 'package:card_recognizer/features/chat/domain/usecases/save_chat_message_usecase.dart';
import 'package:card_recognizer/features/chat/domain/usecases/chat_with_ai_usecase.dart';
import 'package:card_recognizer/features/chat/domain/repositories/ai_repository.dart';
import 'package:card_recognizer/features/chat/domain/repositories/chat_repository.dart';

// ── Fake implementations ────────────────────────────────────────────────

class FakeAiRepository implements AiRepository {
  String identifyCardResult = 'Pikachu VMAX - Pokemon TCG';
  String lastSoldPriceResult = 'Last sold for \$25.00 on eBay';
  String chatResult = 'Hello! I can help with cards.';

  @override
  Future<String> identifyCard(Uint8List imageBytes) async {
    return identifyCardResult;
  }

  @override
  Future<String> getLastSoldPrice(String cardName) async {
    return lastSoldPriceResult;
  }

  @override
  Future<String> chat(String message) async {
    return chatResult;
  }
}

class FakeChatRepository implements ChatRepository {
  List<ChatMessage> storedMessages = [];

  @override
  Future<List<ChatMessage>> loadChatHistory() async {
    return List.from(storedMessages);
  }

  @override
  Future<void> saveChatMessage(ChatMessage message) async {
    storedMessages.add(message);
  }

  @override
  Future<void> clearChatHistory() async {
    storedMessages.clear();
  }
}

// ── Tests ───────────────────────────────────────────────────────────────

void main() {
  group('IdentifyCardUseCase', () {
    late FakeAiRepository fakeRepo;
    late IdentifyCardUseCase useCase;

    setUp(() {
      fakeRepo = FakeAiRepository();
      useCase = IdentifyCardUseCase(fakeRepo);
    });

    test('should return card identification from AI repository', () async {
      final result = await useCase(Uint8List.fromList([1, 2, 3]));
      expect(result, 'Pikachu VMAX - Pokemon TCG');
    });

    test('should return custom AI response', () async {
      fakeRepo.identifyCardResult = 'Charizard Base Set 1st Edition';
      final result = await useCase(Uint8List.fromList([4, 5, 6]));
      expect(result, 'Charizard Base Set 1st Edition');
    });
  });

  group('GetLastSoldPriceUseCase', () {
    late FakeAiRepository fakeRepo;
    late GetLastSoldPriceUseCase useCase;

    setUp(() {
      fakeRepo = FakeAiRepository();
      useCase = GetLastSoldPriceUseCase(fakeRepo);
    });

    test('should return price info from AI repository', () async {
      final result = await useCase('Pikachu VMAX');
      expect(result, 'Last sold for \$25.00 on eBay');
    });
  });

  group('ChatWithAiUseCase', () {
    late FakeAiRepository fakeRepo;
    late ChatWithAiUseCase useCase;

    setUp(() {
      fakeRepo = FakeAiRepository();
      useCase = ChatWithAiUseCase(fakeRepo);
    });

    test('should return chat response from AI repository', () async {
      final result = await useCase('Hello');
      expect(result, 'Hello! I can help with cards.');
    });
  });

  group('GetChatHistoryUseCase', () {
    late FakeChatRepository fakeRepo;
    late GetChatHistoryUseCase useCase;

    setUp(() {
      fakeRepo = FakeChatRepository();
      useCase = GetChatHistoryUseCase(fakeRepo);
    });

    test('should return empty list when no history exists', () async {
      final result = await useCase();
      expect(result, isEmpty);
    });

    test('should return stored messages', () async {
      fakeRepo.storedMessages = [
        ChatMessage(
          id: '1',
          text: 'Hello',
          sender: MessageSender.user,
          timestamp: DateTime(2026, 1, 1),
        ),
      ];

      final result = await useCase();
      expect(result.length, 1);
      expect(result.first.text, 'Hello');
    });
  });

  group('SaveChatMessageUseCase', () {
    late FakeChatRepository fakeRepo;
    late SaveChatMessageUseCase useCase;

    setUp(() {
      fakeRepo = FakeChatRepository();
      useCase = SaveChatMessageUseCase(fakeRepo);
    });

    test('should save message to repository', () async {
      final message = ChatMessage(
        id: '1',
        text: 'Test message',
        sender: MessageSender.user,
        timestamp: DateTime(2026, 1, 1),
      );

      await useCase(message);

      expect(fakeRepo.storedMessages.length, 1);
      expect(fakeRepo.storedMessages.first.text, 'Test message');
    });
  });
}
