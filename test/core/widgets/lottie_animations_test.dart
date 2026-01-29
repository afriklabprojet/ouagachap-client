import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/core/widgets/lottie_animations.dart';

void main() {
  group('LottieAssets', () {
    test('has correct asset paths', () {
      expect(LottieAssets.success, contains('success.json'));
      expect(LottieAssets.error, contains('error.json'));
      expect(LottieAssets.loading, contains('loading.json'));
      expect(LottieAssets.empty, contains('empty.json'));
      expect(LottieAssets.delivery, contains('delivery.json'));
    });

    test('all paths point to animations folder', () {
      expect(LottieAssets.success, startsWith('assets/animations/'));
      expect(LottieAssets.error, startsWith('assets/animations/'));
      expect(LottieAssets.loading, startsWith('assets/animations/'));
      expect(LottieAssets.empty, startsWith('assets/animations/'));
      expect(LottieAssets.delivery, startsWith('assets/animations/'));
    });
  });

  group('AnimatedLoadingWidget', () {
    testWidgets('renders without crashing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedLoadingWidget(),
          ),
        ),
      );

      // Should contain a Center widget
      expect(find.byType(Center), findsWidgets);
    });

    testWidgets('shows message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedLoadingWidget(
              message: 'Loading data...',
            ),
          ),
        ),
      );

      expect(find.text('Loading data...'), findsOneWidget);
    });

    testWidgets('applies custom size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedLoadingWidget(
              size: 150,
            ),
          ),
        ),
      );

      // Widget should be built successfully with custom size
      expect(find.byType(AnimatedLoadingWidget), findsOneWidget);
    });
  });

  group('AnimatedEmptyWidget', () {
    testWidgets('shows title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedEmptyWidget(
              title: 'No items found',
            ),
          ),
        ),
      );

      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('shows subtitle when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedEmptyWidget(
              title: 'No items',
              subtitle: 'Try a different search',
            ),
          ),
        ),
      );

      expect(find.text('Try a different search'), findsOneWidget);
    });

    testWidgets('shows action button when callback provided', (tester) async {
      bool actionCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedEmptyWidget(
              title: 'No results',
              actionText: 'Retry',
              onAction: () => actionCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      
      await tester.tap(find.text('Retry'));
      await tester.pump();
      
      expect(actionCalled, isTrue);
    });

    testWidgets('does not show action button when no callback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedEmptyWidget(
              title: 'No items',
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('applies custom animation size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedEmptyWidget(
              title: 'Empty',
              animationSize: 200,
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedEmptyWidget), findsOneWidget);
    });
  });

  group('LottieAnimation', () {
    testWidgets('renders basic animation', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LottieAnimation(
              asset: LottieAssets.loading,
            ),
          ),
        ),
      );

      expect(find.byType(LottieAnimation), findsOneWidget);
    });

    testWidgets('LottieAnimation.success creates success animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LottieAnimation.success(),
          ),
        ),
      );

      expect(find.byType(LottieAnimation), findsOneWidget);
    });

    testWidgets('LottieAnimation.error creates error animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LottieAnimation.error(),
          ),
        ),
      );

      expect(find.byType(LottieAnimation), findsOneWidget);
    });

    testWidgets('LottieAnimation.loading creates loading animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LottieAnimation.loading(),
          ),
        ),
      );

      expect(find.byType(LottieAnimation), findsOneWidget);
    });

    testWidgets('LottieAnimation.empty creates empty animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LottieAnimation.empty(),
          ),
        ),
      );

      expect(find.byType(LottieAnimation), findsOneWidget);
    });

    testWidgets('LottieAnimation.delivery creates delivery animation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LottieAnimation.delivery(),
          ),
        ),
      );

      expect(find.byType(LottieAnimation), findsOneWidget);
    });

    testWidgets('accepts custom size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LottieAnimation.loading(size: 100),
          ),
        ),
      );

      expect(find.byType(LottieAnimation), findsOneWidget);
    });

    testWidgets('accepts custom width and height', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LottieAnimation(
              asset: LottieAssets.loading,
              width: 200,
              height: 150,
            ),
          ),
        ),
      );

      expect(find.byType(LottieAnimation), findsOneWidget);
    });

    testWidgets('accepts reverse parameter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LottieAnimation(
              asset: LottieAssets.loading,
              reverse: true,
            ),
          ),
        ),
      );

      expect(find.byType(LottieAnimation), findsOneWidget);
    });

    testWidgets('accepts repeat parameter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LottieAnimation(
              asset: LottieAssets.loading,
              repeat: false,
            ),
          ),
        ),
      );

      expect(find.byType(LottieAnimation), findsOneWidget);
    });

    testWidgets('accepts fit parameter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: LottieAnimation(
              asset: LottieAssets.loading,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );

      expect(find.byType(LottieAnimation), findsOneWidget);
    });
  });

  group('AnimatedSuccessWidget', () {
    testWidgets('shows title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedSuccessWidget(
              title: 'Success!',
            ),
          ),
        ),
      );

      expect(find.text('Success!'), findsOneWidget);
    });

    testWidgets('shows subtitle when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedSuccessWidget(
              title: 'Success!',
              subtitle: 'Operation completed',
            ),
          ),
        ),
      );

      expect(find.text('Operation completed'), findsOneWidget);
    });

    testWidgets('shows button when callback provided', (tester) async {
      bool buttonPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSuccessWidget(
              title: 'Success!',
              buttonText: 'Continue',
              onButtonPressed: () => buttonPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
      
      await tester.tap(find.text('Continue'));
      await tester.pump();
      
      expect(buttonPressed, isTrue);
    });

    testWidgets('applies custom animation size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedSuccessWidget(
              title: 'Success!',
              animationSize: 200,
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedSuccessWidget), findsOneWidget);
    });

    testWidgets('auto dismisses after duration', (tester) async {
      bool autoDismissCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedSuccessWidget(
              title: 'Success!',
              autoDismissAfter: const Duration(milliseconds: 100),
              onAutoDismiss: () => autoDismissCalled = true,
            ),
          ),
        ),
      );

      // Wait for auto dismiss
      await tester.pump(const Duration(milliseconds: 150));
      
      expect(autoDismissCalled, isTrue);
    });
  });

  group('AnimatedErrorWidget', () {
    testWidgets('shows title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedErrorWidget(
              title: 'Error occurred',
            ),
          ),
        ),
      );

      expect(find.text('Error occurred'), findsOneWidget);
    });

    testWidgets('shows subtitle when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedErrorWidget(
              title: 'Error',
              subtitle: 'Please try again',
            ),
          ),
        ),
      );

      expect(find.text('Please try again'), findsOneWidget);
    });

    testWidgets('shows message (alias for subtitle)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedErrorWidget(
              title: 'Error',
              message: 'Connection failed',
            ),
          ),
        ),
      );

      expect(find.text('Connection failed'), findsOneWidget);
    });

    testWidgets('shows retry button when callback provided', (tester) async {
      bool retryCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AnimatedErrorWidget(
              title: 'Error',
              retryText: 'Retry',
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
      
      await tester.tap(find.text('Retry'));
      await tester.pump();
      
      expect(retryCalled, isTrue);
    });

    testWidgets('does not show retry button when no callback', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedErrorWidget(
              title: 'Error',
            ),
          ),
        ),
      );

      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('applies custom animation size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedErrorWidget(
              title: 'Error',
              animationSize: 180,
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedErrorWidget), findsOneWidget);
    });
  });

  group('AnimatedSuccessDialog', () {
    testWidgets('shows title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedSuccessDialog(
              title: 'Success!',
            ),
          ),
        ),
      );

      expect(find.text('Success!'), findsOneWidget);
    });

    testWidgets('shows message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedSuccessDialog(
              title: 'Success!',
              message: 'Your order is confirmed',
            ),
          ),
        ),
      );

      expect(find.text('Your order is confirmed'), findsOneWidget);
    });

    testWidgets('shows custom button text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedSuccessDialog(
              title: 'Success!',
              buttonText: 'Continue',
            ),
          ),
        ),
      );

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('shows default OK button', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedSuccessDialog(
              title: 'Success!',
            ),
          ),
        ),
      );

      expect(find.text('OK'), findsOneWidget);
    });

    testWidgets('static show method displays dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AnimatedSuccessDialog.show(
                  context,
                  title: 'Test Dialog',
                  message: 'Test message',
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Test Dialog'), findsOneWidget);
      expect(find.text('Test message'), findsOneWidget);
    });

    testWidgets('static show method with onPressed callback', (tester) async {
      bool pressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AnimatedSuccessDialog.show(
                  context,
                  title: 'Test',
                  onPressed: () => pressed = true,
                ),
                child: const Text('Show Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.byType(AnimatedSuccessDialog), findsOneWidget);
    });

    testWidgets('calls onDismiss when button pressed', (tester) async {
      bool dismissed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => AnimatedSuccessDialog.show(
                  context,
                  title: 'Test',
                  onDismiss: () => dismissed = true,
                ),
                child: const Text('Show'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });
  });

  group('AnimatedEmptyWidget with message alias', () {
    testWidgets('shows message as subtitle alias', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedEmptyWidget(
              title: 'Empty',
              message: 'No items found',
            ),
          ),
        ),
      );

      expect(find.text('No items found'), findsOneWidget);
    });

    testWidgets('subtitle takes precedence over message', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedEmptyWidget(
              title: 'Empty',
              subtitle: 'Subtitle text',
              message: 'Message text',
            ),
          ),
        ),
      );

      expect(find.text('Subtitle text'), findsOneWidget);
      expect(find.text('Message text'), findsNothing);
    });

    testWidgets('accepts icon parameter (ignored)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedEmptyWidget(
              title: 'Empty',
              icon: Icons.inbox,
            ),
          ),
        ),
      );

      expect(find.byType(AnimatedEmptyWidget), findsOneWidget);
    });
  });

  group('AnimatedLoadingWidget with messageColor', () {
    testWidgets('applies custom message color', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedLoadingWidget(
              message: 'Loading...',
              messageColor: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('Loading...'), findsOneWidget);
    });
  });

  group('LottieAnimation factory methods with custom parameters', () {
    testWidgets('success with repeat', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LottieAnimation.success(repeat: true),
          ),
        ),
      );

      expect(find.byType(LottieAnimation), findsOneWidget);
    });

    testWidgets('success with custom size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LottieAnimation.success(size: 200),
          ),
        ),
      );

      expect(find.byType(LottieAnimation), findsOneWidget);
    });

    testWidgets('error with custom size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LottieAnimation.error(size: 150),
          ),
        ),
      );

      expect(find.byType(LottieAnimation), findsOneWidget);
    });

    testWidgets('error with repeat', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LottieAnimation.error(repeat: true),
          ),
        ),
      );

      expect(find.byType(LottieAnimation), findsOneWidget);
    });

    testWidgets('empty with custom size', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LottieAnimation.empty(size: 200),
          ),
        ),
      );

      expect(find.byType(LottieAnimation), findsOneWidget);
    });

    testWidgets('delivery with custom dimensions', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LottieAnimation.delivery(width: 300, height: 150),
          ),
        ),
      );

      expect(find.byType(LottieAnimation), findsOneWidget);
    });
  });
}
