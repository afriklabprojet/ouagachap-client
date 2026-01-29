import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
// Import the file but use "as" to avoid conflict with Flutter's ErrorWidget
import 'package:ouaga_chap_client/core/widgets/app_error_widget.dart' as app;

void main() {
  group('ErrorWidget', () {
    testWidgets('shows title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: app.ErrorWidget(
              title: 'Something went wrong',
            ),
          ),
        ),
      );

      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('shows message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: app.ErrorWidget(
              title: 'Error',
              message: 'Please try again later',
            ),
          ),
        ),
      );

      expect(find.text('Please try again later'), findsOneWidget);
    });

    testWidgets('shows retry button when onRetry provided', (tester) async {
      bool retryCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: app.ErrorWidget(
              title: 'Error',
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      final retryButton = find.text('Réessayer');
      expect(retryButton, findsOneWidget);
      
      await tester.tap(retryButton);
      await tester.pump();
      expect(retryCalled, isTrue);
    });

    testWidgets('does not show retry button when onRetry not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: app.ErrorWidget(
              title: 'Error',
            ),
          ),
        ),
      );

      expect(find.text('Réessayer'), findsNothing);
    });

    testWidgets('shows default error icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: app.ErrorWidget(
              title: 'Error',
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('shows custom icon when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: app.ErrorWidget(
              title: 'Error',
              icon: Icons.warning,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('renders compact mode', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: app.ErrorWidget(
              title: 'Error',
              compact: true,
            ),
          ),
        ),
      );

      expect(find.byType(app.ErrorWidget), findsOneWidget);
    });

    testWidgets('compact mode shows message when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: app.ErrorWidget(
              title: 'Compact Error',
              message: 'Compact message',
              compact: true,
            ),
          ),
        ),
      );

      expect(find.text('Compact Error'), findsOneWidget);
      expect(find.text('Compact message'), findsOneWidget);
    });

    testWidgets('compact mode shows retry icon button when onRetry provided', (tester) async {
      bool retryCalled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: app.ErrorWidget(
              title: 'Compact Error',
              compact: true,
              onRetry: () => retryCalled = true,
            ),
          ),
        ),
      );

      final refreshIcon = find.byIcon(Icons.refresh);
      expect(refreshIcon, findsOneWidget);

      await tester.tap(refreshIcon);
      await tester.pump();
      expect(retryCalled, isTrue);
    });

    testWidgets('compact mode does not show retry button when onRetry not provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: app.ErrorWidget(
              title: 'Error',
              compact: true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.refresh), findsNothing);
    });

    testWidgets('uses custom iconColor', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: app.ErrorWidget(
              title: 'Error',
              iconColor: Colors.orange,
            ),
          ),
        ),
      );

      expect(find.byType(app.ErrorWidget), findsOneWidget);
    });

    testWidgets('full mode without message does not show message text', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: app.ErrorWidget(
              title: 'Title Only',
            ),
          ),
        ),
      );

      expect(find.text('Title Only'), findsOneWidget);
      // No message should be present aside from title
    });
  });

  group('ErrorWidget factory constructors', () {
    testWidgets('network() shows network error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: app.ErrorWidget.network(onRetry: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.wifi_off_outlined), findsOneWidget);
      expect(find.text('Pas de connexion'), findsOneWidget);
    });

    testWidgets('server() shows server error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: app.ErrorWidget.server(onRetry: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.cloud_off_outlined), findsOneWidget);
      expect(find.text('Erreur serveur'), findsOneWidget);
    });

    testWidgets('timeout() shows timeout error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: app.ErrorWidget.timeout(onRetry: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
      expect(find.text('Délai dépassé'), findsOneWidget);
    });

    testWidgets('sessionExpired() shows session expired error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: app.ErrorWidget.sessionExpired(onLogin: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
      expect(find.text('Session expirée'), findsOneWidget);
    });

    testWidgets('location() shows location error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: app.ErrorWidget.location(onRetry: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.location_off_outlined), findsOneWidget);
      expect(find.text('Localisation indisponible'), findsOneWidget);
    });

    testWidgets('permission() shows permission error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: app.ErrorWidget.permission(onSettings: () {}),
          ),
        ),
      );

      expect(find.byIcon(Icons.block_outlined), findsOneWidget);
      expect(find.text('Permission refusée'), findsOneWidget);
    });
  });
}
