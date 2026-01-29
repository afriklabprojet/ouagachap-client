import '../entities/notification.dart';

abstract class NotificationRepository {
  Future<List<Notification>> getNotifications({int page = 1});
  Future<int> getUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}
