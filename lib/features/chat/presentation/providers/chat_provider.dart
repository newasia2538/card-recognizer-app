import 'package:card_recognizer/core/providers/core_provider.dart';
import 'package:card_recognizer/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:card_recognizer/features/chat/data/datasources/ai_remote_datasource.dart';
import 'package:card_recognizer/features/chat/data/datasources/chat_local_datasource.dart';
import 'package:card_recognizer/features/chat/data/repositories/ai_repository_impl.dart';
import 'package:card_recognizer/features/chat/presentation/controllers/chat_notifier.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

final schema = Schema.object(
  properties: {
    'card': Schema.object(
      properties: {
        'name': Schema(SchemaType.string),
        'set': Schema(SchemaType.string),
        'year': Schema(SchemaType.string),
        'rarity' : Schema(SchemaType.string),
        'condition': Schema(SchemaType.string),
        'lastSoldPrice' : Schema(SchemaType.string),
      },
      requiredProperties: ['name', 'set', 'year', 'rarity'],
    ),
  },
);

final generativeModelProvider = Provider<GenerativeModel>((ref) {
  final apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
  if (apiKey.isEmpty) {
    throw StateError(
      'GEMINI_API_KEY is not set. '
      'Please create a .env file with GEMINI_API_KEY=your_key_here',
    );
  }
  return GenerativeModel(
    model: 'gemini-2.5-flash',
    generationConfig: GenerationConfig(
      responseMimeType: 'application/json',
      responseSchema: schema,
    ),
    apiKey: apiKey,
  );
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
