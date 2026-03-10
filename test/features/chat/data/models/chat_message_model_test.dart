import 'package:card_recognizer/features/chat/domain/entities/chat_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:card_recognizer/features/chat/data/models/chat_message_model.dart';

void main() {
  group('ChatMessageModel', () {
    test('fromJson should parse valid JSON correctly', () {
      final json = {
        'id': '1',
        'text': 'Hello',
        'sender': 'user',
        'type': 'text',
        'timestamp': '2026-01-01T00:00:00.000',
        'imagePath': null,
        'cardName': null,
        'showPriceButton': false,
        'showBuyButton': false,
      };

      final model = ChatMessageModel.fromJson(json);

      expect(model.id, '1');
      expect(model.text, 'Hello');
      expect(model.sender, 'user');
      expect(model.type, 'text');
    });

    test('toJson should produce valid JSON', () {
      const model = ChatMessageModel(
        id: '1',
        text: 'Hello',
        sender: 'user',
        type: 'text',
        timestamp: '2026-01-01T00:00:00.000',
      );

      final json = model.toJson();

      expect(json['id'], '1');
      expect(json['text'], 'Hello');
      expect(json['sender'], 'user');
      expect(json['type'], 'text');
    });

    test('fromEntity should map domain entity to model', () {
      final entity = ChatMessage(
        id: '1',
        text: 'Card found',
        sender: MessageSender.ai,
        timestamp: DateTime(2026, 1, 1),
        type: MessageType.card,
        cardName: 'Pikachu',
        showPriceButton: true,
        showBuyButton: true,
      );

      final model = ChatMessageModel.fromEntity(entity);

      expect(model.id, '1');
      expect(model.text, 'Card found');
      expect(model.sender, 'ai');
      expect(model.type, 'card');
      expect(model.cardName, 'Pikachu');
      expect(model.showPriceButton, true);
      expect(model.showBuyButton, true);
    });

    test('toEntity should map model to domain entity', () {
      const model = ChatMessageModel(
        id: '1',
        text: 'Card found',
        sender: 'ai',
        type: 'card',
        timestamp: '2026-01-01T00:00:00.000',
        cardName: 'Pikachu',
        showPriceButton: true,
        showBuyButton: true,
      );

      final entity = model.toEntity();

      expect(entity.id, '1');
      expect(entity.text, 'Card found');
      expect(entity.sender, MessageSender.ai);
      expect(entity.type, MessageType.card);
      expect(entity.cardName, 'Pikachu');
      expect(entity.showPriceButton, true);
      expect(entity.showBuyButton, true);
    });

    test('roundtrip entity -> model -> entity preserves data', () {
      final original = ChatMessage(
        id: '42',
        text: 'Charizard Holo',
        sender: MessageSender.ai,
        timestamp: DateTime(2026, 3, 1, 12, 30),
        type: MessageType.card,
        cardName: 'Charizard Holo 1st Edition',
        showPriceButton: true,
        showBuyButton: true,
        imagePath: '/tmp/img.jpg',
      );

      final model = ChatMessageModel.fromEntity(original);
      final restored = model.toEntity();

      expect(restored.id, original.id);
      expect(restored.text, original.text);
      expect(restored.sender, original.sender);
      expect(restored.type, original.type);
      expect(restored.cardName, original.cardName);
      expect(restored.showPriceButton, original.showPriceButton);
      expect(restored.showBuyButton, original.showBuyButton);
      expect(restored.imagePath, original.imagePath);
    });

    test('encodeList and decodeList should roundtrip correctly', () {
      const models = [
        ChatMessageModel(
          id: '1',
          text: 'Hello',
          sender: 'user',
          timestamp: '2026-01-01T00:00:00.000',
        ),
        ChatMessageModel(
          id: '2',
          text: 'Hi there',
          sender: 'ai',
          timestamp: '2026-01-01T00:00:01.000',
          cardName: 'Test Card',
          showPriceButton: true,
          showBuyButton: true,
        ),
      ];

      final encoded = ChatMessageModel.encodeList(models);
      final decoded = ChatMessageModel.decodeList(encoded);

      expect(decoded.length, 2);
      expect(decoded[0].id, '1');
      expect(decoded[0].text, 'Hello');
      expect(decoded[1].id, '2');
      expect(decoded[1].cardName, 'Test Card');
      expect(decoded[1].showPriceButton, true);
    });

    test('fromJson handles missing optional fields with defaults', () {
      final json = {
        'id': '1',
        'text': 'Hello',
        'sender': 'user',
        'timestamp': '2026-01-01T00:00:00.000',
      };

      final model = ChatMessageModel.fromJson(json);

      expect(model.type, 'text');
      expect(model.imagePath, isNull);
      expect(model.cardName, isNull);
      expect(model.showPriceButton, false);
      expect(model.showBuyButton, false);
    });
  });
}
