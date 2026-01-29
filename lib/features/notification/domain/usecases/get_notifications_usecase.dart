import '../entities/notification.dart';
import '../repositories/notification_repository.dart';

class GetNotificationsUseCase {
  final NotificationRepository repository;

  GetNotificationsUseCase(this.repository);

  Future<List<Notification>> call({int page = 1}) {
    return repository.getNotifications(page: page);
  }
}
