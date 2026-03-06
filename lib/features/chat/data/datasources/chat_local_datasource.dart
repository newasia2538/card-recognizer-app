import 'package:card_recognizer/features/chat/data/models/chat_message_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatLocalDataSource {
  static const String _chatHistoryKey = 'chat_history';
  final SharedPreferences _prefs;

  ChatLocalDataSource(this._prefs);

  Future<List<ChatMessageModel>> loadChatHistory() async {
    final jsonString = _prefs.getString(_chatHistoryKey);
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }
    return ChatMessageModel.decodeList(jsonString);
  }

  Future<void> saveChatMessage(ChatMessageModel message) async {
    final messages = await loadChatHistory();
    messages.add(message);
    await _prefs.setString(
      _chatHistoryKey,
      ChatMessageModel.encodeList(messages),
    );
  }

  Future<void> clearChatHistory() async {
    await _prefs.remove(_chatHistoryKey);
  }
}
