import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:card_recognizer/features/chat/domain/repositories/ai_repository.dart';

class FakeAiRepositoryImpl implements AiRepository {
  String identifyResult = 'Pokemon Card - Pikachu';
  String priceResult = 'Price: \$25';
  String chatResult = 'AI says hi';

  @override
  Future<String> identifyCard(Uint8List imageBytes) async => identifyResult;

  @override
  Future<String> getLastSoldPrice(String cardName) async => priceResult;

  @override
  Future<String> chat(String message) async => chatResult;
}

void main() {
  group('AiRepositoryImpl - interface compliance', () {
    late FakeAiRepositoryImpl repository;

    setUp(() {
      repository = FakeAiRepositoryImpl();
    });

    test('identifyCard returns expected result', () async {
      final result = await repository.identifyCard(Uint8List.fromList([1]));
      expect(result, 'Pokemon Card - Pikachu');
    });

    test('getLastSoldPrice returns expected result', () async {
      final result = await repository.getLastSoldPrice('Pikachu');
      expect(result, 'Price: \$25');
    });

    test('chat returns expected result', () async {
      final result = await repository.chat('Hello');
      expect(result, 'AI says hi');
    });

    test('identifyCard uses custom result', () async {
      repository.identifyResult = 'Charizard Base Set';
      final result = await repository.identifyCard(Uint8List.fromList([1, 2]));
      expect(result, 'Charizard Base Set');
    });
  });
}
