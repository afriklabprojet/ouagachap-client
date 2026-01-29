import 'package:equatable/equatable.dart';

/// Modèle pour une réclamation/ticket
class Complaint extends Equatable {
  final int id;
  final String ticketNumber;
  final String type;
  final String typeLabel;
  final String subject;
  final String description;
  final String status;
  final String statusColor;
  final String statusLabel;
  final String priority;
  final String priorityColor;
  final String priorityLabel;
  final int? orderId;
  final String? orderTracking;
  final String? resolution;
  final DateTime? resolvedAt;
  final LastComplaintMessage? lastMessage;
  final int unreadCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Complaint({
    required this.id,
    required this.ticketNumber,
    required this.type,
    required this.typeLabel,
    required this.subject,
    required this.description,
    required this.status,
    required this.statusColor,
    required this.statusLabel,
    required this.priority,
    required this.priorityColor,
    required this.priorityLabel,
    this.orderId,
    this.orderTracking,
    this.resolution,
    this.resolvedAt,
    this.lastMessage,
    this.unreadCount = 0,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOpen => status == 'open';
  bool get isInProgress => status == 'in_progress';
  bool get isResolved => status == 'resolved';
  bool get isClosed => status == 'closed';
  bool get canReply => !isResolved && !isClosed;
  bool get hasUnread => unreadCount > 0;

  factory Complaint.fromJson(Map<String, dynamic> json) {
    return Complaint(
      id: json['id'] ?? 0,
      ticketNumber: json['ticket_number'] ?? '',
      type: json['type'] ?? 'other',
      typeLabel: json['type_label'] ?? 'Autre',
      subject: json['subject'] ?? '',
      description: json['description'] ?? '',
      status: json['status'] ?? 'open',
      statusColor: json['status_color'] ?? 'gray',
      statusLabel: json['status_label'] ?? 'Ouvert',
      priority: json['priority'] ?? 'medium',
      priorityColor: json['priority_color'] ?? 'info',
      priorityLabel: json['priority_label'] ?? 'Moyenne',
      orderId: json['order_id'],
      orderTracking: json['order_tracking'],
      resolution: json['resolution'],
      resolvedAt: json['resolved_at'] != null
          ? DateTime.parse(json['resolved_at'])
          : null,
      lastMessage: json['last_message'] != null
          ? LastComplaintMessage.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [id, ticketNumber, status, unreadCount];
}

/// Modèle pour un message de réclamation
class ComplaintMessage extends Equatable {
  final int id;
  final String message;
  final bool isAdmin;
  final bool isRead;
  final String? senderName;
  final DateTime createdAt;

  const ComplaintMessage({
    required this.id,
    required this.message,
    required this.isAdmin,
    required this.isRead,
    this.senderName,
    required this.createdAt,
  });

  factory ComplaintMessage.fromJson(Map<String, dynamic> json) {
    return ComplaintMessage(
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
class LastComplaintMessage extends Equatable {
  final String text;
  final bool isAdmin;
  final DateTime createdAt;

  const LastComplaintMessage({
    required this.text,
    required this.isAdmin,
    required this.createdAt,
  });

  factory LastComplaintMessage.fromJson(Map<String, dynamic> json) {
    return LastComplaintMessage(
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

/// Type de réclamation
class ComplaintType extends Equatable {
  final String value;
  final String label;
  final String icon;

  const ComplaintType({
    required this.value,
    required this.label,
    required this.icon,
  });

  factory ComplaintType.fromJson(Map<String, dynamic> json) {
    return ComplaintType(
      value: json['value'] ?? '',
      label: json['label'] ?? '',
      icon: json['icon'] ?? 'help-circle',
    );
  }

  @override
  List<Object?> get props => [value, label, icon];
}
