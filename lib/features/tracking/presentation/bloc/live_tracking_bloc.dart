import 'dart:async';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/websocket_service.dart';
import 'live_tracking_event.dart';
import 'live_tracking_state.dart';

/// BLoC pour le suivi en temps réel des commandes
class LiveTrackingBloc extends Bloc<LiveTrackingEvent, LiveTrackingState> {
  final WebSocketService _webSocketService;
  StreamSubscription? _messageSubscription;

  LiveTrackingBloc({
    required WebSocketService webSocketService,
  })  : _webSocketService = webSocketService,
        super(const LiveTrackingState()) {
    on<StartTracking>(_onStartTracking);
    on<StopTracking>(_onStopTracking);
    on<CourierLocationUpdated>(_onCourierLocationUpdated);
    on<OrderStatusUpdated>(_onOrderStatusUpdated);
    on<ETAUpdated>(_onETAUpdated);
    on<TrackingConnectionError>(_onConnectionError);
    on<TrackingReconnecting>(_onReconnecting);
    on<TrackingConnected>(_onConnected);
  }

  Future<void> _onStartTracking(
    StartTracking event,
    Emitter<LiveTrackingState> emit,
  ) async {
    emit(state.copyWith(
      connectionStatus: TrackingConnectionStatus.connecting,
      orderId: event.orderId,
      trackingCode: event.trackingCode,
      statusMessage: 'Connexion en cours...',
    ));

    try {
      // Connecter au WebSocket
      await _webSocketService.connect();

      // S'abonner au canal de la commande
      final channel = 'order.${event.orderId}';
      _webSocketService.subscribe(channel);

      // Écouter les messages
      _messageSubscription?.cancel();
      _messageSubscription = _webSocketService.messages.listen(
        (message) => _handleWebSocketMessage(message),
        onError: (error) {
          add(TrackingConnectionError(error.toString()));
        },
      );

      // Vérifier si connecté
      if (_webSocketService.isConnected) {
        add(const TrackingConnected());
      }
    } catch (e) {
      emit(state.copyWith(
        connectionStatus: TrackingConnectionStatus.error,
        errorMessage: 'Erreur de connexion: $e',
      ));
    }
  }

  void _handleWebSocketMessage(Map<String, dynamic> message) {
    final event = message['event'] as String?;
    final channel = message['channel'] as String?;
    
    // Vérifier que c'est pour notre commande
    if (channel != 'order.${state.orderId}') return;

    try {
      final data = message['data'] is String
          ? json.decode(message['data'])
          : message['data'];

      switch (event) {
        // Events du backend Laravel (via broadcastAs)
        case 'location.updated':
        case 'courier.location.updated':
        case 'App\\Events\\CourierLocationUpdated':
          _handleLocationUpdate(data);
          break;
        case 'tracking.update':
        case 'App\\Events\\OrderTrackingUpdate':
          _handleTrackingUpdate(data);
          break;
        case 'status.changed':
        case 'order.status.updated':
        case 'App\\Events\\OrderStatusChanged':
          _handleStatusUpdate(data);
          break;
      }
    } catch (e) {
      print('LiveTrackingBloc: Error parsing message: $e');
    }
  }

  void _handleLocationUpdate(Map<String, dynamic> data) {
    add(CourierLocationUpdated(
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      heading: data['heading'] != null ? (data['heading'] as num).toDouble() : null,
      speed: data['speed'] != null ? (data['speed'] as num).toDouble() : null,
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
    ));
  }

  /// Gère les updates de tracking complet (position + ETA)
  void _handleTrackingUpdate(Map<String, dynamic> data) {
    // Extraire les données du courier
    final courier = data['courier'] as Map<String, dynamic>?;
    if (courier != null) {
      final latitude = courier['latitude'] as num?;
      final longitude = courier['longitude'] as num?;
      
      if (latitude != null && longitude != null) {
        add(CourierLocationUpdated(
          latitude: latitude.toDouble(),
          longitude: longitude.toDouble(),
          timestamp: data['timestamp'] != null
              ? DateTime.parse(data['timestamp'])
              : DateTime.now(),
        ));
      }
    }
    
    // Extraire l'ETA et la distance
    final etaMinutes = data['eta_minutes'] as int?;
    final distanceRemaining = data['distance_remaining'] as num?;
    
    if (etaMinutes != null) {
      add(ETAUpdated(
        estimatedMinutes: etaMinutes,
        distanceKm: distanceRemaining?.toDouble() ?? 0.0,
      ));
    }
    
    // Mettre à jour le statut si présent
    final orderStatus = data['order_status'] as String?;
    if (orderStatus != null) {
      add(OrderStatusUpdated(
        status: orderStatus,
        timestamp: DateTime.now(),
      ));
    }
  }

