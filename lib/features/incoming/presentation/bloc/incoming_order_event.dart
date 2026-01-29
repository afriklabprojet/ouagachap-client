import 'package:equatable/equatable.dart';

abstract class IncomingOrderEvent extends Equatable {
  const IncomingOrderEvent();

  @override
  List<Object?> get props => [];
}

/// Charger la liste des colis entrants
class LoadIncomingOrders extends IncomingOrderEvent {
  final String? status;

  const LoadIncomingOrders({this.status});

  @override
  List<Object?> get props => [status];
}

/// Charger les détails d'un colis
class LoadIncomingOrderDetails extends IncomingOrderEvent {
  final String orderId;

  const LoadIncomingOrderDetails(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Suivre un colis en temps réel
class TrackIncomingOrder extends IncomingOrderEvent {
  final String orderId;

  const TrackIncomingOrder(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

/// Confirmer la réception d'un colis
class ConfirmIncomingOrderReceipt extends IncomingOrderEvent {
  final String orderId;
  final String confirmationCode;

  const ConfirmIncomingOrderReceipt({
    required this.orderId,
    required this.confirmationCode,
  });

  @override
  List<Object?> get props => [orderId, confirmationCode];
}

/// Rafraîchir les colis entrants
class RefreshIncomingOrders extends IncomingOrderEvent {
  const RefreshIncomingOrders();
}
