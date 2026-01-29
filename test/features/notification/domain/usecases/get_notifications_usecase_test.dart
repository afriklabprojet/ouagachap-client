import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/notification/domain/entities/notification.dart';
import 'package:ouaga_chap_client/features/notification/domain/repositories/notification_repository.dart';
import 'package:ouaga_chap_client/features/notification/domain/usecases/get_notifications_usecase.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late GetNotificationsUseCase useCase;
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
    useCase = GetNotificationsUseCase(mockRepository);
  });

  group('GetNotificationsUseCase', () {
    final testNotifications = [
      Notification(
        id: '1',
        title: 'Test Notification 1',
        body: 'Test body 1',
        isRead: false,
        createdAt: DateTime(2024, 1, 15),
      ),
      Notification(
        id: '2',
        title: 'Test Notification 2',
        body: 'Test body 2',
        isRead: true,
        createdAt: DateTime(2024, 1, 14),
      ),
    ];

    test('should call repository.getNotifications with default page', () async {
      // Arrange
      when(() => mockRepository.getNotifications(page: 1))
          .thenAnswer((_) async => testNotifications);

      // Act
      final result = await useCase();

      // Assert
      expect(result, testNotifications);
      verify(() => mockRepository.getNotifications(page: 1)).called(1);
    });

    test('should call repository.getNotifications with custom page', () async {
      // Arrange
      when(() => mockRepository.getNotifications(page: 2))
          .thenAnswer((_) async => testNotifications);

      // Act
      final result = await useCase(page: 2);

      // Assert
      expect(result, testNotifications);
      verify(() => mockRepository.getNotifications(page: 2)).called(1);
    });

    test('should return empty list when no notifications', () async {
      // Arrange
      when(() => mockRepository.getNotifications(page: 1))
          .thenAnswer((_) async => []);

      // Act
      final result = await useCase();

      // Assert
      expect(result, isEmpty);
    });

    test('should propagate exception from repository', () async {
      // Arrange
      when(() => mockRepository.getNotifications(page: 1))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => useCase(), throwsA(isA<Exception>()));
    });
  });
}
