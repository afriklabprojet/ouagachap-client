import 'package:flutter/foundation.dart';

import 'notification.dart';

@immutable
class AppNotification extends Notification {
  const AppNotification({
    required super.id,
    required super.title,
    required super.body,
    super.type,
    required super.isRead,
    required super.createdAt,
    super.data,
  });
}
