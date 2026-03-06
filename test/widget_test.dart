import 'package:card_recognizer/features/card_recognition/domain/entities/chat_message.dart';
import 'package:card_recognizer/presentation/widgets/message_bubble.dart';
import 'package:card_recognizer/presentation/widgets/message_input.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MessageBubble Widget', () {
    testWidgets('renders user message correctly', (tester) async {
      final message = ChatMessage(
        id: '1',
        text: 'Hello AI',
        sender: MessageSender.user,
        timestamp: DateTime(2026, 1, 1, 12, 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(body: MessageBubble(message: message)),
        ),
      );

      expect(find.text('Hello AI'), findsOneWidget);
      expect(find.text('You'), findsOneWidget);
      expect(find.text('12:00'), findsOneWidget);
    });

    testWidgets('renders AI message with card info', (tester) async {
      final message = ChatMessage(
        id: '2',
        text: 'This is a Pikachu VMAX card',
        sender: MessageSender.ai,
        timestamp: DateTime(2026, 1, 1, 12, 30),
        type: MessageType.card,
        cardName: 'Pikachu VMAX',
        showPriceButton: true,
        showBuyButton: true,
      );

      bool pricePressed = false;
      bool buyPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: SingleChildScrollView(
              child: MessageBubble(
                message: message,
                onPriceButtonPressed: () => pricePressed = true,
                onBuyButtonPressed: () => buyPressed = true,
              ),
            ),
          ),
        ),
      );

      expect(find.text('This is a Pikachu VMAX card'), findsOneWidget);
      expect(find.text('Card AI'), findsOneWidget);
      expect(find.text('Last Sold Price'), findsOneWidget);
      expect(find.text('Buy Now'), findsOneWidget);

      // Tap price button
      await tester.tap(find.text('Last Sold Price'));
      expect(pricePressed, true);

      // Tap buy button
      await tester.tap(find.text('Buy Now'));
      expect(buyPressed, true);
    });

    testWidgets('does not show action buttons when disabled', (tester) async {
      final message = ChatMessage(
        id: '3',
        text: 'Just a regular message',
        sender: MessageSender.ai,
        timestamp: DateTime(2026, 1, 1, 13, 0),
      );

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(body: MessageBubble(message: message)),
        ),
      );

      expect(find.text('Last Sold Price'), findsNothing);
      expect(find.text('Buy Now'), findsNothing);
    });
  });

  group('MessageInput Widget', () {
    testWidgets('renders all input elements', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: MessageInput(
              onSendText: (_) {},
              onCameraPressed: () {},
              onGalleryPressed: () {},
              onPasteImage: (_) {},
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('camera_button')), findsOneWidget);
      expect(find.byKey(const Key('gallery_button')), findsOneWidget);
      expect(find.byKey(const Key('paste_button')), findsOneWidget);
      expect(find.byKey(const Key('message_input')), findsOneWidget);
      expect(find.byKey(const Key('send_button')), findsOneWidget);
    });

    testWidgets('sends text when send button is pressed', (tester) async {
      String? sentText;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: MessageInput(
              onSendText: (text) => sentText = text,
              onCameraPressed: () {},
              onGalleryPressed: () {},
              onPasteImage: (_) {},
            ),
          ),
        ),
      );

      // Type text
      await tester.enterText(find.byKey(const Key('message_input')), 'Hello');
      await tester.pump();

      // Tap send
      await tester.tap(find.byKey(const Key('send_button')));
      await tester.pump();

      expect(sentText, 'Hello');
    });

    testWidgets('does not send empty text', (tester) async {
      String? sentText;

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: MessageInput(
              onSendText: (text) => sentText = text,
              onCameraPressed: () {},
              onGalleryPressed: () {},
              onPasteImage: (_) {},
            ),
          ),
        ),
      );

      // Tap send without text
      await tester.tap(find.byKey(const Key('send_button')));
      await tester.pump();

      expect(sentText, isNull);
    });

    testWidgets('shows loading indicator when isLoading is true', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark(),
          home: Scaffold(
            body: MessageInput(
              isLoading: true,
              onSendText: (_) {},
              onCameraPressed: () {},
              onGalleryPressed: () {},
              onPasteImage: (_) {},
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
