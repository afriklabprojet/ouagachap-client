import '../datasources/jeko_payment_datasource.dart';

/// Repository pour les paiements JEKO
class JekoPaymentRepository {
  final JekoPaymentRemoteDataSource _remoteDataSource;

  JekoPaymentRepository(this._remoteDataSource);

  /// Récupérer les méthodes de paiement disponibles
  Future<List<JekoPaymentMethod>> getPaymentMethods() async {
    try {
      return await _remoteDataSource.getPaymentMethods();
    } catch (e) {
      throw Exception('Impossible de charger les méthodes de paiement: $e');
    }
  }

  /// Initier une recharge de wallet
  Future<JekoPaymentResult> initiateWalletRecharge({
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      return await _remoteDataSource.initiateWalletRecharge(
        amount: amount,
        paymentMethod: paymentMethod,
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'initiation de la recharge: $e');
    }
  }

  /// Initier le paiement d'une commande
  Future<JekoPaymentResult> initiateOrderPayment({
    required String orderId,
    required String paymentMethod,
  }) async {
    try {
      return await _remoteDataSource.initiateOrderPayment(
        orderId: orderId,
        paymentMethod: paymentMethod,
      );
    } catch (e) {
      throw Exception('Erreur lors de l\'initiation du paiement: $e');
    }
  }

  /// Vérifier le statut d'une transaction
  Future<JekoTransaction> checkTransactionStatus(int transactionId) async {
    try {
      return await _remoteDataSource.checkTransactionStatus(transactionId);
    } catch (e) {
      throw Exception('Erreur lors de la vérification du statut: $e');
    }
  }

  /// Récupérer l'historique des transactions
  Future<List<JekoTransaction>> getTransactionHistory({int page = 1}) async {
    try {
      return await _remoteDataSource.getTransactionHistory(page: page);
    } catch (e) {
      throw Exception('Erreur lors du chargement de l\'historique: $e');
    }
  }

  /// Callback après paiement réussi
  Future<JekoTransaction> paymentSuccessCallback(int transactionId) async {
    try {
      return await _remoteDataSource.paymentSuccessCallback(transactionId);
    } catch (e) {
      throw Exception('Erreur lors de la confirmation du paiement: $e');
    }
  }

  /// Callback après paiement échoué
  Future<void> paymentErrorCallback(int transactionId) async {
    try {
      await _remoteDataSource.paymentErrorCallback(transactionId);
    } catch (e) {
      // Ignorer les erreurs de callback d'erreur
    }
  }
}
