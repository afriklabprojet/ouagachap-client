import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/core/widgets/loading_button.dart';

void main() {
  group('LoadingButton', () {
    testWidgets('shows text when not loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              text: 'Submit',
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.text('Submit'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              text: 'Submit',
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              text: 'Submit',
              icon: Icons.check,
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.check), findsOneWidget);
    });

    testWidgets('is disabled when loading', (tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () => pressed = true,
              text: 'Submit',
              isLoading: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(LoadingButton));
      expect(pressed, isFalse);
    });

    testWidgets('calls onPressed when tapped and not loading', (tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () => pressed = true,
              text: 'Submit',
              isLoading: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isTrue);
    });

    testWidgets('uses custom background color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              text: 'Submit',
              backgroundColor: Colors.red,
              isLoading: false,
            ),
          ),
        ),
      );

      // Just verify it builds without error
      expect(find.byType(LoadingButton), findsOneWidget);
    });

    testWidgets('uses label as alias for text', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              label: 'Click Me',
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('prefers text over label when both provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              text: 'Text Value',
              label: 'Label Value',
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.text('Text Value'), findsOneWidget);
      expect(find.text('Label Value'), findsNothing);
    });

    testWidgets('renders outlined button when outlined is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              text: 'Outlined',
              outlined: true,
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('is disabled when isEnabled is false', (tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () => pressed = true,
              text: 'Submit',
              isEnabled: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(LoadingButton));
      expect(pressed, isFalse);
    });

    testWidgets('uses custom textColor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              text: 'Colored',
              textColor: Colors.yellow,
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.byType(LoadingButton), findsOneWidget);
    });

    testWidgets('uses custom width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              text: 'Custom Width',
              width: 200,
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.byType(LoadingButton), findsOneWidget);
    });

    testWidgets('uses custom height', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              text: 'Custom Height',
              height: 60,
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.byType(LoadingButton), findsOneWidget);
    });

    testWidgets('uses custom borderRadius', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              text: 'Rounded',
              borderRadius: 24,
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.byType(LoadingButton), findsOneWidget);
    });

    testWidgets('shows loading in outlined button', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              text: 'Loading Outlined',
              outlined: true,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
    });

    testWidgets('outlined button is disabled when loading', (tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () => pressed = true,
              text: 'Submit',
              outlined: true,
              isLoading: true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(LoadingButton));
      expect(pressed, isFalse);
    });

    testWidgets('outlined button is disabled when isEnabled is false', (tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () => pressed = true,
              text: 'Submit',
              outlined: true,
              isEnabled: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(LoadingButton));
      expect(pressed, isFalse);
    });

    testWidgets('shows icon in row when not loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingButton(
              onPressed: () {},
              text: 'With Icon',
              icon: Icons.send,
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.send), findsOneWidget);
      expect(find.text('With Icon'), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });
  });

  group('LoadingIconButton', () {
    testWidgets('shows icon when not loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingIconButton(
              icon: Icons.refresh,
              onPressed: () {},
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.refresh), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('shows loading indicator when loading', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingIconButton(
              icon: Icons.refresh,
              onPressed: () {},
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('calls onPressed when tapped and not loading', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingIconButton(
              icon: Icons.refresh,
              onPressed: () => pressed = true,
              isLoading: false,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      expect(pressed, isTrue);
    });

    testWidgets('uses custom color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingIconButton(
              icon: Icons.refresh,
              onPressed: () {},
              color: Colors.red,
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.byType(LoadingIconButton), findsOneWidget);
    });

    testWidgets('uses custom size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingIconButton(
              icon: Icons.refresh,
              onPressed: () {},
              size: 32,
              isLoading: false,
            ),
          ),
        ),
      );

      expect(find.byType(LoadingIconButton), findsOneWidget);
    });

    testWidgets('loading indicator uses custom color', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingIconButton(
              icon: Icons.refresh,
              onPressed: () {},
              color: Colors.green,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('loading indicator uses custom size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LoadingIconButton(
              icon: Icons.refresh,
              onPressed: () {},
              size: 48,
              isLoading: true,
            ),
          ),
        ),
      );

      // Verify the SizedBox has the correct size
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 48);
      expect(sizedBox.height, 48);
    });
  });
}
