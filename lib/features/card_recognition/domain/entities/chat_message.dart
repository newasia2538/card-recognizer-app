import 'package:equatable/equatable.dart';

enum MessageSender { user, ai }

enum MessageType { text, image, card }

class ChatMessage extends Equatable {
  final String id;
  final String text;
  final String content;
  final String? imagePath;
  final MessageSender sender;
  final MessageType type;
  final DateTime timestamp;
  final String? cardName;
  final bool showPriceButton;
  final bool showBuyButton;

  const ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    required this.timestamp,
    this.imagePath,
    this.type = MessageType.text,
    this.content = '',
    this.cardName,
    this.showPriceButton = false,
    this.showBuyButton = false,
  });

  bool get isUser => sender == MessageSender.user;
  bool get isAi => sender == MessageSender.ai;
  bool get isText => type == MessageType.text;
  bool get isImage => type == MessageType.image;
  bool get isCard => type == MessageType.card;

  ChatMessage copyWith({
    String? id,
    String? text,
    String? imagePath,
    MessageSender? sender,
    MessageType? type,
    DateTime? timestamp,
    String? cardName,
    bool? showPriceButton,
    bool? showBuyButton,
    String? content,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      imagePath: imagePath ?? this.imagePath,
      sender: sender ?? this.sender,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      cardName: cardName ?? this.cardName,
      showPriceButton: showPriceButton ?? this.showPriceButton,
      showBuyButton: showBuyButton ?? this.showBuyButton,
      content: content ?? this.content,
    );
  }

  @override
  List<Object?> get props => [
    id,
    text,
    imagePath,
    sender,
    type,
    timestamp,
    cardName,
    showPriceButton,
    showBuyButton,
    content,
  ];
}
