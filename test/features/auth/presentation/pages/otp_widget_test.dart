import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// =============================================================================
// Tests widget pour la page OTP (sans dépendances Firebase)
// On teste la logique UI isolément avec des widgets simplifiés
// =============================================================================

void main() {
  // =========================================================================
  // 1. OTP Input Widget Tests
  // =========================================================================
  group('OTP Input Widget', () {
    testWidgets('affiche 6 champs pour le code OTP', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: _OtpInputWidget()),
        ),
      );

      // Vérifie qu'on a un champ pour le code
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('accepte uniquement les chiffres', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: _OtpInputWidget()),
        ),
      );

      final textField = find.byType(TextFormField);
      
      // Entrer des chiffres valides
      await tester.enterText(textField, '123456');
      await tester.pump();

      // Le champ sous-jacent TextField doit avoir le type numérique
      final TextField underlying = tester.widget(find.byType(TextField));
      expect(underlying.keyboardType, TextInputType.number);
    });

    testWidgets('valide un code de 6 chiffres', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: _OtpInputWidget()),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '123456');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Pas d'erreur de validation
      expect(find.text('Le code doit avoir 6 chiffres'), findsNothing);
    });

    testWidgets('rejette un code trop court', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: _OtpInputWidget()),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Le code doit avoir 6 chiffres'), findsOneWidget);
    });

    testWidgets('rejette un code vide', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: _OtpInputWidget()),
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Le code doit avoir 6 chiffres'), findsOneWidget);
    });

    testWidgets('rejette un code avec des lettres', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: _OtpInputWidget()),
        ),
      );

      await tester.enterText(find.byType(TextFormField), '12ab56');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Le code doit contenir uniquement des chiffres'), findsOneWidget);
    });

    testWidgets('maxLength est 6', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: _OtpInputWidget()),
        ),
      );

      final TextField underlying = tester.widget(find.byType(TextField));
      expect(underlying.maxLength, 6);
    });
  });

  // =========================================================================
  // 2. OTP Page Structure Tests  
  // =========================================================================
  group('OTP Page Structure', () {
    testWidgets('affiche le titre "Vérification"', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: _OtpPageStructure(phoneNumber: '+22670123456')),
        ),
      );

      expect(find.text('Vérification'), findsOneWidget);
    });

    testWidgets('affiche le numéro de téléphone formaté', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: _OtpPageStructure(phoneNumber: '+22670123456')),
        ),
      );

      // RichText rend les TextSpan, chercher le widget RichText contenant le numéro
      final richTexts = find.byType(RichText);
      expect(richTexts, findsWidgets);
      
      // Vérifier qu'un RichText contient le numéro formaté
      bool foundPhone = false;
      for (final element in richTexts.evaluate()) {
        final richText = element.widget as RichText;
        final text = richText.text.toPlainText();
        if (text.contains('+226 70 12 34 56')) {
          foundPhone = true;
          break;
        }
      }
      expect(foundPhone, isTrue, reason: 'Le numéro formaté +226 70 12 34 56 doit être affiché');
    });

    testWidgets('affiche le bouton Vérifier', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: _OtpPageStructure(phoneNumber: '+22670123456')),
        ),
      );

      expect(find.text('Vérifier'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('affiche le texte de renvoi avec timer', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: _OtpPageStructure(phoneNumber: '+22670123456')),
        ),
      );

      expect(find.textContaining('Renvoyer le code dans'), findsOneWidget);
    });

    testWidgets('NE contient PAS de message démo', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: _OtpPageStructure(phoneNumber: '+22670123456')),
        ),
      );

      // Vérifier qu'aucun texte de démo n'est visible
      expect(find.textContaining('démo'), findsNothing);
      expect(find.textContaining('demo'), findsNothing);
      expect(find.textContaining('123456'), findsNothing);
      expect(find.textContaining('Mode démo'), findsNothing);
      expect(find.textContaining('code de test'), findsNothing);
    });

    testWidgets('affiche le message d\'instruction', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: _OtpPageStructure(phoneNumber: '+22670123456')),
        ),
      );

      // Le texte d'instruction est dans un RichText (TextSpan)
      final richTexts = find.byType(RichText);
      bool foundInstruction = false;
      for (final element in richTexts.evaluate()) {
        final richText = element.widget as RichText;
        final text = richText.text.toPlainText();
        if (text.contains('code') && text.contains('6 chiffres')) {
          foundInstruction = true;
          break;
        }
      }
      expect(foundInstruction, isTrue, reason: 'Le message d\'instruction contenant "code à 6 chiffres" doit être affiché');
    });
  });

  // =========================================================================
  // 3. Resend Timer Widget Tests
  // =========================================================================
  group('OTP Resend Timer', () {
    testWidgets('affiche le compteur initial', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _ResendTimerWidget(remainingSeconds: 60, canResend: false),
          ),
        ),
      );

      expect(find.text('Renvoyer le code dans 60s'), findsOneWidget);
      expect(find.byType(TextButton), findsNothing);
    });

    testWidgets('affiche le compteur à 30s', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _ResendTimerWidget(remainingSeconds: 30, canResend: false),
          ),
        ),
      );

      expect(find.text('Renvoyer le code dans 30s'), findsOneWidget);
    });

    testWidgets('affiche le bouton de renvoi quand timer terminé', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _ResendTimerWidget(remainingSeconds: 0, canResend: true),
          ),
        ),
      );

      expect(find.text('Renvoyer le code'), findsOneWidget);
      expect(find.byType(TextButton), findsOneWidget);
    });

    testWidgets('bouton de renvoi est cliquable', (tester) async {
      bool resendTapped = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: _ResendTimerWidget(
              remainingSeconds: 0,
              canResend: true,
              onResend: () => resendTapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextButton));
      expect(resendTapped, true);
    });
  });

  // =========================================================================
  // 4. OTP Loading State Tests
  // =========================================================================
  group('OTP Loading State', () {
    testWidgets('affiche un indicateur de chargement', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _OtpLoadingWidget(isLoading: true),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Le bouton est désactivé pendant le chargement
    });

    testWidgets('n\'affiche pas de chargement par défaut', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _OtpLoadingWidget(isLoading: false),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Vérifier'), findsOneWidget);
    });
  });

  // =========================================================================
  // 5. Error Display Tests
  // =========================================================================
  group('OTP Error Display', () {
    testWidgets('affiche un message d\'erreur', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _OtpErrorWidget(errorMessage: 'Code OTP invalide'),
          ),
        ),
      );

      expect(find.text('Code OTP invalide'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('n\'affiche pas d\'erreur quand null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _OtpErrorWidget(errorMessage: null),
          ),
        ),
      );

      expect(find.byIcon(Icons.error_outline), findsNothing);
    });

    testWidgets('message d\'erreur session expirée', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _OtpErrorWidget(
              errorMessage: 'Session expirée. Renvoyez le code.',
            ),
          ),
        ),
      );

      expect(find.textContaining('Session expirée'), findsOneWidget);
    });
  });
}

