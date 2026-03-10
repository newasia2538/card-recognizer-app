import 'package:card_recognizer/features/chat/domain/entities/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatMessage Entity', () {
    test('should create ChatMessage with required fields', () {
      final message = ChatMessage(
        id: '1',
        text: 'Hello',
        sender: MessageSender.user,
        timestamp: DateTime(2026, 1, 1),
      );

      expect(message.id, '1');
      expect(message.text, 'Hello');
      expect(message.sender, MessageSender.user);
      expect(message.timestamp, DateTime(2026, 1, 1));
      expect(message.imagePath, isNull);
      expect(message.type, MessageType.text);
      expect(message.cardName, isNull);
      expect(message.showPriceButton, false);
      expect(message.showBuyButton, false);
    });

    test('should create ChatMessage with all fields', () {
      final message = ChatMessage(
        id: '2',
        text: 'Card found',
        sender: MessageSender.ai,
        timestamp: DateTime(2026, 1, 1),
        imagePath: '/path/to/image.jpg',
        type: MessageType.card,
        cardName: 'Pikachu VMAX',
        showPriceButton: true,
        showBuyButton: true,
      );

      expect(message.imagePath, '/path/to/image.jpg');
      expect(message.type, MessageType.card);
      expect(message.cardName, 'Pikachu VMAX');
      expect(message.showPriceButton, true);
      expect(message.showBuyButton, true);
    });

    test('copyWith should create new instance with updated fields', () {
      final original = ChatMessage(
        id: '1',
        text: 'Hello',
        sender: MessageSender.user,
        timestamp: DateTime(2026, 1, 1),
      );

      final updated = original.copyWith(text: 'Updated', showPriceButton: true);

      expect(updated.id, '1');
      expect(updated.text, 'Updated');
      expect(updated.sender, MessageSender.user);
      expect(updated.showPriceButton, true);
    });

    test('should support value equality via Equatable', () {
      final msg1 = ChatMessage(
        id: '1',
        text: 'Hello',
        sender: MessageSender.user,
        timestamp: DateTime(2026, 1, 1),
      );

      final msg2 = ChatMessage(
        id: '1',
        text: 'Hello',
        sender: MessageSender.user,
        timestamp: DateTime(2026, 1, 1),
      );

      expect(msg1, equals(msg2));
    });

    test('different messages should not be equal', () {
      final msg1 = ChatMessage(
        id: '1',
        text: 'Hello',
        sender: MessageSender.user,
        timestamp: DateTime(2026, 1, 1),
      );

      final msg2 = ChatMessage(
        id: '2',
        text: 'World',
        sender: MessageSender.ai,
        timestamp: DateTime(2026, 1, 2),
      );

      expect(msg1, isNot(equals(msg2)));
    });
  });
}
