import 'package:equatable/equatable.dart';

/// Événements pour le suivi en temps réel
abstract class LiveTrackingEvent extends Equatable {
  const LiveTrackingEvent();

  @override
  List<Object?> get props => [];
}

/// Démarrer le suivi d'une commande
class StartTracking extends LiveTrackingEvent {
  final int orderId;
  final String trackingCode;

  const StartTracking({
    required this.orderId,
    required this.trackingCode,
  });

  @override
  List<Object?> get props => [orderId, trackingCode];
}

/// Arrêter le suivi
class StopTracking extends LiveTrackingEvent {
  const StopTracking();
}

/// Mise à jour de la position du coursier
class CourierLocationUpdated extends LiveTrackingEvent {
  final double latitude;
  final double longitude;
  final double? heading;
  final double? speed;
  final DateTime timestamp;

  const CourierLocationUpdated({
    required this.latitude,
    required this.longitude,
    this.heading,
    this.speed,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [latitude, longitude, heading, speed, timestamp];
}

/// Mise à jour du statut de la commande
class OrderStatusUpdated extends LiveTrackingEvent {
  final String status;
  final String? message;
  final DateTime timestamp;

  const OrderStatusUpdated({
    required this.status,
    this.message,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [status, message, timestamp];
}

/// Mise à jour de l'ETA
class ETAUpdated extends LiveTrackingEvent {
  final int estimatedMinutes;
  final double distanceKm;

  const ETAUpdated({
    required this.estimatedMinutes,
    required this.distanceKm,
  });

  @override
  List<Object?> get props => [estimatedMinutes, distanceKm];
}

/// Erreur de connexion
class TrackingConnectionError extends LiveTrackingEvent {
  final String message;

  const TrackingConnectionError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Reconnexion en cours
class TrackingReconnecting extends LiveTrackingEvent {
  const TrackingReconnecting();
}

/// Connexion établie
class TrackingConnected extends LiveTrackingEvent {
  const TrackingConnected();
}
