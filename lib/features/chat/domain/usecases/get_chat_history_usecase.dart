import 'package:card_recognizer/features/chat/domain/entities/chat_message.dart';
import 'package:card_recognizer/features/chat/domain/repositories/chat_repository.dart';

class GetChatHistoryUseCase {
  final ChatRepository _chatRepository;

  GetChatHistoryUseCase(this._chatRepository);

  Future<List<ChatMessage>> call() {
    return _chatRepository.loadChatHistory();
  }
}
