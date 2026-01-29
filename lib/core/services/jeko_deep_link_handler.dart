import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../features/wallet/presentation/bloc/jeko_payment_bloc.dart';
import '../../features/wallet/presentation/bloc/jeko_payment_event.dart';

/// Service pour gérer les deep links de paiement JEKO
class JekoDeepLinkHandler {
  static const String scheme = 'ouagachap';
  static const String successPath = '/payment/success';
  static const String errorPath = '/payment/error';

  /// Traiter un deep link de paiement
  static void handleDeepLink(BuildContext context, Uri uri) {
    if (uri.scheme != scheme) return;

    final path = uri.path;
    final transactionId = int.tryParse(uri.queryParameters['transaction_id'] ?? '');

    if (transactionId == null) {
      debugPrint('JekoDeepLink: transaction_id manquant');
      return;
    }

    debugPrint('JekoDeepLink: $path, transactionId: $transactionId');

    try {
      final bloc = context.read<JekoPaymentBloc>();

      if (path == successPath) {
        // Paiement réussi
        bloc.add(PaymentSuccessCallback(transactionId));
        _showSuccessSnackBar(context);
      } else if (path == errorPath) {
        // Paiement échoué
        bloc.add(PaymentErrorCallback(transactionId));
        _showErrorSnackBar(context);
      }
    } catch (e) {
      debugPrint('JekoDeepLink: Erreur - $e');
    }
  }

  static void _showSuccessSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 12),
            Text('Vérification du paiement en cours...'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  static void _showErrorSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 12),
            Text('Le paiement a échoué ou a été annulé'),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  /// Générer l'URL de succès pour JEKO
  static String getSuccessUrl(int transactionId) {
    return '$scheme://$successPath?transaction_id=$transactionId';
  }

  /// Générer l'URL d'erreur pour JEKO
  static String getErrorUrl(int transactionId) {
    return '$scheme://$errorPath?transaction_id=$transactionId';
  }
}

/// Extension pour GoRouter pour gérer les deep links JEKO
extension JekoGoRouterExtension on GoRouter {
  /// Configurer les routes de deep link pour JEKO
  static List<RouteBase> get jekoRoutes => [
        GoRoute(
          path: '/payment/success',
          name: 'payment-success',
          builder: (context, state) {
            final transactionId = int.tryParse(
              state.uri.queryParameters['transaction_id'] ?? '',
            );
            
            if (transactionId != null) {
              // Déclencher le callback de succès
              WidgetsBinding.instance.addPostFrameCallback((_) {
                try {
                  context.read<JekoPaymentBloc>().add(
                    PaymentSuccessCallback(transactionId),
                  );
                } catch (e) {
                  debugPrint('JekoRoute: Erreur - $e');
                }
              });
            }
            
            return const _PaymentResultPage(isSuccess: true);
          },
        ),
        GoRoute(
          path: '/payment/error',
          name: 'payment-error',
          builder: (context, state) {
            final transactionId = int.tryParse(
              state.uri.queryParameters['transaction_id'] ?? '',
            );
            
            if (transactionId != null) {
              // Déclencher le callback d'erreur
              WidgetsBinding.instance.addPostFrameCallback((_) {
                try {
                  context.read<JekoPaymentBloc>().add(
                    PaymentErrorCallback(transactionId),
                  );
                } catch (e) {
                  debugPrint('JekoRoute: Erreur - $e');
                }
              });
            }
            
            return const _PaymentResultPage(isSuccess: false);
          },
        ),
      ];
}

/// Page de résultat de paiement (temporaire, redirige vers le wallet)
class _PaymentResultPage extends StatefulWidget {
  final bool isSuccess;

  const _PaymentResultPage({required this.isSuccess});

  @override
  State<_PaymentResultPage> createState() => _PaymentResultPageState();
}

class _PaymentResultPageState extends State<_PaymentResultPage> {
  @override
  void initState() {
    super.initState();
    // Rediriger après un délai
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.go('/wallet');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.isSuccess ? Icons.check_circle : Icons.cancel,
              size: 80,
              color: widget.isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 24),
            Text(
              widget.isSuccess ? 'Paiement réussi!' : 'Paiement annulé',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              widget.isSuccess
                  ? 'Votre compte sera crédité sous peu'
                  : 'Veuillez réessayer',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 24),
            const CircularProgressIndicator(),
            const SizedBox(height: 12),
            Text(
              'Redirection...',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
