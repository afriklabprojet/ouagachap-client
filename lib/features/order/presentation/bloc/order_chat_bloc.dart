import 'dart:async';
import 'dart:convert';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/bloc/safe_emit_mixin.dart';
import '../../../../core/services/websocket_service.dart';
import '../../data/models/order_chat_model.dart';
import '../../data/repositories/order_chat_repository.dart';

// ==================== EVENTS ====================

abstract class OrderChatEvent extends Equatable {
  const OrderChatEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrderChat extends OrderChatEvent {
  final String orderUuid;
  const LoadOrderChat(this.orderUuid);

  @override
  List<Object?> get props => [orderUuid];
}

class SendOrderMessage extends OrderChatEvent {
  final String message;
  const SendOrderMessage(this.message);

  @override
  List<Object?> get props => [message];
}

class RefreshChat extends OrderChatEvent {
  const RefreshChat();
}

class MarkMessagesRead extends OrderChatEvent {
  const MarkMessagesRead();
}

class _ChatMessageReceived extends OrderChatEvent {
  final OrderChatMessage message;
  const _ChatMessageReceived(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== STATES ====================

abstract class OrderChatState extends Equatable {
  const OrderChatState();

  @override
  List<Object?> get props => [];
}

class OrderChatInitial extends OrderChatState {
  const OrderChatInitial();
}

class OrderChatLoading extends OrderChatState {
  const OrderChatLoading();
}

class OrderChatReady extends OrderChatState {
  final OrderChat chat;
  final List<OrderChatMessage> messages;
  final bool isSending;

  const OrderChatReady({
    required this.chat,
    required this.messages,
    this.isSending = false,
  });

  OrderChatReady copyWith({
    OrderChat? chat,
    List<OrderChatMessage>? messages,
    bool? isSending,
  }) {
    return OrderChatReady(
      chat: chat ?? this.chat,
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }

  @override
  List<Object?> get props => [chat, messages, isSending];
}

class OrderChatError extends OrderChatState {
  final String message;
  const OrderChatError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== BLOC ====================

class OrderChatBloc extends Bloc<OrderChatEvent, OrderChatState>
    with SafeEmitMixin {
  final OrderChatRepository _repository;
  final WebSocketService _webSocketService;
  String? _orderUuid;
  int? _orderId;
  StreamSubscription<Map<String, dynamic>>? _wsSubscription;

  OrderChatBloc(this._repository, {required WebSocketService webSocketService})
    : _webSocketService = webSocketService,
      super(const OrderChatInitial()) {
    on<LoadOrderChat>(_onLoadChat, transformer: restartable());
    // droppable() → empêche les double envois de messages
    on<SendOrderMessage>(_onSendMessage, transformer: droppable());
    on<RefreshChat>(_onRefresh, transformer: restartable());
    on<MarkMessagesRead>(_onMarkRead, transformer: droppable());
    on<_ChatMessageReceived>(_onChatMessageReceived, transformer: droppable());
  }

  Future<void> _onLoadChat(
    LoadOrderChat event,
    Emitter<OrderChatState> emit,
  ) async {
    _orderUuid = event.orderUuid;
    emit(const OrderChatLoading());

    try {
      final chat = await _repository.getOrderChat(event.orderUuid);
      if (isClosed) return;
      _orderId = chat.orderId;
      await _repository.markAsRead(event.orderUuid);
      if (isClosed) return;
      emit(OrderChatReady(chat: chat, messages: chat.messages));
      // Démarrer l'écoute WebSocket pour les nouveaux messages
      _subscribeToWebSocket(chat.orderId);
    } catch (e) {
      if (isClosed) return;
      emit(OrderChatError(_errorMessage(e)));
    }
  }

  void _subscribeToWebSocket(int orderId) {
    _wsSubscription?.cancel();
    final channel = 'orders.$orderId';
    _webSocketService.connect().then((_) {
      if (isClosed) return;
      _webSocketService.subscribe(channel);
    });
    _wsSubscription = _webSocketService
        .on(channel, 'message.sent')
        .listen(
          (message) {
            if (isClosed) return;
            try {
              final rawData = message['data'];
              final data = rawData is String
                  ? json.decode(rawData) as Map<String, dynamic>
                  : rawData as Map<String, dynamic>;
              final msg = OrderChatMessage.fromJson(data);
              // Ignorer les messages envoyés par le client (optimiste déjà affiché)
              if (!msg.isCourier) return;
              add(_ChatMessageReceived(msg));
            } catch (e) {
              debugPrint('[OrderChat] WS parse error: $e');
            }
          },
          onError: (e) => debugPrint('[OrderChat] WS stream error: $e'),
        );
  }

  Future<void> _onChatMessageReceived(
    _ChatMessageReceived event,
    Emitter<OrderChatState> emit,
  ) async {
    final current = state;
    if (current is! OrderChatReady) return;
    // Éviter les doublons
    if (current.messages.any((m) => m.id == event.message.id)) return;
    emit(current.copyWith(messages: [...current.messages, event.message]));
    // Marquer comme lu immédiatement
    if (_orderUuid != null) {
      try {
        await _repository.markAsRead(_orderUuid!);
      } catch (e) {
        debugPrint('[OrderChat] markAsRead after WS message error: $e');
      }
    }
  }

  Future<void> _onSendMessage(
    SendOrderMessage event,
    Emitter<OrderChatState> emit,
  ) async {
    if (_orderUuid == null || state is! OrderChatReady) return;
    final current = state as OrderChatReady;

    // Ajouter le message localement pour feedback instantané
    final localMsg = OrderChatMessage.local(
      message: event.message,
      senderName: current.chat.clientName,
    );
    emit(
      current.copyWith(
        messages: [...current.messages, localMsg],
        isSending: true,
      ),
    );

    try {
      final sent = await _repository.sendMessage(_orderUuid!, event.message);
      if (isClosed) return;
      // Relire l'état actuel car il a pu changer pendant l'attente
      final latestState = state;
      if (latestState is! OrderChatReady) return;
      // Remplacer le message local par le message confirmé
      final updated =
          latestState.messages.where((m) => m.id != localMsg.id).toList()
            ..add(sent);
      emit(latestState.copyWith(messages: updated, isSending: false));
    } catch (e) {
      if (isClosed) return;
      // Relire l'état actuel pour retirer le message local
      final latestState = state;
      if (latestState is! OrderChatReady) return;
      final reverted = latestState.messages
          .where((m) => m.id != localMsg.id)
          .toList();
      emit(latestState.copyWith(messages: reverted, isSending: false));
    }
  }

  Future<void> _onRefresh(
    RefreshChat event,
    Emitter<OrderChatState> emit,
  ) async {
    if (_orderUuid == null || state is! OrderChatReady) return;

    try {
      final chat = await _repository.getOrderChat(_orderUuid!);
      if (isClosed) return;
      await _repository.markAsRead(_orderUuid!);
      if (isClosed) return;
      // Relire l'état actuel
      final latestState = state;
      if (latestState is! OrderChatReady) return;
      emit(latestState.copyWith(chat: chat, messages: chat.messages));
    } catch (e) {
      debugPrint('Silent refresh error: $e');
    }
  }

  Future<void> _onMarkRead(
    MarkMessagesRead event,
    Emitter<OrderChatState> emit,
  ) async {
    if (_orderUuid == null) return;
    try {
      await _repository.markAsRead(_orderUuid!);
    } catch (e) {
      debugPrint('[OrderChat] markAsRead error: $e');
    }
  }

  String _errorMessage(dynamic e) {
    if (e is Exception) {
      return e.toString().replaceFirst('Exception: ', '');
    }
    return 'Une erreur est survenue';
  }

  @override
  Future<void> close() {
    _wsSubscription?.cancel();
    if (_orderId != null) {
      _webSocketService.unsubscribe('orders.$_orderId');
    }
    return super.close();
  }
}
