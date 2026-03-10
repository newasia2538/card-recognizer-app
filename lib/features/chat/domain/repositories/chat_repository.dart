import 'package:card_recognizer/features/chat/domain/entities/chat_message.dart';

abstract class ChatRepository {
  /// Loads chat history from local storage
  Future<List<ChatMessage>> loadChatHistory();

  /// Saves a single message to chat history
  Future<void> saveChatMessage(ChatMessage message);

  /// Clears all chat history
  Future<void> clearChatHistory();
}
