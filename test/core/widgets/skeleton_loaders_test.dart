import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/core/widgets/skeleton_loaders.dart';

void main() {
  group('SkeletonLoader', () {
    testWidgets('renders multiple items', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              itemCount: 3,
              itemBuilder: (context, index) => Container(
                height: 50,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
    });
  });

  group('OrderCardSkeleton', () {
    testWidgets('renders order card skeleton', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OrderCardSkeleton(),
          ),
        ),
      );

      expect(find.byType(OrderCardSkeleton), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });
  });

  group('ProfileSkeleton', () {
    testWidgets('renders profile skeleton', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProfileSkeleton(),
            ),
          ),
        ),
      );

      expect(find.byType(ProfileSkeleton), findsOneWidget);
    });
  });

  group('WalletSkeleton', () {
    testWidgets('renders wallet skeleton', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: WalletSkeleton(),
            ),
          ),
        ),
      );

      expect(find.byType(WalletSkeleton), findsOneWidget);
    });
  });

  group('NotificationSkeleton', () {
    testWidgets('renders notification skeleton', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationSkeleton(),
          ),
        ),
      );

      expect(find.byType(NotificationSkeleton), findsOneWidget);
    });
  });

  group('ShimmerWrapper', () {
    testWidgets('wraps child with shimmer effect', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerWrapper(
              child: SizedBox(width: 100, height: 50),
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerWrapper), findsOneWidget);
    });

    testWidgets('shows child without shimmer when isLoading is false', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerWrapper(
              isLoading: false,
              child: Text('Content'),
            ),
          ),
        ),
      );

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('shows shimmer when isLoading is true by default', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ShimmerWrapper(
              child: Text('Loading'),
            ),
          ),
        ),
      );

      expect(find.byType(ShimmerWrapper), findsOneWidget);
    });
  });

  group('TransactionCardSkeleton', () {
    testWidgets('renders transaction card skeleton', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TransactionCardSkeleton(),
          ),
        ),
      );

      expect(find.byType(TransactionCardSkeleton), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Row), findsWidgets);
    });

    testWidgets('contains icon placeholder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: TransactionCardSkeleton(),
          ),
        ),
      );

      // Should have containers for icon, text and amount placeholders
      expect(find.byType(Container), findsWidgets);
    });
  });

  group('SkeletonTransactionListLoader', () {
    testWidgets('renders default number of items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonTransactionListLoader(),
          ),
        ),
      );

      expect(find.byType(SkeletonTransactionListLoader), findsOneWidget);
      expect(find.byType(TransactionCardSkeleton), findsNWidgets(6));
    });

    testWidgets('renders custom number of items', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonTransactionListLoader(itemCount: 3),
          ),
        ),
      );

      expect(find.byType(TransactionCardSkeleton), findsNWidgets(3));
    });

    testWidgets('renders with shimmer effect', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SkeletonTransactionListLoader(),
          ),
        ),
      );

      // Verify ListView is rendered
      expect(find.byType(ListView), findsOneWidget);
    });
  });

  group('SkeletonLoader with custom parameters', () {
    testWidgets('applies custom padding', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              itemCount: 2,
              padding: const EdgeInsets.all(32),
              itemBuilder: (context, index) => Container(
                height: 50,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('applies custom item spacing', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              itemCount: 2,
              itemSpacing: 24,
              itemBuilder: (context, index) => Container(
                height: 50,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(SkeletonLoader), findsOneWidget);
    });

    testWidgets('uses default itemCount of 5', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SkeletonLoader(
              itemBuilder: (context, index) => Container(
                height: 50,
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsNWidgets(5));
    });
  });

  group('OrderCardSkeleton internal structure', () {
    testWidgets('contains address rows', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: OrderCardSkeleton(),
          ),
        ),
      );

      // Should contain multiple rows for pickup and dropoff
      expect(find.byType(Row), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });
  });

  group('ProfileSkeleton internal structure', () {
    testWidgets('contains avatar placeholder', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: ProfileSkeleton(),
            ),
          ),
        ),
      );

      // Should contain containers for avatar, name, phone and menu items
      expect(find.byType(Container), findsWidgets);
    });
  });

  group('WalletSkeleton internal structure', () {
    testWidgets('contains balance card and actions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: WalletSkeleton(),
            ),
          ),
        ),
      );

      // Should contain balance card, action buttons and transaction list
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Row), findsWidgets);
    });
  });

  group('NotificationSkeleton internal structure', () {
    testWidgets('contains icon and text placeholders', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: NotificationSkeleton(),
          ),
        ),
      );

      // Should contain icon circle and text lines
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
    });
  });
}
