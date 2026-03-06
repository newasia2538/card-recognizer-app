import 'package:card_recognizer/core/providers/core_provider.dart';

import 'package:card_recognizer/features/chat/data/repositories/chat_repository_imple.dart';
import 'package:card_recognizer/features/chat/data/datasources/ai_remote_datasource.dart';
import 'package:card_recognizer/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:card_recognizer/features/chat/data/repositories/ai_repository_impl.dart';
import 'package:card_recognizer/features/chat/presentation/controllers/chat_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

const String _geminiApiKey = String.fromEnvironment(
  'GEMINI_API_KEY',
  defaultValue: '',
);

final generativeModelProvider = Provider<GenerativeModel>((ref) {
  return GenerativeModel(model: 'gemini-2.5-flash', apiKey: _geminiApiKey);
});

final chatLocalDataSourceProvider = Provider<ChatLocalDataSource>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ChatLocalDataSource(prefs);
});

final aiRemoteDataSourceProvider = Provider<AiRemoteDataSource>((ref) {
  final generativeModel = ref.watch(generativeModelProvider);
  return AiRemoteDataSource(generativeModel);
});

final aiRepositoryProvider = Provider<AiRepositoryImpl>((ref) {
  final aiRemoteDataSource = ref.watch(aiRemoteDataSourceProvider);
  return AiRepositoryImpl(aiRemoteDataSource);
});

final chatRepositoryProvider = Provider<ChatRepositoryImpl>((ref) {
  final localDataSource = ref.watch(chatLocalDataSourceProvider);
  return ChatRepositoryImpl(localDataSource);
});

final chatNotifierProvider = StateNotifierProvider<ChatNotifier, ChatState>((
  ref,
) {
  final chatRepository = ref.watch(chatRepositoryProvider);
  final aiRepository = ref.watch(aiRepositoryProvider);
  return ChatNotifier(
    chatRepository: chatRepository,
    aiRepository: aiRepository,
  );
});
