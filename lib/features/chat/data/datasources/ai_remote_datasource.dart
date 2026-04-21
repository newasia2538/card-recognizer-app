import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';


class AiRemoteDataSource {
  final GenerativeModel _model;

  AiRemoteDataSource(this._model);

  Future<String> identifyCard(Uint8List imageBytes) async {
    final prompt = TextPart(
      'What is this card? Please identify the card name, set and year, in short '
      'including the card condition if visible.',
    );

    final imagePart = DataPart('image/jpeg', imageBytes);

    final response = await _model.generateContent([
      Content.multi([prompt, imagePart]),
    ]);

    return response.text ?? 'Unable to identify the card. Please try again.';
  }

  Future<String> getLastSoldPrice(String cardName) async {
    final prompt = TextPart(
      'What is the last sold price of the card "$cardName"? '
      'Please provide pricing information including:\n'
      '- Recent sold prices\n'
      '- Price ranges for different conditions (Near Mint, Lightly Played, etc.)\n'
      '- Reference sources such as Pricecharting.com, TCGPlayer.com, '
      'eBay sold listings, or other reliable sources.',
    );

    final response = await _model.generateContent([
      Content('user', [prompt]),
    ]);

    return response.text ??
        'Unable to find pricing information. Please try again.';
  }

  Future<String> chat(String message) async {
    final response = await _model.generateContent([Content.text(message)]);

    return response.text ?? 'No response from AI. Please try again.';
  }
}
