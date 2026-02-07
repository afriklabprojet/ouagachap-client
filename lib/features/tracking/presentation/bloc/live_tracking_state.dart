import 'package:equatable/equatable.dart';

/// États de connexion
enum TrackingConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  error,
}

/// État du suivi en temps réel
class LiveTrackingState extends Equatable {
  final TrackingConnectionStatus connectionStatus;
  final int? orderId;
  final String? trackingCode;
  
  // Position du coursier
  final double? courierLatitude;
  final double? courierLongitude;
  final double? courierHeading;
  final double? courierSpeed;
  final DateTime? lastLocationUpdate;
  
  // Position de destination
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  
  // Position de récupération
  final double? pickupLatitude;
  final double? pickupLongitude;
  
  // Infos de la commande
  final String? orderStatus;
  final String? courierName;
  final String? courierPhone;
  final String? vehicleInfo;
  
  // ETA
  final int? estimatedMinutes;
  final double? distanceKm;
  
  // Messages
  final String? errorMessage;
  final String? statusMessage;
  
  // Historique des positions (pour tracer le chemin)
  final List<LatLngPoint> routeHistory;

  const LiveTrackingState({
    this.connectionStatus = TrackingConnectionStatus.disconnected,
    this.orderId,
    this.trackingCode,
    this.courierLatitude,
    this.courierLongitude,
    this.courierHeading,
    this.courierSpeed,
    this.lastLocationUpdate,
    this.deliveryLatitude,
    this.deliveryLongitude,
    this.pickupLatitude,
    this.pickupLongitude,
    this.orderStatus,
    this.courierName,
    this.courierPhone,
    this.vehicleInfo,
    this.estimatedMinutes,
    this.distanceKm,
    this.errorMessage,
    this.statusMessage,
    this.routeHistory = const [],
  });

  bool get isTracking => connectionStatus == TrackingConnectionStatus.connected;
  bool get hasCourierLocation => courierLatitude != null && courierLongitude != null;
  
  LiveTrackingState copyWith({
    TrackingConnectionStatus? connectionStatus,
    int? orderId,
    String? trackingCode,
    double? courierLatitude,
    double? courierLongitude,
    double? courierHeading,
    double? courierSpeed,
    DateTime? lastLocationUpdate,
    double? deliveryLatitude,
    double? deliveryLongitude,
    double? pickupLatitude,
    double? pickupLongitude,
    String? orderStatus,
    String? courierName,
    String? courierPhone,
    String? vehicleInfo,
    int? estimatedMinutes,
    double? distanceKm,
    String? errorMessage,
    String? statusMessage,
    List<LatLngPoint>? routeHistory,
  }) {
    return LiveTrackingState(
      connectionStatus: connectionStatus ?? this.connectionStatus,
      orderId: orderId ?? this.orderId,
      trackingCode: trackingCode ?? this.trackingCode,
      courierLatitude: courierLatitude ?? this.courierLatitude,
      courierLongitude: courierLongitude ?? this.courierLongitude,
      courierHeading: courierHeading ?? this.courierHeading,
      courierSpeed: courierSpeed ?? this.courierSpeed,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
      deliveryLatitude: deliveryLatitude ?? this.deliveryLatitude,
      deliveryLongitude: deliveryLongitude ?? this.deliveryLongitude,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      orderStatus: orderStatus ?? this.orderStatus,
      courierName: courierName ?? this.courierName,
      courierPhone: courierPhone ?? this.courierPhone,
      vehicleInfo: vehicleInfo ?? this.vehicleInfo,
      estimatedMinutes: estimatedMinutes ?? this.estimatedMinutes,
      distanceKm: distanceKm ?? this.distanceKm,
      errorMessage: errorMessage,
      statusMessage: statusMessage,
      routeHistory: routeHistory ?? this.routeHistory,
    );
  }

  @override
  List<Object?> get props => [
        connectionStatus,
        orderId,
        trackingCode,
        courierLatitude,
        courierLongitude,
        courierHeading,
        courierSpeed,
        lastLocationUpdate,
        deliveryLatitude,
        deliveryLongitude,
        pickupLatitude,
        pickupLongitude,
        orderStatus,
        courierName,
        courierPhone,
        vehicleInfo,
        estimatedMinutes,
        distanceKm,
        errorMessage,
        statusMessage,
        routeHistory,
      ];
}

/// Point de coordonnées avec timestamp
class LatLngPoint extends Equatable {
  final double latitude;
  final double longitude;
  final DateTime timestamp;

  const LatLngPoint({
    required this.latitude,
    required this.longitude,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [latitude, longitude, timestamp];
}
