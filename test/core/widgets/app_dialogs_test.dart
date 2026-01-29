import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/core/widgets/app_dialogs.dart';

void main() {
  group('ConfirmDialog', () {
    testWidgets('shows title and message', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await ConfirmDialog.show(
                  context,
                  title: 'Confirm Action',
                  message: 'Are you sure?',
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Confirm Action'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
    });

    testWidgets('shows custom button texts', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await ConfirmDialog.show(
                  context,
                  title: 'Delete',
                  message: 'Delete item?',
                  confirmText: 'Yes, Delete',
                  cancelText: 'No, Keep',
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Yes, Delete'), findsOneWidget);
      expect(find.text('No, Keep'), findsOneWidget);
    });

    testWidgets('returns true when confirmed', (tester) async {
      bool? result;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ConfirmDialog.show(
                  context,
                  title: 'Confirm',
                  message: 'Proceed?',
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Confirmer'));
      await tester.pumpAndSettle();

      expect(result, isTrue);
    });

    testWidgets('returns false when cancelled', (tester) async {
      bool? result;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                result = await ConfirmDialog.show(
                  context,
                  title: 'Confirm',
                  message: 'Proceed?',
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Annuler'));
      await tester.pumpAndSettle();

      expect(result, isFalse);
    });

    testWidgets('shows dangerous style when isDangerous is true', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await ConfirmDialog.show(
                  context,
                  title: 'Delete',
                  message: 'This cannot be undone',
                  isDangerous: true,
                );
              },
              child: const Text('Open Dialog'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('shows icon when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => ConfirmDialog(
                      title: 'Delete Item',
                      message: 'Are you sure?',
                      icon: Icons.delete,
                      isDangerous: true,
                      onConfirm: () {},
                      onCancel: () {},
                    ),
                  );
                },
                child: const Text('Open Dialog'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Dialog'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete), findsOneWidget);
      expect(find.text('Delete Item'), findsOneWidget);
    });
  });

  group('ConfirmDialog factory methods', () {
    testWidgets('logout() shows logout confirmation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await ConfirmDialog.logout(context);
              },
              child: const Text('Logout'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();

      expect(find.text('Déconnexion'), findsOneWidget);
      expect(find.text('Se déconnecter'), findsOneWidget);
    });

    testWidgets('cancelOrder() shows cancel order confirmation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await ConfirmDialog.cancelOrder(context);
              },
              child: const Text('Cancel Order'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Cancel Order'));
      await tester.pumpAndSettle();

      // "Annuler la commande" appears both in title and confirm button
      expect(find.text('Annuler la commande'), findsWidgets);
    });

    testWidgets('delete() shows delete confirmation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await ConfirmDialog.delete(context);
              },
              child: const Text('Delete'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.text('Supprimer'), findsWidgets);
    });

    testWidgets('delete() with itemName shows item name', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await ConfirmDialog.delete(context, itemName: 'Test Item');
              },
              child: const Text('Delete'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Test Item'), findsOneWidget);
    });
  });

  group('SuccessDialog', () {
    testWidgets('shows title', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await SuccessDialog.show(
                  context,
                  title: 'Operation Successful',
                );
              },
              child: const Text('Show Success'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Success'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Operation Successful'), findsOneWidget);
    });

    testWidgets('shows message when provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await SuccessDialog.show(
                  context,
                  title: 'Success',
                  message: 'Your changes have been saved',
                );
              },
              child: const Text('Show Success'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Success'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Your changes have been saved'), findsOneWidget);
    });

    testWidgets('shows button when buttonText provided', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await SuccessDialog.show(
                  context,
                  title: 'Success',
                  buttonText: 'Continue',
                );
              },
              child: const Text('Show Success'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Success'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Continue'), findsOneWidget);
    });
  });

  group('SuccessDialog factory methods', () {
    testWidgets('orderConfirmed() shows order confirmation', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await SuccessDialog.orderConfirmed(context);
              },
              child: const Text('Confirm Order'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Confirm Order'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Commande confirmée !'), findsOneWidget);
    });

    testWidgets('paymentSuccess() shows payment success', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await SuccessDialog.paymentSuccess(context);
              },
              child: const Text('Payment'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Payment'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Paiement réussi !'), findsOneWidget);
    });

    testWidgets('profileUpdated() shows profile updated', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                await SuccessDialog.profileUpdated(context);
              },
              child: const Text('Update Profile'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Update Profile'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));

      expect(find.text('Profil mis à jour !'), findsOneWidget);
      
      // Close the dialog manually to prevent pending timer issues
      await tester.pump(const Duration(seconds: 3));
    });
  });
}
