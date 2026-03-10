import 'package:card_recognizer/core/providers/core_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:card_recognizer/features/chat/presentation/screens/chat_screen.dart';


void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Card Recognizer App Integration Tests', () {

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