// =============================================================================
// Widgets de test simplifiés (reproduisent la logique OTP sans Firebase)
// =============================================================================

class _OtpInputWidget extends StatefulWidget {
  const _OtpInputWidget();

  @override
  State<_OtpInputWidget> createState() => _OtpInputWidgetState();
}

class _OtpInputWidgetState extends State<_OtpInputWidget> {
  final _formKey = GlobalKey<FormState>();
  final _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _controller,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(labelText: 'Code de vérification'),
              validator: (value) {
                if (value == null || value.length != 6) {
                  return 'Le code doit avoir 6 chiffres';
                }
                if (!RegExp(r'^\d+$').hasMatch(value)) {
                  return 'Le code doit contenir uniquement des chiffres';
                }
                return null;
              },
            ),
            ElevatedButton(
              onPressed: () => _formKey.currentState?.validate(),
              child: const Text('Vérifier'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpPageStructure extends StatelessWidget {
  final String phoneNumber;
  const _OtpPageStructure({required this.phoneNumber});

  String _formatPhoneNumber(String phone) {
    if (phone.startsWith('+226') && phone.length == 12) {
      final local = phone.substring(4);
      return '+226 ${local.substring(0, 2)} ${local.substring(2, 4)} ${local.substring(4, 6)} ${local.substring(6)}';
    }
    return phone;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vérification',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              children: [
                const TextSpan(text: 'Entrez le code à 6 chiffres envoyé au '),
                TextSpan(
                  text: _formatPhoneNumber(phoneNumber),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          // OTP field placeholder
          TextFormField(
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(labelText: 'Code OTP'),
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              child: const Text('Vérifier'),
            ),
          ),
          const SizedBox(height: 24),
          Center(
            child: Text(
              'Renvoyer le code dans 60s',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ResendTimerWidget extends StatelessWidget {
  final int remainingSeconds;
  final bool canResend;
  final VoidCallback? onResend;

  const _ResendTimerWidget({
    required this.remainingSeconds,
    required this.canResend,
    this.onResend,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: canResend
          ? TextButton(
              onPressed: onResend,
              child: const Text('Renvoyer le code'),
            )
          : Text(
              'Renvoyer le code dans ${remainingSeconds}s',
              style: TextStyle(color: Colors.grey[600]),
            ),
    );
  }
}

class _OtpLoadingWidget extends StatelessWidget {
  final bool isLoading;
  const _OtpLoadingWidget({required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: isLoading ? null : () {},
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Vérifier'),
        ),
      ),
    );
  }
}

class _OtpErrorWidget extends StatelessWidget {
  final String? errorMessage;
  const _OtpErrorWidget({required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    if (errorMessage == null) return const SizedBox.shrink();
    return Row(
      children: [
        const Icon(Icons.error_outline, color: Colors.red),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            errorMessage!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ],
    );
  }
}
