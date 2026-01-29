import 'package:equatable/equatable.dart';

/// Modèle pour une conversation de chat support
class SupportChat extends Equatable {
  final int id;
  final String? subject;
  final String status;
  final String statusLabel;
  final LastMessage? lastMessage;
  final int unreadCount;
  final DateTime? lastMessageAt;
  final DateTime createdAt;

  const SupportChat({
    required this.id,
    this.subject,
    required this.status,
    required this.statusLabel,
    this.lastMessage,
    this.unreadCount = 0,
    this.lastMessageAt,
    required this.createdAt,
  });

  bool get isOpen => status == 'open';
  bool get hasUnread => unreadCount > 0;

  factory SupportChat.fromJson(Map<String, dynamic> json) {
    return SupportChat(
      id: json['id'] ?? 0,
      subject: json['subject'],
      status: json['status'] ?? 'open',
      statusLabel: json['status_label'] ?? 'Ouverte',
      lastMessage: json['last_message'] != null
          ? LastMessage.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      lastMessageAt: json['last_message_at'] != null
          ? DateTime.parse(json['last_message_at'])
          : null,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, subject, status, unreadCount, lastMessageAt];
}

/// Modèle pour un message de chat
class ChatMessage extends Equatable {
  final int id;
  final String message;
  final bool isAdmin;
  final bool isRead;
  final String? senderName;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    required this.message,
    required this.isAdmin,
    required this.isRead,
    this.senderName,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] ?? 0,
      message: json['message'] ?? '',
      isAdmin: json['is_admin'] ?? false,
      isRead: json['is_read'] ?? false,
      senderName: json['sender_name'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, message, isAdmin, createdAt];
}

/// Dernier message résumé
class LastMessage extends Equatable {
  final String text;
  final bool isAdmin;
  final DateTime createdAt;

  const LastMessage({
    required this.text,
    required this.isAdmin,
    required this.createdAt,
  });

  factory LastMessage.fromJson(Map<String, dynamic> json) {
    return LastMessage(
      text: json['text'] ?? '',
      isAdmin: json['is_admin'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [text, isAdmin, createdAt];
}
