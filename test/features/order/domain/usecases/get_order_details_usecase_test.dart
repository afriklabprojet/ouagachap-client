import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/order/domain/entities/order.dart';
import 'package:ouaga_chap_client/features/order/domain/repositories/order_repository.dart';
import 'package:ouaga_chap_client/features/order/domain/usecases/get_order_details_usecase.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late GetOrderDetailsUseCase useCase;
  late MockOrderRepository mockRepository;

  setUp(() {
    mockRepository = MockOrderRepository();
    useCase = GetOrderDetailsUseCase(mockRepository);
  });

  group('GetOrderDetailsUseCase', () {
    final testOrder = Order(
      id: 1,
      trackingNumber: 'OCH-001',
      pickupAddress: '123 Rue Principale',
      pickupLatitude: 12.3456,
      pickupLongitude: -1.2345,
      deliveryAddress: '456 Rue Secondaire',
      deliveryLatitude: 12.4567,
      deliveryLongitude: -1.3456,
      recipientName: 'Marie Martin',
      recipientPhone: '+22671234567',
      status: OrderStatus.inTransit,
      distance: 5.5,
      price: 2500,
      createdAt: DateTime(2024, 1, 15),
      courier: Courier(
        id: 5,
        name: 'Kofi Mensah',
        phone: '+22675555555',
      ),
    );

    test('should return order details by id', () async {
      // Arrange
      when(() => mockRepository.getOrderDetails(1))
          .thenAnswer((_) async => testOrder);

      // Act
      final result = await useCase.call(1);

      // Assert
      expect(result, equals(testOrder));
      expect(result.id, equals(1));
      verify(() => mockRepository.getOrderDetails(1)).called(1);
    });

    test('should return order with courier when assigned', () async {
      // Arrange
      when(() => mockRepository.getOrderDetails(1))
          .thenAnswer((_) async => testOrder);

      // Act
      final result = await useCase.call(1);

      // Assert
      expect(result.courier, isNotNull);
      expect(result.courier!.name, equals('Kofi Mensah'));
      expect(result.courier!.phone, equals('+22675555555'));
    });

    test('should return order without courier when not assigned', () async {
      // Arrange
      final orderWithoutCourier = Order(
        id: 1,
        trackingNumber: 'OCH-001',
        pickupAddress: '123 Rue Principale',
        pickupLatitude: 12.3456,
        pickupLongitude: -1.2345,
        deliveryAddress: '456 Rue Secondaire',
        deliveryLatitude: 12.4567,
        deliveryLongitude: -1.3456,
        recipientName: 'Marie Martin',
        recipientPhone: '+22671234567',
        status: OrderStatus.pending,
        distance: 5.5,
        price: 2500,
        createdAt: DateTime(2024, 1, 15),
        courier: null,
      );
      when(() => mockRepository.getOrderDetails(1))
          .thenAnswer((_) async => orderWithoutCourier);

      // Act
      final result = await useCase.call(1);

      // Assert
      expect(result.courier, isNull);
    });

    test('should throw exception when order not found', () async {
      // Arrange
      when(() => mockRepository.getOrderDetails(999))
          .thenThrow(Exception('Order not found'));

      // Act & Assert
      expect(
        () => useCase.call(999),
        throwsException,
      );
    });

    test('should return order with correct status', () async {
      // Arrange
      when(() => mockRepository.getOrderDetails(1))
          .thenAnswer((_) async => testOrder);

      // Act
      final result = await useCase.call(1);

      // Assert
      expect(result.status, equals(OrderStatus.inTransit));
      expect(result.isActive, isTrue);
    });

    test('should be called with different order ids', () async {
      // Arrange
      final order2 = Order(
        id: 2,
        trackingNumber: 'OCH-002',
        pickupAddress: '123 Rue Principale',
        pickupLatitude: 12.3456,
        pickupLongitude: -1.2345,
        deliveryAddress: '456 Rue Secondaire',
        deliveryLatitude: 12.4567,
        deliveryLongitude: -1.3456,
        recipientName: 'Marie Martin',
        recipientPhone: '+22671234567',
        status: OrderStatus.inTransit,
        distance: 5.5,
        price: 2500,
        createdAt: DateTime(2024, 1, 15),
      );
      when(() => mockRepository.getOrderDetails(1))
          .thenAnswer((_) async => testOrder);
      when(() => mockRepository.getOrderDetails(2))
          .thenAnswer((_) async => order2);

      // Act
      final result1 = await useCase.call(1);
      final result2 = await useCase.call(2);

      // Assert
      expect(result1.id, equals(1));
      expect(result2.id, equals(2));
    });
  });
}
