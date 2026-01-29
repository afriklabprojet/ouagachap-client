import '../../domain/entities/notification.dart';

class NotificationModel extends Notification {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.body,
    required super.isRead,
    super.type,
    required super.createdAt,
    super.data,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    // Le backend envoie title/message directement, pas dans un sous-objet data
    String title = json['title'] ?? 'Notification';
    String body = json['message'] ?? json['body'] ?? '';
    
    // Si data contient title/body, les utiliser en priorité
    if (json['data'] != null && json['data'] is Map) {
      title = json['data']['title'] ?? title;
      body = json['data']['body'] ?? json['data']['message'] ?? body;
    }
    
    return NotificationModel(
      id: json['id'].toString(),
      title: title,
      body: body,
      isRead: json['is_read'] == true || json['read_at'] != null,
      type: json['type']?.toString(),
      createdAt: DateTime.parse(json['created_at']),
      data: json['data'] is Map<String, dynamic> ? json['data'] : null,
    );
  }
}
