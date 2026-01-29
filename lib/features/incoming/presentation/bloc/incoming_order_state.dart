import 'package:equatable/equatable.dart';
import '../../domain/entities/incoming_order.dart';

abstract class IncomingOrderState extends Equatable {
  const IncomingOrderState();

  @override
  List<Object?> get props => [];
}

/// État initial
class IncomingOrderInitial extends IncomingOrderState {
  const IncomingOrderInitial();
}

/// Chargement en cours
class IncomingOrderLoading extends IncomingOrderState {
  const IncomingOrderLoading();
}

/// Liste des colis entrants chargée
class IncomingOrderLoaded extends IncomingOrderState {
  final List<IncomingOrder> orders;
  final IncomingOrderStats stats;
  final String? activeFilter;

  const IncomingOrderLoaded({
    required this.orders,
    required this.stats,
    this.activeFilter,
  });

  @override
  List<Object?> get props => [orders, stats, activeFilter];
}

/// Détails d'un colis chargés
class IncomingOrderDetailsLoaded extends IncomingOrderState {
  final IncomingOrder order;

  const IncomingOrderDetailsLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

/// Données de tracking chargées
class IncomingOrderTrackingLoaded extends IncomingOrderState {
  final String orderId;
  final String orderNumber;
  final String status;
  final String statusLabel;
  final Map<String, dynamic> courier;
  final Map<String, dynamic> destination;
  final int? etaMinutes;
  final String etaText;

  const IncomingOrderTrackingLoaded({
    required this.orderId,
    required this.orderNumber,
    required this.status,
    required this.statusLabel,
    required this.courier,
    required this.destination,
    this.etaMinutes,
    required this.etaText,
  });

  @override
  List<Object?> get props => [orderId, orderNumber, status, courier, destination, etaMinutes];
}

/// Réception confirmée avec succès
class IncomingOrderReceiptConfirmed extends IncomingOrderState {
  final String message;

  const IncomingOrderReceiptConfirmed(this.message);

  @override
  List<Object?> get props => [message];
}

/// Erreur
class IncomingOrderError extends IncomingOrderState {
  final String message;

  const IncomingOrderError(this.message);

  @override
  List<Object?> get props => [message];
}
