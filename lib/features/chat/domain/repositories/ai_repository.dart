import 'dart:typed_data';

abstract class AiRepository {
  Future<String> identifyCard(Uint8List imageBytes);
  Future<String> getLastSoldPrice(String cardName);
  Future<String> chat(String message);
}
