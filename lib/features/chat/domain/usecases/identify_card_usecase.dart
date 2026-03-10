import 'dart:typed_data';
import '../repositories/ai_repository.dart';

class IdentifyCardUseCase {
  final AiRepository _aiRepository;

  IdentifyCardUseCase(this._aiRepository);

  Future<String> call(Uint8List imageBytes) {
    return _aiRepository.identifyCard(imageBytes);
  }
}
