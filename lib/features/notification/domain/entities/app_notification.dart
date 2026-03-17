import 'package:flutter/foundation.dart';

import 'notification.dart';

@immutable
class AppNotification extends Notification {
  final String? type;
  final Map<String, dynamic>? data;

  const AppNotification({
    required super.id,
    required super.title,
    required super.body,
    this.type,
    required super.isRead,
    required super.createdAt,
    this.data,
  });
}
