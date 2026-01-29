import '../../../../core/network/api_client.dart';

/// Modèle pour une méthode de paiement JEKO
class JekoPaymentMethod {
  final String code;
  final String name;
  final String icon;

  JekoPaymentMethod({
    required this.code,
    required this.name,
    required this.icon,
  });

  factory JekoPaymentMethod.fromJson(Map<String, dynamic> json) {
    return JekoPaymentMethod(
      code: json['code'] ?? '',
      name: json['name'] ?? '',
      icon: json['icon'] ?? '💳',
    );
  }
}

/// Modèle pour une transaction JEKO
class JekoTransaction {
  final int id;
  final String? jekoId;
  final String reference;
  final String type;
  final double amount;
  final String currency;
  final double fees;
  final String status;
  final String statusLabel;
  final String paymentMethod;
  final String paymentMethodName;
  final DateTime createdAt;
  final DateTime? executedAt;

  JekoTransaction({
    required this.id,
    this.jekoId,
    required this.reference,
    required this.type,
    required this.amount,
    required this.currency,
    required this.fees,
    required this.status,
    required this.statusLabel,
    required this.paymentMethod,
    required this.paymentMethodName,
    required this.createdAt,
    this.executedAt,
  });

  factory JekoTransaction.fromJson(Map<String, dynamic> json) {
    return JekoTransaction(
      id: json['id'] ?? 0,
      jekoId: json['jeko_id'],
      reference: json['reference'] ?? '',
      type: json['type'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      currency: json['currency'] ?? 'XOF',
      fees: (json['fees'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      statusLabel: json['status_label'] ?? 'En attente',
      paymentMethod: json['payment_method'] ?? '',
      paymentMethodName: json['payment_method_name'] ?? '',
      createdAt: json['created_at'] != null 
          ? DateTime.parse(json['created_at']) 
          : DateTime.now(),
      executedAt: json['executed_at'] != null 
          ? DateTime.parse(json['executed_at']) 
          : null,
    );
  }

  bool get isPending => status == 'pending';
  bool get isSuccessful => status == 'success';
  bool get isFailed => ['error', 'expired', 'cancelled'].contains(status);

  String get formattedAmount => '${amount.toStringAsFixed(0)} $currency';
}

/// Résultat d'une initiation de paiement
class JekoPaymentResult {
  final bool success;
  final String? message;
  final int? transactionId;
  final String? jekoId;
  final String? redirectUrl;
  final double? amount;
  final String? paymentMethod;

  JekoPaymentResult({
    required this.success,
    this.message,
    this.transactionId,
    this.jekoId,
    this.redirectUrl,
    this.amount,
    this.paymentMethod,
  });

  factory JekoPaymentResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return JekoPaymentResult(
      success: json['success'] ?? false,
      message: json['message'],
      transactionId: data?['transaction_id'],
      jekoId: data?['jeko_id'],
      redirectUrl: data?['redirect_url'],
      amount: data?['amount']?.toDouble(),
      paymentMethod: data?['payment_method'],
    );
  }
}

/// DataSource pour les paiements JEKO
abstract class JekoPaymentRemoteDataSource {
  /// Récupérer les méthodes de paiement disponibles
  Future<List<JekoPaymentMethod>> getPaymentMethods();
  
  /// Initier une recharge de wallet
  Future<JekoPaymentResult> initiateWalletRecharge({
    required double amount,
    required String paymentMethod,
  });
  
  /// Initier le paiement d'une commande
  Future<JekoPaymentResult> initiateOrderPayment({
    required String orderId,
    required String paymentMethod,
  });
  
  /// Vérifier le statut d'une transaction
  Future<JekoTransaction> checkTransactionStatus(int transactionId);
  
  /// Récupérer l'historique des transactions
  Future<List<JekoTransaction>> getTransactionHistory({int page = 1});
  
  /// Callback après paiement réussi
  Future<JekoTransaction> paymentSuccessCallback(int transactionId);
  
  /// Callback après paiement échoué
  Future<void> paymentErrorCallback(int transactionId);
}

class JekoPaymentRemoteDataSourceImpl implements JekoPaymentRemoteDataSource {
  final ApiClient _apiClient;

  JekoPaymentRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<JekoPaymentMethod>> getPaymentMethods() async {
    try {
      final response = await _apiClient.get('jeko/payment-methods');
      
      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((e) => JekoPaymentMethod.fromJson(e)).toList();
      }
      
      return [];
    } catch (e) {
      // En cas d'erreur, retourner une liste vide plutôt que crasher
      return [];
    }
  }

  @override
  Future<JekoPaymentResult> initiateWalletRecharge({
    required double amount,
    required String paymentMethod,
  }) async {
    final response = await _apiClient.post(
      'jeko/recharge',
      data: {
        'amount': amount,
        'payment_method': paymentMethod,
      },
    );
    
    return JekoPaymentResult.fromJson(response.data);
  }

  @override
  Future<JekoPaymentResult> initiateOrderPayment({
    required String orderId,
    required String paymentMethod,
  }) async {
    final response = await _apiClient.post(
      'jeko/pay-order',
      data: {
        'order_id': orderId,
        'payment_method': paymentMethod,
      },
    );
    
    return JekoPaymentResult.fromJson(response.data);
  }

  @override
  Future<JekoTransaction> checkTransactionStatus(int transactionId) async {
    final response = await _apiClient.get('jeko/status/$transactionId');
    
    if (response.data['success'] == true) {
      return JekoTransaction.fromJson(response.data['data']);
    }
    
    throw Exception(response.data['message'] ?? 'Erreur lors de la vérification du statut');
  }

  @override
  Future<List<JekoTransaction>> getTransactionHistory({int page = 1}) async {
    final response = await _apiClient.get(
      'jeko/transactions',
      queryParameters: {'page': page},
    );
    
    if (response.data['success'] == true) {
      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((e) => JekoTransaction.fromJson(e)).toList();
    }
    
    return [];
  }

  @override
  Future<JekoTransaction> paymentSuccessCallback(int transactionId) async {
    final response = await _apiClient.get(
      'jeko/callback/success',
      queryParameters: {'transaction_id': transactionId},
    );
    
    if (response.data['success'] == true) {
      return JekoTransaction.fromJson(response.data['data']);
    }
    
    throw Exception(response.data['message'] ?? 'Erreur lors de la confirmation');
  }

  @override
  Future<void> paymentErrorCallback(int transactionId) async {
    await _apiClient.get(
      'jeko/callback/error',
      queryParameters: {'transaction_id': transactionId},
    );
  }
}
