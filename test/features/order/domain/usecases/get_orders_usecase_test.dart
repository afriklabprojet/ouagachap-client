import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/order/domain/entities/order.dart';
import 'package:ouaga_chap_client/features/order/domain/repositories/order_repository.dart';
import 'package:ouaga_chap_client/features/order/domain/usecases/get_orders_usecase.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late GetOrdersUseCase useCase;
  late MockOrderRepository mockRepository;

  setUp(() {
    mockRepository = MockOrderRepository();
    useCase = GetOrdersUseCase(mockRepository);
  });

  group('GetOrdersUseCase', () {
    final testOrders = <Order>[
      Order(
        id: 1,
        trackingNumber: 'OCH-001',
        pickupAddress: '123 Rue A',
        pickupLatitude: 12.3456,
        pickupLongitude: -1.2345,
        deliveryAddress: '456 Rue B',
        deliveryLatitude: 12.4567,
        deliveryLongitude: -1.3456,
        recipientName: 'Marie',
        recipientPhone: '+22671234567',
        status: OrderStatus.pending,
        distance: 5.0,
        price: 2500,
        createdAt: DateTime(2024, 1, 15),
      ),
      Order(
        id: 2,
        trackingNumber: 'OCH-002',
        pickupAddress: '789 Rue C',
        pickupLatitude: 12.5678,
        pickupLongitude: -1.4567,
        deliveryAddress: '012 Rue D',
        deliveryLatitude: 12.6789,
        deliveryLongitude: -1.5678,
        recipientName: 'Jean',
        recipientPhone: '+22670123456',
        status: OrderStatus.delivered,
        distance: 7.5,
        price: 3000,
        createdAt: DateTime(2024, 1, 14),
      ),
    ];

    test('should return list of orders with default pagination', () async {
      // Arrange
      when(() => mockRepository.getOrders(
            page: 1,
            perPage: 10,
            status: null,
          )).thenAnswer((_) async => testOrders);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, equals(testOrders));
      expect(result.length, equals(2));
      verify(() => mockRepository.getOrders(
            page: 1,
            perPage: 10,
            status: null,
          )).called(1);
    });

    test('should return orders with custom pagination', () async {
      // Arrange
      when(() => mockRepository.getOrders(
            page: 2,
            perPage: 5,
            status: null,
          )).thenAnswer((_) async => testOrders);

      // Act
      final result = await useCase.call(page: 2, perPage: 5);

      // Assert
      expect(result, isNotNull);
      verify(() => mockRepository.getOrders(
            page: 2,
            perPage: 5,
            status: null,
          )).called(1);
    });

    test('should filter orders by status', () async {
      // Arrange
      final pendingOrders = testOrders
          .where((o) => o.status == OrderStatus.pending)
          .toList();
      when(() => mockRepository.getOrders(
            page: 1,
            perPage: 10,
            status: OrderStatus.pending,
          )).thenAnswer((_) async => pendingOrders);

      // Act
      final result = await useCase.call(status: OrderStatus.pending);

      // Assert
      expect(result.length, equals(1));
      expect(result.first.status, equals(OrderStatus.pending));
    });

    test('should return empty list when no orders', () async {
      // Arrange
      when(() => mockRepository.getOrders(
            page: 1,
            perPage: 10,
            status: null,
          )).thenAnswer((_) async => <Order>[]);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isEmpty);
    });

    test('should throw exception when repository throws', () async {
      // Arrange
      when(() => mockRepository.getOrders(
            page: any(named: 'page'),
            perPage: any(named: 'perPage'),
            status: any(named: 'status'),
          )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase.call(),
        throwsException,
      );
    });

    test('should return orders sorted by creation date', () async {
      // Arrange
      when(() => mockRepository.getOrders(
            page: 1,
            perPage: 10,
            status: null,
          )).thenAnswer((_) async => testOrders);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result.first.createdAt!.isAfter(result.last.createdAt!), isTrue);
    });
  });
}
