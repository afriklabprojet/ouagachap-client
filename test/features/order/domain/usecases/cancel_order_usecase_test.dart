import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/order/domain/repositories/order_repository.dart';
import 'package:ouaga_chap_client/features/order/domain/usecases/cancel_order_usecase.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late CancelOrderUseCase useCase;
  late MockOrderRepository mockRepository;

  setUp(() {
    mockRepository = MockOrderRepository();
    useCase = CancelOrderUseCase(mockRepository);
  });

  group('CancelOrderUseCase', () {
    test('should cancel order without reason', () async {
      // Arrange
      when(() => mockRepository.cancelOrder(1, reason: null))
          .thenAnswer((_) async {});

      // Act
      await useCase.call(1);

      // Assert
      verify(() => mockRepository.cancelOrder(1, reason: null)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should cancel order with reason', () async {
      // Arrange
      const reason = 'Changement de plan';
      when(() => mockRepository.cancelOrder(1, reason: reason))
          .thenAnswer((_) async {});

      // Act
      await useCase.call(1, reason: reason);

      // Assert
      verify(() => mockRepository.cancelOrder(1, reason: reason)).called(1);
    });

    test('should throw exception when order cannot be cancelled', () async {
      // Arrange
      when(() => mockRepository.cancelOrder(any(), reason: any(named: 'reason')))
          .thenThrow(Exception('Order already delivered'));

      // Act & Assert
      expect(
        () => useCase.call(1),
        throwsException,
      );
    });

    test('should throw exception when order not found', () async {
      // Arrange
      when(() => mockRepository.cancelOrder(999, reason: null))
          .thenThrow(Exception('Order not found'));

      // Act & Assert
      expect(
        () => useCase.call(999),
        throwsException,
      );
    });

    test('should complete without error on successful cancellation', () async {
      // Arrange
      when(() => mockRepository.cancelOrder(1, reason: null))
          .thenAnswer((_) async {});

      // Act & Assert
      expect(useCase.call(1), completes);
    });

    test('should handle various cancellation reasons', () async {
      // Arrange
      final reasons = [
        'Adresse incorrecte',
        'Délai trop long',
        'Plus besoin',
        null,
      ];

      for (final reason in reasons) {
        when(() => mockRepository.cancelOrder(1, reason: reason))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(1, reason: reason);

        // Assert
        verify(() => mockRepository.cancelOrder(1, reason: reason)).called(1);
      }
    });

    test('should handle network error gracefully', () async {
      // Arrange
      when(() => mockRepository.cancelOrder(any(), reason: any(named: 'reason')))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () async => await useCase.call(1),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Network error'),
        )),
      );
    });
  });
}
