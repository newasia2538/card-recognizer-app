import 'dart:typed_data';

abstract class AiRepository {
  /// Sends an image to AI and asks "What is this card?"
  Future<String> identifyCard(Uint8List imageBytes);

  /// Asks AI for the last sold price of the identified card
  Future<String> getLastSoldPrice(String cardName);

  /// Sends a text message to AI and gets a response
  Future<String> chat(String message);
}
