import 'package:equatable/equatable.dart';

abstract class JekoPaymentEvent extends Equatable {
  const JekoPaymentEvent();

  @override
  List<Object?> get props => [];
}

/// Charger les méthodes de paiement
class LoadPaymentMethods extends JekoPaymentEvent {}

/// Initier une recharge de wallet
class InitiateWalletRecharge extends JekoPaymentEvent {
  final double amount;
  final String paymentMethod;

  const InitiateWalletRecharge({
    required this.amount,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [amount, paymentMethod];
}

/// Initier le paiement d'une commande
class InitiateOrderPayment extends JekoPaymentEvent {
  final String orderId;
  final String paymentMethod;

  const InitiateOrderPayment({
    required this.orderId,
    required this.paymentMethod,
  });

  @override
  List<Object?> get props => [orderId, paymentMethod];
}

/// Vérifier le statut d'une transaction
class CheckTransactionStatus extends JekoPaymentEvent {
  final int transactionId;

  const CheckTransactionStatus(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

/// Charger l'historique des transactions
class LoadTransactionHistory extends JekoPaymentEvent {
  final int page;

  const LoadTransactionHistory({this.page = 1});

  @override
  List<Object?> get props => [page];
}

/// Callback paiement réussi
class PaymentSuccessCallback extends JekoPaymentEvent {
  final int transactionId;

  const PaymentSuccessCallback(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

/// Callback paiement échoué
class PaymentErrorCallback extends JekoPaymentEvent {
  final int transactionId;

  const PaymentErrorCallback(this.transactionId);

  @override
  List<Object?> get props => [transactionId];
}

/// Réinitialiser l'état
class ResetPaymentState extends JekoPaymentEvent {}