  void _handleStatusUpdate(Map<String, dynamic> data) {
    add(OrderStatusUpdated(
      status: data['status'] as String,
      message: data['message'] as String?,
      timestamp: data['timestamp'] != null
          ? DateTime.parse(data['timestamp'])
          : DateTime.now(),
    ));
  }

  void _handleETAUpdate(Map<String, dynamic> data) {
    add(ETAUpdated(
      estimatedMinutes: data['estimated_minutes'] as int,
      distanceKm: (data['distance_km'] as num).toDouble(),
    ));
  }

  void _onCourierLocationUpdated(
    CourierLocationUpdated event,
    Emitter<LiveTrackingState> emit,
  ) {
    // Ajouter au historique de route
    final newPoint = LatLngPoint(
      latitude: event.latitude,
      longitude: event.longitude,
      timestamp: event.timestamp,
    );
    
    final updatedHistory = [...state.routeHistory, newPoint];
    // Garder seulement les 100 derniers points
    final trimmedHistory = updatedHistory.length > 100
        ? updatedHistory.sublist(updatedHistory.length - 100)
        : updatedHistory;

    emit(state.copyWith(
      courierLatitude: event.latitude,
      courierLongitude: event.longitude,
      courierHeading: event.heading,
      courierSpeed: event.speed,
      lastLocationUpdate: event.timestamp,
      routeHistory: trimmedHistory,
    ));
  }

  void _onOrderStatusUpdated(
    OrderStatusUpdated event,
    Emitter<LiveTrackingState> emit,
  ) {
    emit(state.copyWith(
      orderStatus: event.status,
      statusMessage: event.message ?? _getStatusMessage(event.status),
    ));
  }

  String _getStatusMessage(String status) {
    switch (status) {
      case 'pending':
        return 'En attente de prise en charge';
      case 'accepted':
        return 'Commande acceptée';
      case 'picking_up':
        return 'Le coursier se dirige vers le point de récupération';
      case 'picked_up':
        return 'Colis récupéré';
      case 'delivering':
        return 'Livraison en cours';
      case 'delivered':
        return 'Livré avec succès !';
      case 'cancelled':
        return 'Commande annulée';
      default:
        return status;
    }
  }

  void _onETAUpdated(
    ETAUpdated event,
    Emitter<LiveTrackingState> emit,
  ) {
    emit(state.copyWith(
      estimatedMinutes: event.estimatedMinutes,
      distanceKm: event.distanceKm,
    ));
  }

  void _onConnectionError(
    TrackingConnectionError event,
    Emitter<LiveTrackingState> emit,
  ) {
    emit(state.copyWith(
      connectionStatus: TrackingConnectionStatus.error,
      errorMessage: event.message,
    ));
  }

  void _onReconnecting(
    TrackingReconnecting event,
    Emitter<LiveTrackingState> emit,
  ) {
    emit(state.copyWith(
      connectionStatus: TrackingConnectionStatus.reconnecting,
      statusMessage: 'Reconnexion...',
    ));
  }

  void _onConnected(
    TrackingConnected event,
    Emitter<LiveTrackingState> emit,
  ) {
    emit(state.copyWith(
      connectionStatus: TrackingConnectionStatus.connected,
      statusMessage: 'Suivi en direct',
      errorMessage: null,
    ));
  }

  Future<void> _onStopTracking(
    StopTracking event,
    Emitter<LiveTrackingState> emit,
  ) async {
    // Se désabonner du canal
    if (state.orderId != null) {
      _webSocketService.unsubscribe('order.${state.orderId}');
    }

    _messageSubscription?.cancel();
    _messageSubscription = null;

    emit(const LiveTrackingState());
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    return super.close();
  }
}
