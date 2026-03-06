import 'package:card_recognizer/features/card_recognition/domain/entities/chat_message.dart';
import 'package:card_recognizer/features/chat/domain/repositories/chat_repository.dart';

class GetChatHistoryUseCase {
  final ChatRepository _chatRepository;

  GetChatHistoryUseCase(this._chatRepository);

  Future<List<ChatMessage>> call() {
    return _chatRepository.loadChatHistory();
  }
}
