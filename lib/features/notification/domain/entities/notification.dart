class Notification {
  final String id;
  final String title;
  final String body;
  final bool isRead;
  final String? type; // 'order_update', 'promo', 'system'
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  const Notification({
    required this.id,
    required this.title,
    required this.body,
    required this.isRead,
    this.type,
    required this.createdAt,
    this.data,
  });
}
