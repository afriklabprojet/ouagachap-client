import 'package:flutter/foundation.dart';

/// Modèle pour le chat entre client et coursier pour une commande
class OrderChat {
  final int orderId;
  final String orderUuid;
  final int clientId;
  final String clientName;
  final String? clientPhone;
  final String? clientPhoto;
  final int courierId;
  final String courierName;
  final String? courierPhone;
  final String? courierPhoto;
  final List<OrderChatMessage> messages;
  final int unreadCount;
  final DateTime? lastMessageAt;

  OrderChat({
    required this.orderId,
    required this.orderUuid,
    required this.clientId,
    required this.clientName,
    this.clientPhone,
    this.clientPhoto,
    required this.courierId,
    required this.courierName,
    this.courierPhone,
    this.courierPhoto,
    this.messages = const [],
    this.unreadCount = 0,
    this.lastMessageAt,
  });

  factory OrderChat.fromJson(Map<String, dynamic> json) {
    List<OrderChatMessage> messages = [];
    if (json['messages'] != null) {
      messages = (json['messages'] as List)
          .map((m) => OrderChatMessage.fromJson(m as Map<String, dynamic>))
          .toList();
    }

    return OrderChat(
      orderId: _parseInt(json['order_id'] ?? json['id']),
      orderUuid:
          json['order_uuid']?.toString() ?? json['uuid']?.toString() ?? '',
      clientId: _parseInt(json['client_id']),
      clientName: json['client_name']?.toString() ?? 'Client',
      clientPhone: json['client_phone']?.toString(),
      clientPhoto: json['client_photo']?.toString(),
      courierId: _parseInt(json['courier_id']),
      courierName: json['courier_name']?.toString() ?? 'Coursier',
      courierPhone: json['courier_phone']?.toString(),
      courierPhoto: json['courier_photo']?.toString(),
      messages: messages,
      unreadCount: _parseInt(json['unread_count'], defaultValue: 0),
      lastMessageAt: json['last_message_at'] != null
          ? _parseDateTime(json['last_message_at'])
          : null,
    );
  }

  static int _parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? defaultValue;
    if (value is double) return value.toInt();
    return defaultValue;
  }

  static DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        debugPrint('[OrderChat] Invalid date format, using now(): $e');
        return DateTime.now();
      }
    }
    return DateTime.now();
  }
}

/// Modèle pour un message de chat
class OrderChatMessage {
  final int id;
  final int orderId;
  final int senderId;
  final String senderType;
  final String senderName;
  final String? message;
  final String? imageUrl;
  final bool isRead;
  final DateTime createdAt;
  final bool isCourier;

  OrderChatMessage({
    required this.id,
    required this.orderId,
    required this.senderId,
    required this.senderType,
    required this.senderName,
    this.message,
    this.imageUrl,
    this.isRead = false,
    required this.createdAt,
    this.isCourier = false,
  });

  factory OrderChatMessage.fromJson(Map<String, dynamic> json) {
    return OrderChatMessage(
      id: OrderChat._parseInt(json['id']),
      orderId: OrderChat._parseInt(json['order_id']),
      senderId: OrderChat._parseInt(json['sender_id']),
      senderType: json['sender_type']?.toString() ?? 'client',
      senderName: json['sender_name']?.toString() ?? '',
      message: json['message']?.toString(),
      imageUrl: json['image_url']?.toString(),
      isRead: json['is_read'] == true,
      createdAt: json['created_at'] != null
          ? OrderChat._parseDateTime(json['created_at'])
          : DateTime.now(),
      isCourier: json['is_courier'] == true || json['sender_type'] == 'courier',
    );
  }

  /// Message temporaire local (avant confirmation serveur)
  factory OrderChatMessage.local({
    required String message,
    required String senderName,
  }) {
    return OrderChatMessage(
      id: -DateTime.now().millisecondsSinceEpoch,
      orderId: 0,
      senderId: 0,
      senderType: 'client',
      senderName: senderName,
      message: message,
      createdAt: DateTime.now(),
      isCourier: false,
    );
  }
}
