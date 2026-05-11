import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/status.dart' as status;

/// Service de connexion WebSocket pour le suivi en temps réel.
/// Compatible avec Laravel Reverb/Pusher.
///
/// **Stratégie de reconnexion** : Exponential backoff avec jitter aléatoire.
/// Pas de limite sur le nombre de tentatives — sur 3G instable,
/// couper après 5 essais (45s) perd le suivi en temps réel définitivement.
/// Le backoff est plafonné à 60s pour ne pas attendre trop longtemps.
class WebSocketService {
  WebSocketChannel? _channel;
  StreamController<Map<String, dynamic>>? _messageController;
  Timer? _pingTimer;
  Timer? _reconnectTimer;

  bool _isConnected = false;
  bool _shouldReconnect = true;
  int _reconnectAttempts = 0;

  /// Délai initial de reconnexion
  static const Duration _baseReconnectDelay = Duration(seconds: 2);

  /// Délai maximum de reconnexion (plafonné)
  static const Duration _maxReconnectDelay = Duration(seconds: 60);

  /// Intervalle de ping pour maintenir la connexion alive
  static const Duration _pingInterval = Duration(seconds: 30);

  final String _baseUrl;
  final String _appKey;
  String? _socketId;
  final Set<String> _subscribedChannels = {};

  WebSocketService({required String baseUrl, required String appKey})
    : _baseUrl = baseUrl,
      _appKey = appKey;

  /// Stream des messages reçus
  Stream<Map<String, dynamic>> get messages {
    _messageController ??= StreamController<Map<String, dynamic>>.broadcast();
    return _messageController!.stream;
  }

  bool get isConnected => _isConnected;
  String? get socketId => _socketId;

