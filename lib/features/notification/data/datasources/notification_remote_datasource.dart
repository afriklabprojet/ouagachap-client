import '../../../../core/network/api_client.dart';
import '../models/notification_model.dart';
abstract class NotificationRemoteDataSource {
  Future<List<NotificationModel>> getNotifications({int page = 1});
  Future<int> getUnreadCount();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
}

class NotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final ApiClient _apiClient;

  NotificationRemoteDataSourceImpl(this._apiClient);

  @override
  Future<List<NotificationModel>> getNotifications({int page = 1}) async {
    final response = await _apiClient.get(
      'notifications', // Corrected path (no leading slash)
      queryParameters: {'page': page},
    );
    
    // API returns paginated response inside 'data' key
    // response.data['data'] is the paginator object
    // response.data['data']['data'] is the actual list
    final data = response.data['data']['data'] as List<dynamic>?;
    
    if (data == null) return [];
    
    return data
        .map((json) => NotificationModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  @override
  Future<int> getUnreadCount() async {
    final response = await _apiClient.get('notifications/unread-count');
     // Depend on API response structure. Assuming { count: 5 } or just 5
    if (response.data is int) return response.data;
    return response.data['count'] ?? 0;
  }

  @override
  Future<void> markAsRead(String id) async {
    await _apiClient.post('notifications/$id/read');
  }

  @override
  Future<void> markAllAsRead() async {
    await _apiClient.post('notifications/mark-all-read');
  }
}
