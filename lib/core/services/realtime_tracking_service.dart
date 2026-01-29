import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Modèle de position du coursier
class CourierPosition {
  final String courierId;
  final String courierName;
  final String? courierPhoto;
  final String? courierPhone;
  final double latitude;
  final double longitude;
  final double? speed; // km/h
  final double? heading; // Direction en degrés
  final DateTime timestamp;
  final String? vehicleType;
  final String? vehiclePlate;
  
  CourierPosition({
    required this.courierId,
    required this.courierName,
    this.courierPhoto,
    this.courierPhone,
    required this.latitude,
    required this.longitude,
    this.speed,
    this.heading,
    required this.timestamp,
    this.vehicleType,
    this.vehiclePlate,
  });
  
  LatLng get latLng => LatLng(latitude, longitude);
  
  factory CourierPosition.fromJson(Map<String, dynamic> json) {
    return CourierPosition(
      courierId: json['courier_id']?.toString() ?? '',
      courierName: json['courier_name'] ?? 'Coursier',
      courierPhoto: json['courier_photo'],
      courierPhone: json['courier_phone'],
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      speed: (json['speed'] as num?)?.toDouble(),
      heading: (json['heading'] as num?)?.toDouble(),
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      vehicleType: json['vehicle_type'],
      vehiclePlate: json['vehicle_plate'],
    );
  }
  
  Map<String, dynamic> toJson() => {
    'courier_id': courierId,
    'courier_name': courierName,
    'courier_photo': courierPhoto,
    'courier_phone': courierPhone,
    'latitude': latitude,
    'longitude': longitude,
    'speed': speed,
    'heading': heading,
    'timestamp': timestamp.toIso8601String(),
    'vehicle_type': vehicleType,
    'vehicle_plate': vehiclePlate,
  };
}

/// Modèle d'info de livraison temps réel
class DeliveryTrackingInfo {
  final String orderId;
  final String status;
  final String statusLabel;
  final CourierPosition? courierPosition;
  final LatLng pickupLocation;
  final LatLng deliveryLocation;
  final String pickupAddress;
  final String deliveryAddress;
  final double? estimatedDistance; // km
  final int? estimatedMinutes;
  final DateTime? estimatedArrival;
  final List<LatLng> routePolyline;
  final List<TrackingEvent> events;
  
  DeliveryTrackingInfo({
    required this.orderId,
    required this.status,
    required this.statusLabel,
    this.courierPosition,
    required this.pickupLocation,
    required this.deliveryLocation,
    required this.pickupAddress,
    required this.deliveryAddress,
    this.estimatedDistance,
    this.estimatedMinutes,
    this.estimatedArrival,
    this.routePolyline = const [],
    this.events = const [],
  });
  
  factory DeliveryTrackingInfo.fromJson(Map<String, dynamic> json) {
    // Parse route polyline
    List<LatLng> polyline = [];
    if (json['route_polyline'] != null) {
      final List<dynamic> points = json['route_polyline'];
      polyline = points.map((p) => LatLng(
        (p['lat'] as num).toDouble(),
        (p['lng'] as num).toDouble(),
      )).toList();
    }
    
    // Parse events
    List<TrackingEvent> events = [];
    if (json['events'] != null) {
      final List<dynamic> eventList = json['events'];
      events = eventList.map((e) => TrackingEvent.fromJson(e)).toList();
    }
    
    return DeliveryTrackingInfo(
      orderId: json['order_id']?.toString() ?? '',
      status: json['status'] ?? 'pending',
      statusLabel: json['status_label'] ?? _getStatusLabel(json['status'] ?? 'pending'),
      courierPosition: json['courier'] != null 
          ? CourierPosition.fromJson(json['courier'])
          : null,
      pickupLocation: LatLng(
        (json['pickup_latitude'] as num?)?.toDouble() ?? 0.0,
        (json['pickup_longitude'] as num?)?.toDouble() ?? 0.0,
      ),
      deliveryLocation: LatLng(
        (json['delivery_latitude'] as num?)?.toDouble() ?? 0.0,
        (json['delivery_longitude'] as num?)?.toDouble() ?? 0.0,
      ),
      pickupAddress: json['pickup_address'] ?? '',
      deliveryAddress: json['delivery_address'] ?? '',
      estimatedDistance: (json['estimated_distance'] as num?)?.toDouble(),
      estimatedMinutes: json['estimated_minutes'] as int?,
      estimatedArrival: json['estimated_arrival'] != null 
          ? DateTime.parse(json['estimated_arrival'])
          : null,
      routePolyline: polyline,
      events: events,
    );
  }
  
