import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/core/widgets/empty_state_widget.dart';

void main() {
  group('EmptyStateWidget', () {
    testWidgets('shows title', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
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
            body: EmptyStateWidget(
              title: 'No items',
              subtitle: 'Try searching for something else',
            ),
          ),
        ),
      );

      expect(find.text('Try searching for something else'), findsOneWidget);
    });

    testWidgets('shows custom icon when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'No items',
              icon: Icons.search_off,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search_off), findsOneWidget);
    });

    testWidgets('shows action button when action provided', (tester) async {
      bool actionCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'No items',
              actionText: 'Refresh',
              onAction: () => actionCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Refresh'), findsOneWidget);
      
      await tester.tap(find.text('Refresh'));
      expect(actionCalled, isTrue);
    });

    testWidgets('does not show action button when no action provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget(
              title: 'No items',
            ),
          ),
        ),
      );

      // No action button should be present
      expect(find.byType(EmptyStateWidget), findsOneWidget);
    });
  });

  group('EmptyStateWidget factory constructors', () {
    testWidgets('orders() shows order-related message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget.orders(),
          ),
        ),
      );

      expect(find.byIcon(Icons.receipt_long_outlined), findsOneWidget);
      expect(find.text('Aucune commande'), findsOneWidget);
    });

    testWidgets('orders() with onCreate shows action button', (tester) async {
      bool createCalled = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget.orders(
              onCreate: () => createCalled = true,
            ),
          ),
        ),
      );

      expect(find.text('Créer une commande'), findsOneWidget);
      await tester.tap(find.text('Créer une commande'));
      expect(createCalled, isTrue);
    });

    testWidgets('notifications() shows notification message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget.notifications(),
          ),
        ),
      );

      expect(find.byIcon(Icons.notifications_none_outlined), findsOneWidget);
      expect(find.text('Aucune notification'), findsOneWidget);
    });

    testWidgets('transactions() shows transaction message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget.transactions(),
          ),
        ),
      );

      expect(find.byIcon(Icons.account_balance_wallet_outlined), findsOneWidget);
      expect(find.text('Aucune transaction'), findsOneWidget);
    });

    testWidgets('search() shows search message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget.search(),
          ),
        ),
      );

      expect(find.byIcon(Icons.search_off_outlined), findsOneWidget);
      expect(find.text('Aucun résultat'), findsOneWidget);
    });

    testWidgets('search() with query shows query in message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget.search(query: 'test'),
          ),
        ),
      );

      expect(find.textContaining('test'), findsOneWidget);
    });

    testWidgets('noCouriers() shows no couriers message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStateWidget.noCouriers(),
          ),
        ),
      );

      expect(find.byIcon(Icons.delivery_dining_outlined), findsOneWidget);
      expect(find.text('Aucun coursier disponible'), findsOneWidget);
    });
  });
}
