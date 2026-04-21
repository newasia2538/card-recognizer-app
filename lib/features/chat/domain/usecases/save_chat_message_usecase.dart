import 'package:card_recognizer/features/chat/domain/entities/chat_message.dart';
import 'package:card_recognizer/features/chat/domain/repositories/chat_repository.dart';

class SaveChatMessageUseCase {
  final ChatRepository _chatRepository;

  SaveChatMessageUseCase(this._chatRepository);

  Future<void> call(ChatMessage message) {
    return _chatRepository.saveChatMessage(message);
  }
}