  static String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'assigned':
        return 'Coursier assigné';
      case 'picked_up':
        return 'Colis récupéré';
      case 'in_transit':
        return 'En cours de livraison';
      case 'delivered':
        return 'Livré';
      case 'cancelled':
        return 'Annulé';
      default:
        return status;
    }
  }
  
  /// Vérifie si le coursier est en route
  bool get isCourierOnRoute => courierPosition != null && 
      (status == 'assigned' || status == 'picked_up' || status == 'in_transit');
  
  /// Vérifie si la commande est terminée
  bool get isCompleted => status == 'delivered' || status == 'cancelled';
  
  /// Obtient le pourcentage de progression
  double get progressPercent {
    switch (status) {
      case 'pending':
        return 0.1;
      case 'assigned':
        return 0.25;
      case 'picked_up':
        return 0.5;
      case 'in_transit':
        return 0.75;
      case 'delivered':
        return 1.0;
      default:
        return 0.0;
    }
  }
}

/// Événement de suivi
class TrackingEvent {
  final String type;
  final String title;
  final String? description;
  final DateTime timestamp;
  final LatLng? location;
  
  TrackingEvent({
    required this.type,
    required this.title,
    this.description,
    required this.timestamp,
    this.location,
  });
  
  factory TrackingEvent.fromJson(Map<String, dynamic> json) {
    return TrackingEvent(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      timestamp: json['timestamp'] != null 
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      location: json['latitude'] != null && json['longitude'] != null
          ? LatLng(
              (json['latitude'] as num).toDouble(),
              (json['longitude'] as num).toDouble(),
            )
          : null,
    );
  }
}

/// Service de suivi en temps réel
class RealTimeTrackingService {
  static final RealTimeTrackingService _instance = RealTimeTrackingService._internal();
  factory RealTimeTrackingService() => _instance;
  RealTimeTrackingService._internal();
  
  // Stream controllers
  final _trackingController = StreamController<DeliveryTrackingInfo>.broadcast();
  final _courierPositionController = StreamController<CourierPosition>.broadcast();
  
  // Streams publics
  Stream<DeliveryTrackingInfo> get trackingStream => _trackingController.stream;
  Stream<CourierPosition> get courierPositionStream => _courierPositionController.stream;
  
  // Timer pour le polling
  Timer? _pollingTimer;
  String? _currentOrderId;
  bool _isTracking = false;
  
  // Intervalle de mise à jour (3 secondes pour temps réel)
  static const Duration _updateInterval = Duration(seconds: 3);
  
  /// Démarrer le suivi d'une commande
  Future<void> startTracking(String orderId) async {
    if (_isTracking && _currentOrderId == orderId) return;
    
    stopTracking();
    
    _currentOrderId = orderId;
    _isTracking = true;
    
    debugPrint('🚀 Démarrage du suivi temps réel pour la commande $orderId');
    
    // Premier chargement immédiat
    await _fetchTrackingInfo();
    
    // Polling toutes les 3 secondes
    _pollingTimer = Timer.periodic(_updateInterval, (_) {
      _fetchTrackingInfo();
    });
  }
  
  /// Arrêter le suivi
  void stopTracking() {
    _pollingTimer?.cancel();
    _pollingTimer = null;
    _currentOrderId = null;
    _isTracking = false;
    debugPrint('🛑 Arrêt du suivi temps réel');
  }
  
  /// Récupérer les infos de suivi depuis l'API
  Future<void> _fetchTrackingInfo() async {
    if (_currentOrderId == null || !_isTracking) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/orders/$_currentOrderId/tracking'),
        headers: {
          'Accept': 'application/json',
          'Authorization': token != null ? 'Bearer $token' : '',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final trackingInfo = DeliveryTrackingInfo.fromJson(data['data'] ?? data);
        
        _trackingController.add(trackingInfo);
        
        if (trackingInfo.courierPosition != null) {
          _courierPositionController.add(trackingInfo.courierPosition!);
        }
        
        debugPrint('📍 Position mise à jour: ${trackingInfo.courierPosition?.latLng}');
        
        // Arrêter le suivi si la commande est terminée
        if (trackingInfo.isCompleted) {
          debugPrint('✅ Commande terminée, arrêt du suivi');
          stopTracking();
        }
      } else {
        debugPrint('❌ Erreur API tracking: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Erreur récupération tracking: $e');
    }
  }
  
  /// Récupérer les infos de suivi une seule fois
  Future<DeliveryTrackingInfo?> getTrackingInfo(String orderId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}/orders/$orderId/tracking'),
        headers: {
          'Accept': 'application/json',
          'Authorization': token != null ? 'Bearer $token' : '',
        },
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return DeliveryTrackingInfo.fromJson(data['data'] ?? data);
      }
    } catch (e) {
      debugPrint('Erreur getTrackingInfo: $e');
    }
    return null;
  }
  
  /// Envoyer une notification au coursier
  Future<bool> sendMessageToCourier(String orderId, String message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}/orders/$orderId/message'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': token != null ? 'Bearer $token' : '',
        },
        body: json.encode({'message': message}),
      );
      
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Erreur envoi message: $e');
      return false;
    }
  }
  
  /// Nettoyer les ressources
  void dispose() {
    stopTracking();
    _trackingController.close();
    _courierPositionController.close();
  }
}