  /// Connecter au serveur WebSocket
  Future<void> connect() async {
    if (_isConnected) return;

    try {
      final wsUrl = _buildWebSocketUrl();
      debugPrint('WebSocket: Connecting to $wsUrl');

      _channel = WebSocketChannel.connect(Uri.parse(wsUrl));

      _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: false,
      );

      _startPingTimer();
      _reconnectAttempts = 0;
    } catch (e) {
      debugPrint('WebSocket: Connection error: $e');
      _scheduleReconnect();
    }
  }

  String _buildWebSocketUrl() {
    // Format pour Laravel Reverb
    final uri = Uri.parse(_baseUrl);
    final wsScheme = uri.scheme == 'https' ? 'wss' : 'ws';
    return '$wsScheme://${uri.host}:${uri.port}/app/$_appKey?protocol=7&client=flutter&version=1.0';
  }

  void _handleMessage(dynamic data) {
    try {
      final message = json.decode(data as String) as Map<String, dynamic>;
      final event = message['event'] as String?;

      debugPrint('WebSocket: Received event: $event');

      switch (event) {
        case 'pusher:connection_established':
          _handleConnectionEstablished(message);
          break;
        case 'pusher:ping':
          _sendPong();
          break;
        case 'pusher:pong':
          // Pong reçu, connexion active
          break;
        case 'pusher_internal:subscription_succeeded':
          debugPrint('WebSocket: Subscription succeeded');
          break;
        case 'pusher:error':
          debugPrint('WebSocket: Error: ${message['data']}');
          break;
        default:
          // Événement de l'application
          _messageController?.add(message);
      }
    } catch (e) {
      debugPrint('WebSocket: Error parsing message: $e');
    }
  }

  void _handleConnectionEstablished(Map<String, dynamic> message) {
    try {
      final data = json.decode(message['data'] as String);
      _socketId = data['socket_id'] as String?;
      _isConnected = true;
      _reconnectAttempts = 0; // Reset après connexion réussie
      debugPrint('WebSocket: Connected with socket_id: $_socketId');

      // Ré-abonner aux channels précédents
      for (final channel in _subscribedChannels) {
        _sendSubscribe(channel);
      }
    } catch (e) {
      debugPrint('WebSocket: Error handling connection: $e');
    }
  }

  void _handleError(dynamic error) {
    debugPrint('WebSocket: Error: $error');
    _isConnected = false;
    _scheduleReconnect();
  }

  void _handleDisconnect() {
    debugPrint('WebSocket: Disconnected');
    _isConnected = false;
    _socketId = null;
    _pingTimer?.cancel();

    if (_shouldReconnect) {
      _scheduleReconnect();
    }
  }

  /// Nombre maximum de tentatives de reconnexion avant abandon.
  static const int _maxReconnectAttempts = 15;

  /// Planifie une reconnexion avec exponential backoff + jitter.
  ///
  /// Formule : min(baseDelay * 2^attempts, maxDelay) + jitter aléatoire
  /// Le jitter évite que tous les clients se reconnectent en même temps
  /// après une panne serveur (thundering herd problem).
  void _scheduleReconnect() {
    if (!_shouldReconnect) return;

    _reconnectTimer?.cancel();
    _reconnectAttempts++;

    // Circuit breaker : abandon après trop de tentatives
    if (_reconnectAttempts > _maxReconnectAttempts) {
      debugPrint(
        'WebSocket: Max reconnect attempts reached ($_maxReconnectAttempts). Giving up.',
      );
      _shouldReconnect = false;
      _messageController?.add({'event': 'connection_failed', 'data': {}});
      return;
    }

    // Exponential backoff : 2s, 4s, 8s, 16s, 32s, 60s, 60s, 60s...
    final exponentialDelay =
        _baseReconnectDelay * pow(2, _reconnectAttempts - 1);
    final cappedDelay = exponentialDelay > _maxReconnectDelay
        ? _maxReconnectDelay
        : exponentialDelay;

    // Ajouter un jitter aléatoire de 0-30% pour éviter le thundering herd
    final jitter = Duration(
      milliseconds: (cappedDelay.inMilliseconds * Random().nextDouble() * 0.3)
          .round(),
    );
    final totalDelay = cappedDelay + jitter;

    debugPrint(
      'WebSocket: Reconnecting in ${totalDelay.inSeconds}s '
      '(attempt #$_reconnectAttempts)',
    );

    _reconnectTimer = Timer(totalDelay, () {
      connect();
    });
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(_pingInterval, (_) {
      _sendPing();
    });
  }

  void _sendPing() {
    _send({'event': 'pusher:ping', 'data': {}});
  }

  void _sendPong() {
    _send({'event': 'pusher:pong', 'data': {}});
  }

  void _send(Map<String, dynamic> data) {
    if (_channel != null && _isConnected) {
      _channel!.sink.add(json.encode(data));
    }
  }

  /// S'abonner à un canal public
  void subscribe(String channel) {
    _subscribedChannels.add(channel);
    if (_isConnected) {
      _sendSubscribe(channel);
    }
  }

  void _sendSubscribe(String channel) {
    _send({
      'event': 'pusher:subscribe',
      'data': {'channel': channel},
    });
    debugPrint('WebSocket: Subscribing to $channel');
  }

  /// Se désabonner d'un canal
  void unsubscribe(String channel) {
    _subscribedChannels.remove(channel);
    _send({
      'event': 'pusher:unsubscribe',
      'data': {'channel': channel},
    });
    debugPrint('WebSocket: Unsubscribed from $channel');
  }

  /// S'abonner à un canal privé (nécessite authentification)
  Future<void> subscribePrivate(String channel, String authToken) async {
    _subscribedChannels.add(channel);

    _send({
      'event': 'pusher:subscribe',
      'data': {'channel': channel, 'auth': authToken},
    });
    debugPrint('WebSocket: Subscribing to private channel $channel');
  }

  /// Écouter un événement spécifique sur un canal
  Stream<Map<String, dynamic>> on(String channel, String event) {
    return messages.where((message) {
      return message['channel'] == channel && message['event'] == event;
    });
  }

  /// Déconnecter
  void disconnect() {
    _shouldReconnect = false;
    _pingTimer?.cancel();
    _reconnectTimer?.cancel();
    _channel?.sink.close(status.goingAway);
    _isConnected = false;
    _socketId = null;
    _subscribedChannels.clear();
    debugPrint('WebSocket: Disconnected manually');
  }

  /// Libérer les ressources
  void dispose() {
    disconnect();
    _messageController?.close();
    _messageController = null;
  }
}
