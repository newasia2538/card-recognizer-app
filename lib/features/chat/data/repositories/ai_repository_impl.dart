import 'dart:typed_data';

import 'package:card_recognizer/features/chat/data/datasources/ai_remote_datasource.dart';
import 'package:card_recognizer/features/chat/domain/repositories/ai_repository.dart';

class AiRepositoryImpl extends AiRepository {
  final AiRemoteDataSource _remoteDataSource;

  AiRepositoryImpl(this._remoteDataSource);

  @override
  Future<String> getLastSoldPrice(String cardName) {
    return _remoteDataSource.getLastSoldPrice(cardName);
  }

  @override
  Future<String> identifyCard(Uint8List imageBytes) {
    return _remoteDataSource.identifyCard(imageBytes);
  }

  @override
  Future<String> chat(String message) {
    return _remoteDataSource.chat(message);
  }
}
