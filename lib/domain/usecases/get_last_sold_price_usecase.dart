import '../repositories/ai_repository.dart';

class GetLastSoldPriceUseCase {
  final AiRepository _aiRepository;

  GetLastSoldPriceUseCase(this._aiRepository);

  Future<String> call(String cardName) {
    return _aiRepository.getLastSoldPrice(cardName);
  }
}
