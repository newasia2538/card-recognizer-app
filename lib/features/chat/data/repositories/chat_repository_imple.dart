import 'package:card_recognizer/features/card_recognition/domain/entities/chat_message.dart';
import 'package:card_recognizer/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:card_recognizer/features/chat/data/models/chat_message_model.dart';
import 'package:card_recognizer/features/chat/domain/repositories/chat_repository.dart';

class ChatRepositoryImpl implements ChatRepository {
  final ChatLocalDataSource _localDataSource;

  ChatRepositoryImpl(this._localDataSource);

  @override
  Future<List<ChatMessage>> loadChatHistory() async {
    final models = await _localDataSource.loadChatHistory();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveChatMessage(ChatMessage message) {
    final model = ChatMessageModel.fromEntity(message);
    return _localDataSource.saveChatMessage(model);
  }

  @override
  Future<void> clearChatHistory() {
    return _localDataSource.clearChatHistory();
  }
}
