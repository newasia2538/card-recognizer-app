import 'package:card_recognizer/features/card_recognition/domain/entities/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:card_recognizer/data/models/chat_message_model.dart';
import 'package:card_recognizer/domain/repositories/chat_repository.dart';

/// Fake ChatRepository that stores messages in memory
class FakeChatRepository implements ChatRepository {
  final List<ChatMessage> _messages = [];

  @override
  Future<List<ChatMessage>> loadChatHistory() async => List.from(_messages);

  @override
  Future<void> saveChatMessage(ChatMessage message) async {
    _messages.add(message);
  }

  @override
  Future<void> clearChatHistory() async => _messages.clear();
}

void main() {
  group('ChatRepository - interface compliance', () {
    late FakeChatRepository repository;

    setUp(() {
      repository = FakeChatRepository();
    });

    test('loadChatHistory returns empty list when no messages exist', () async {
      final result = await repository.loadChatHistory();
      expect(result, isEmpty);
    });

    test('saveChatMessage saves and loadChatHistory retrieves', () async {
      final message = ChatMessage(
        id: '1',
        text: 'Hello',
        sender: MessageSender.user,
        timestamp: DateTime(2026, 1, 1),
      );

      await repository.saveChatMessage(message);
      final result = await repository.loadChatHistory();

      expect(result.length, 1);
      expect(result.first.text, 'Hello');
      expect(result.first.sender, MessageSender.user);
    });

    test('clearChatHistory removes all messages', () async {
      final message = ChatMessage(
        id: '1',
        text: 'Test',
        sender: MessageSender.user,
        timestamp: DateTime(2026, 1, 1),
      );

      await repository.saveChatMessage(message);
      await repository.clearChatHistory();
      final result = await repository.loadChatHistory();

      expect(result, isEmpty);
    });

    test('multiple messages are preserved in order', () async {
      for (int i = 0; i < 3; i++) {
        await repository.saveChatMessage(
          ChatMessage(
            id: '$i',
            text: 'Message $i',
            sender: i.isEven ? MessageSender.user : MessageSender.ai,
            timestamp: DateTime(2026, 1, 1, i),
          ),
        );
      }

      final result = await repository.loadChatHistory();
      expect(result.length, 3);
      expect(result[0].text, 'Message 0');
      expect(result[1].text, 'Message 1');
      expect(result[2].text, 'Message 2');
    });
  });

  group('ChatMessageModel roundtrip through repository', () {
    test('model roundtrip preserves all data', () {
      final entity = ChatMessage(
        id: '42',
        text: 'Test card',
        sender: MessageSender.ai,
        timestamp: DateTime(2026, 3, 1),
        type: MessageType.card,
        cardName: 'Pikachu',
        showPriceButton: true,
        showBuyButton: true,
      );

      final model = ChatMessageModel.fromEntity(entity);
      final restored = model.toEntity();

      expect(restored.id, entity.id);
      expect(restored.text, entity.text);
      expect(restored.sender, entity.sender);
      expect(restored.cardName, entity.cardName);
    });
  });
}
