import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/notification/domain/repositories/notification_repository.dart';
import 'package:ouaga_chap_client/features/notification/domain/usecases/mark_notification_read_usecase.dart';

class MockNotificationRepository extends Mock implements NotificationRepository {}

void main() {
  late MarkNotificationReadUseCase useCase;
  late MockNotificationRepository mockRepository;

  setUp(() {
    mockRepository = MockNotificationRepository();
    useCase = MarkNotificationReadUseCase(mockRepository);
  });

  group('MarkNotificationReadUseCase', () {
    const testNotificationId = 'notification_123';

    test('should call repository.markAsRead with correct id', () async {
      // Arrange
      when(() => mockRepository.markAsRead(testNotificationId))
          .thenAnswer((_) async => {});

      // Act
      await useCase(testNotificationId);

      // Assert
      verify(() => mockRepository.markAsRead(testNotificationId)).called(1);
    });

    test('should complete successfully when repository succeeds', () async {
      // Arrange
      when(() => mockRepository.markAsRead(testNotificationId))
          .thenAnswer((_) async => {});

      // Act & Assert
      await expectLater(useCase(testNotificationId), completes);
    });

    test('should propagate exception from repository', () async {
      // Arrange
      when(() => mockRepository.markAsRead(testNotificationId))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(() => useCase(testNotificationId), throwsA(isA<Exception>()));
    });

    test('should handle different notification ids', () async {
      // Arrange
      const otherId = 'notification_456';
      when(() => mockRepository.markAsRead(otherId))
          .thenAnswer((_) async => {});

      // Act
      await useCase(otherId);

      // Assert
      verify(() => mockRepository.markAsRead(otherId)).called(1);
      verifyNever(() => mockRepository.markAsRead(testNotificationId));
    });
  });
}
