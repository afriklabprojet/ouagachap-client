import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

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

class OrderChatBloc extends Bloc<OrderChatEvent, OrderChatState> {
  final OrderChatRepository _repository;
  String? _orderUuid;

  OrderChatBloc(this._repository) : super(const OrderChatInitial()) {
    on<LoadOrderChat>(_onLoadChat);
    on<SendOrderMessage>(_onSendMessage);
    on<RefreshChat>(_onRefresh);
    on<MarkMessagesRead>(_onMarkRead);
  }

  Future<void> _onLoadChat(
    LoadOrderChat event,
    Emitter<OrderChatState> emit,
  ) async {
    _orderUuid = event.orderUuid;
    emit(const OrderChatLoading());

    try {
      final chat = await _repository.getOrderChat(event.orderUuid);
      await _repository.markAsRead(event.orderUuid);
      emit(OrderChatReady(chat: chat, messages: chat.messages));
    } catch (e) {
      emit(OrderChatError(_errorMessage(e)));
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
    emit(current.copyWith(
      messages: [...current.messages, localMsg],
      isSending: true,
    ));

    try {
      final sent = await _repository.sendMessage(_orderUuid!, event.message);
      // Remplacer le message local par le message confirmé
      final updated = current.messages
          .where((m) => m.id != localMsg.id)
          .toList()
        ..add(sent);
      emit(current.copyWith(messages: updated, isSending: false));
    } catch (e) {
      // Retirer le message local en cas d'erreur
      final reverted = current.messages
          .where((m) => m.id != localMsg.id)
          .toList();
      emit(current.copyWith(messages: reverted, isSending: false));
    }
  }

  Future<void> _onRefresh(
    RefreshChat event,
    Emitter<OrderChatState> emit,
  ) async {
    if (_orderUuid == null || state is! OrderChatReady) return;
    final current = state as OrderChatReady;

    try {
      final chat = await _repository.getOrderChat(_orderUuid!);
      await _repository.markAsRead(_orderUuid!);
      emit(current.copyWith(chat: chat, messages: chat.messages));
    } catch (_) {
      // Ignorer l'erreur de refresh silencieux
    }
  }

  Future<void> _onMarkRead(
    MarkMessagesRead event,
    Emitter<OrderChatState> emit,
  ) async {
    if (_orderUuid == null) return;
    try {
      await _repository.markAsRead(_orderUuid!);
    } catch (_) {}
  }

  String _errorMessage(dynamic e) {
    if (e is Exception) {
      return e.toString().replaceFirst('Exception: ', '');
    }
    return 'Une erreur est survenue';
  }
}
