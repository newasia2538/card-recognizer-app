import 'package:card_recognizer/features/chat/domain/repositories/ai_repository.dart';

class ChatWithAiUseCase {
  final AiRepository _aiRepository;

  ChatWithAiUseCase(this._aiRepository);

  Future<String> call(String message) {
    return _aiRepository.chat(message);
  }
}
