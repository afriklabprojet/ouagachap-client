import 'dart:async';
import 'dart:convert';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/bloc/safe_emit_mixin.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/services/websocket_service.dart';
import 'live_tracking_event.dart';
import 'live_tracking_state.dart';

/// BLoC pour le suivi en temps réel des commandes
class LiveTrackingBloc extends Bloc<LiveTrackingEvent, LiveTrackingState>
    with SafeEmitMixin {
  final WebSocketService _webSocketService;
  final ApiClient _apiClient;
  StreamSubscription? _messageSubscription;

  LiveTrackingBloc({
    required WebSocketService webSocketService,
    required ApiClient apiClient,
  }) : _webSocketService = webSocketService,
       _apiClient = apiClient,
       super(const LiveTrackingState()) {
    // droppable() → empêche le double StartTracking (deux connexions WebSocket)
    on<StartTracking>(_onStartTracking, transformer: droppable());
    on<StopTracking>(_onStopTracking);
    on<CourierLocationUpdated>(_onCourierLocationUpdated);
    on<OrderStatusUpdated>(_onOrderStatusUpdated);
    on<ETAUpdated>(_onETAUpdated);
    on<TrackingConnectionError>(_onConnectionError);
    on<TrackingReconnecting>(_onReconnecting);
    on<TrackingConnected>(_onConnected);
    on<ReconnectTracking>(_onReconnectTracking);
  }

  Future<void> _onStartTracking(
    StartTracking event,
    Emitter<LiveTrackingState> emit,
  ) async {
    emit(
      state.copyWith(
        connectionStatus: TrackingConnectionStatus.connecting,
        orderId: event.orderId,
        trackingCode: event.trackingCode,
        statusMessage: 'Connexion en cours...',
      ),
    );

    try {
      // Connecter au WebSocket
      await _webSocketService.connect();
      if (isClosed) return;

      // S'abonner au canal privé de la commande (nécessite auth Pusher)
      final channel = 'private-order.${event.orderId}';
      await _subscribePrivateChannel(channel);

      // Écouter les messages
      _messageSubscription?.cancel();
      _messageSubscription = _webSocketService.messages.listen(
        (message) => _handleWebSocketMessage(message),
        onError: (error) {
          if (!isClosed) {
            add(TrackingConnectionError(error.toString()));
          }
        },
      );

      // Vérifier si connecté
      if (_webSocketService.isConnected && !isClosed) {
        add(const TrackingConnected());
      }
    } catch (e) {
      emit(
        state.copyWith(
          connectionStatus: TrackingConnectionStatus.error,
          errorMessage: 'Erreur de connexion: $e',
        ),
      );
    }
  }

  /// Authentifie et souscrit à un canal privé Pusher/Reverb.
  ///
  /// Flux : obtenir socket_id → POST /broadcasting/auth → subscribePrivate.
  /// Si l'auth échoue (réseau ou 403), fallback sur subscribe() public.
  Future<void> _subscribePrivateChannel(String channel) async {
    // Attendre que le socket_id soit disponible (handshake asynchrone)
    String? socketId;
    for (int i = 0; i < 15; i++) {
      socketId = _webSocketService.socketId;
      if (socketId != null) break;
      await Future.delayed(const Duration(milliseconds: 200));
    }

    if (socketId == null) {
      // Pas encore connecté — subscribe sans auth (sera rejeté par Reverb
      // mais le canal sera queued pour re-subscribe automatique)
      _webSocketService.subscribe(channel);
      return;
    }

    try {
      final response = await _apiClient.post(
        'broadcasting/auth',
        data: {'socket_id': socketId, 'channel_name': channel},
      );
      final authToken = (response.data as Map?)?['auth'] as String?;
      if (authToken != null) {
        await _webSocketService.subscribePrivate(channel, authToken);
      } else {
        _webSocketService.subscribe(channel);
      }
    } catch (_) {
      // Fallback : tenter sans token (Reverb en mode permissif, ou test local)
      _webSocketService.subscribe(channel);
    }
  }

  void _handleWebSocketMessage(Map<String, dynamic> message) {
    // Vérifier que le BLoC n'est pas fermé avant d'ajouter des événements
    if (isClosed) return;

    final event = message['event'] as String?;
    final channel = message['channel'] as String?;

    // Vérifier que c'est pour notre commande
    if (channel != 'private-order.${state.orderId}') return;

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
      debugPrint('LiveTrackingBloc: Error parsing message: $e');
    }
  }

  void _handleLocationUpdate(Map<String, dynamic> data) {
    if (isClosed) return;
    final lat = (data['latitude'] as num?)?.toDouble();
    final lng = (data['longitude'] as num?)?.toDouble();
    if (!_isValidPosition(lat, lng)) {
      debugPrint('[Tracking] Position invalide ignorée: lat=$lat, lng=$lng');
      return;
    }
    add(
      CourierLocationUpdated(
        latitude: lat!,
        longitude: lng!,
        heading: data['heading'] != null
            ? (data['heading'] as num).toDouble()
            : null,
        speed: data['speed'] != null ? (data['speed'] as num).toDouble() : null,
        timestamp: data['timestamp'] != null
            ? DateTime.parse(data['timestamp'])
            : DateTime.now(),
      ),
    );
  }

  /// Gère les updates de tracking complet (position + ETA)
  void _handleTrackingUpdate(Map<String, dynamic> data) {
    if (isClosed) return;
    // Extraire les données du courier
    final courier = data['courier'] as Map<String, dynamic>?;
    if (courier != null) {
      final latitude = courier['latitude'] as num?;
      final longitude = courier['longitude'] as num?;

      if (latitude != null && longitude != null) {
        if (!_isValidPosition(latitude.toDouble(), longitude.toDouble())) {
          debugPrint(
            '[Tracking] Position invalide ignorée (tracking update): lat=$latitude, lng=$longitude',
          );
        } else {
          add(
            CourierLocationUpdated(
              latitude: latitude.toDouble(),
              longitude: longitude.toDouble(),
              timestamp: courier['timestamp'] != null
                  ? DateTime.parse(courier['timestamp'] as String)
                  : (data['updated_at'] != null
                        ? DateTime.parse(data['updated_at'] as String)
                        : DateTime.now()),
            ),
          );
        }
      }
    }

    // Extraire l'ETA et la distance
    final etaMinutes = data['eta_minutes'] as int?;
    final distanceRemaining = data['distance_remaining'] as num?;

    if (etaMinutes != null) {
      add(
        ETAUpdated(
          estimatedMinutes: etaMinutes,
          distanceKm: distanceRemaining?.toDouble() ?? 0.0,
        ),
      );
    }

    // Mettre à jour le statut si présent
    final orderStatus = data['order_status'] as String?;
    if (orderStatus != null) {
      add(OrderStatusUpdated(status: orderStatus, timestamp: DateTime.now()));
    }
  }

  void _handleStatusUpdate(Map<String, dynamic> data) {
    if (isClosed) return;
    add(
      OrderStatusUpdated(
        status: data['status'] as String,
        message: data['message'] as String?,
        timestamp: data['timestamp'] != null
            ? DateTime.parse(data['timestamp'])
            : DateTime.now(),
      ),
    );
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

    emit(
      state.copyWith(
        courierLatitude: event.latitude,
        courierLongitude: event.longitude,
        courierHeading: event.heading,
        courierSpeed: event.speed,
        lastLocationUpdate: event.timestamp,
        routeHistory: trimmedHistory,
      ),
    );
  }

  void _onOrderStatusUpdated(
    OrderStatusUpdated event,
    Emitter<LiveTrackingState> emit,
  ) {
    emit(
      state.copyWith(
        orderStatus: event.status,
        statusMessage: event.message ?? _getStatusMessage(event.status),
      ),
    );
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

  /// Valide qu'une paire (lat, lng) est dans les plages attendues.
  ///
  /// Rejette silencieusement les positions null, hors plage (lat ∉ [-90,90] /
  /// lng ∉ [-180,180]) et les coordonnées (0,0) qui indiquent un bug backend.
  bool _isValidPosition(double? lat, double? lng) {
    if (lat == null || lng == null) return false;
    if (lat < -90 || lat > 90) return false;
    if (lng < -180 || lng > 180) return false;
    if (lat == 0.0 && lng == 0.0) {
      return false; // coordonnées nulles = bug backend
    }
    return true;
  }

  void _onETAUpdated(ETAUpdated event, Emitter<LiveTrackingState> emit) {
    emit(
      state.copyWith(
        estimatedMinutes: event.estimatedMinutes,
        distanceKm: event.distanceKm,
      ),
    );
  }

  void _onConnectionError(
    TrackingConnectionError event,
    Emitter<LiveTrackingState> emit,
  ) {
    emit(
      state.copyWith(
        connectionStatus: TrackingConnectionStatus.error,
        errorMessage: event.message,
      ),
    );
  }

  void _onReconnecting(
    TrackingReconnecting event,
    Emitter<LiveTrackingState> emit,
  ) {
    emit(
      state.copyWith(
        connectionStatus: TrackingConnectionStatus.reconnecting,
        statusMessage: 'Reconnexion...',
      ),
    );
  }

  void _onConnected(TrackingConnected event, Emitter<LiveTrackingState> emit) {
    emit(
      state.copyWith(
        connectionStatus: TrackingConnectionStatus.connected,
        statusMessage: 'Suivi en direct',
        errorMessage: null,
      ),
    );
  }

  /// Reconnecte le WebSocket quand l'app revient au premier plan.
  /// Appelé par le WidgetsBindingObserver de live_tracking_page.
  Future<void> _onReconnectTracking(
    ReconnectTracking event,
    Emitter<LiveTrackingState> emit,
  ) async {
    if (_webSocketService.isConnected) return;
    if (state.orderId == null || state.trackingCode == null) return;
    add(
      StartTracking(orderId: state.orderId!, trackingCode: state.trackingCode!),
    );
  }

  Future<void> _onStopTracking(
    StopTracking event,
    Emitter<LiveTrackingState> emit,
  ) async {
    // Se désabonner du canal
    if (state.orderId != null) {
      _webSocketService.unsubscribe('private-order.${state.orderId}');
    }

    _messageSubscription?.cancel();
    _messageSubscription = null;

    emit(const LiveTrackingState());
  }

  @override
  Future<void> close() {
    _messageSubscription?.cancel();
    _messageSubscription = null;
    // Désabonner du canal et déconnecter le WebSocket proprement
    if (state.orderId != null) {
      _webSocketService.unsubscribe('private-order.${state.orderId}');
    }
    return super.close();
  }
}
