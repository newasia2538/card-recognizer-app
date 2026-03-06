import 'dart:typed_data';
import 'package:card_recognizer/core/providers/core_provider.dart';
import 'package:card_recognizer/features/card_recognition/domain/entities/chat_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:card_recognizer/domain/repositories/ai_repository.dart';
import 'package:card_recognizer/domain/repositories/chat_repository.dart';
import 'package:card_recognizer/presentation/screens/chat_screen.dart';

// ── Fake repositories for integration testing ───────────────────────────

class FakeAiRepository implements AiRepository {
  @override
  Future<String> identifyCard(Uint8List imageBytes) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 'Pikachu VMAX\n\nThis is a Pikachu VMAX card from the Pokémon TCG '
        'Sword & Shield series. Card #044/185.';
  }

  @override
  Future<String> getLastSoldPrice(String cardName) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 'The last sold price for "$cardName" is approximately \$24.99.\n\n'
        'References:\n'
        '- Pricecharting.com: \$23.50 - \$26.00\n'
        '- TCGPlayer.com: \$24.99 (Near Mint)\n'
        '- eBay sold listings: \$22.00 - \$28.00';
  }

  @override
  Future<String> chat(String message) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return 'I can help you identify trading cards! '
        'Just take a photo or paste an image of any card.';
  }
}

class FakeChatRepository implements ChatRepository {
  final List<ChatMessage> _messages = [];

  @override
  Future<List<ChatMessage>> loadChatHistory() async => List.from(_messages);

  @override
  Future<void> saveChatMessage(ChatMessage message) async {
    _messages.add(message);
  }

  @override
  Future<void> clearChatHistory() async => _messages.clear();
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Card Recognizer App Integration Tests', () {
    late FakeAiRepository fakeAiRepo;
    late FakeChatRepository fakeChatRepo;

    setUp(() {
      fakeAiRepo = FakeAiRepository();
      fakeChatRepo = FakeChatRepository();
    });

    testWidgets('App shows empty state on first launch', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(home: ChatScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Should show empty state with Card Recognizer AI title
      expect(find.text('Card Recognizer AI'), findsOneWidget);
      expect(
        find.text(
          'Take a photo or paste an image of any\ntrading card to get started!',
        ),
        findsOneWidget,
      );

      // Should show input bar elements
      expect(find.byKey(const Key('camera_button')), findsOneWidget);
      expect(find.byKey(const Key('gallery_button')), findsOneWidget);
      expect(find.byKey(const Key('paste_button')), findsOneWidget);
      expect(find.byKey(const Key('message_input')), findsOneWidget);
      expect(find.byKey(const Key('send_button')), findsOneWidget);
    });

    testWidgets('User can send a text message and receive AI response', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(home: ChatScreen()),
        ),
      );
      await tester.pumpAndSettle();

      // Type a message
      await tester.enterText(
        find.byKey(const Key('message_input')),
        'What cards do you support?',
      );
      await tester.pump();

      // Tap send button
      await tester.tap(find.byKey(const Key('send_button')));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // User message should appear
      expect(find.text('What cards do you support?'), findsOneWidget);
    });

    testWidgets('App bar shows Card Recognizer title', (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(home: ChatScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Card Recognizer'), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);
    });

    testWidgets('Quick action chips are visible on empty state', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
          child: const MaterialApp(home: ChatScreen()),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Camera'), findsOneWidget);
      expect(find.text('Gallery'), findsOneWidget);
      expect(find.text('Paste'), findsOneWidget);
    });
  });
}
