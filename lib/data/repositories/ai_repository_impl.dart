import 'dart:typed_data';
import '../../domain/repositories/ai_repository.dart';
import '../datasources/ai_remote_datasource.dart';

class AiRepositoryImpl implements AiRepository {
  final AiRemoteDataSource _remoteDataSource;

  AiRepositoryImpl(this._remoteDataSource);

  @override
  Future<String> identifyCard(Uint8List imageBytes) {
    return _remoteDataSource.identifyCard(imageBytes);
  }

  @override
  Future<String> getLastSoldPrice(String cardName) {
    return _remoteDataSource.getLastSoldPrice(cardName);
  }

  @override
  Future<String> chat(String message) {
    return _remoteDataSource.chat(message);
  }
}
