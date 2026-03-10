import 'dart:convert';
import 'package:card_recognizer/features/chat/domain/entities/chat_message.dart';

class ChatMessageModel {
  final String id;
  final String text;
  final String? imagePath;
  final String sender; // 'user' or 'ai'
  final String type; // 'text', 'image', 'card'
  final String timestamp;
  final String? cardName;
  final bool showPriceButton;
  final bool showBuyButton;

  const ChatMessageModel({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.imagePath,
    this.type = 'text',
    this.cardName,
    this.showPriceButton = false,
    this.showBuyButton = false,
  });

  factory ChatMessageModel.fromEntity(ChatMessage entity) {
    return ChatMessageModel(
      id: entity.id,
      text: entity.text,
      imagePath: entity.imagePath,
      sender: entity.sender == MessageSender.user ? 'user' : 'ai',
      type:
          entity.type == MessageType.text
              ? 'text'
              : entity.type == MessageType.image
              ? 'image'
              : 'card',
      timestamp: entity.timestamp.toIso8601String(),
      cardName: entity.cardName,
      showPriceButton: entity.showPriceButton,
      showBuyButton: entity.showBuyButton,
    );
  }

  ChatMessage toEntity() {
    return ChatMessage(
      id: id,
      text: text,
      imagePath: imagePath,
      sender: sender == 'user' ? MessageSender.user : MessageSender.ai,
      type:
          type == 'text'
              ? MessageType.text
              : type == 'image'
              ? MessageType.image
              : MessageType.card,
      timestamp: DateTime.parse(timestamp),
      cardName: cardName,
      showPriceButton: showPriceButton,
      showBuyButton: showBuyButton,
    );
  }

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      text: json['text'] as String,
      imagePath: json['imagePath'] as String?,
      sender: json['sender'] as String,
      type: json['type'] as String? ?? 'text',
      timestamp: json['timestamp'] as String,
      cardName: json['cardName'] as String?,
      showPriceButton: json['showPriceButton'] as bool? ?? false,
      showBuyButton: json['showBuyButton'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'imagePath': imagePath,
      'sender': sender,
      'type': type,
      'timestamp': timestamp,
      'cardName': cardName,
      'showPriceButton': showPriceButton,
      'showBuyButton': showBuyButton,
    };
  }

  static String encodeList(List<ChatMessageModel> models) {
    return jsonEncode(models.map((m) => m.toJson()).toList());
  }

  static List<ChatMessageModel> decodeList(String jsonString) {
    final List<dynamic> list = jsonDecode(jsonString) as List<dynamic>;
    return list
        .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
