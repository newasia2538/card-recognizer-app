import 'package:card_recognizer/features/card_recognition/domain/entities/chat_message.dart';

abstract class ChatRepository {
  Future<List<ChatMessage>> loadChatHistory();

  Future<void> saveChatMessage(ChatMessage message);

  Future<void> clearChatHistory();
}
