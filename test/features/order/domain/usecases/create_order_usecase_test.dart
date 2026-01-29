import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/order/domain/entities/order.dart';
import 'package:ouaga_chap_client/features/order/domain/repositories/order_repository.dart';
import 'package:ouaga_chap_client/features/order/domain/usecases/create_order_usecase.dart';

class MockOrderRepository extends Mock implements OrderRepository {}

void main() {
  late CreateOrderUseCase useCase;
  late MockOrderRepository mockRepository;

  setUp(() {
    mockRepository = MockOrderRepository();
    useCase = CreateOrderUseCase(mockRepository);
  });

  group('CreateOrderUseCase', () {
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
      status: OrderStatus.pending,
      distance: 5.5,
      price: 2500,
      createdAt: DateTime(2024, 1, 15),
    );

    test('should create order with all required parameters', () async {
      // Arrange
      when(() => mockRepository.createOrder(
            pickupAddress: any(named: 'pickupAddress'),
            pickupLatitude: any(named: 'pickupLatitude'),
            pickupLongitude: any(named: 'pickupLongitude'),
            pickupContactName: any(named: 'pickupContactName'),
            pickupContactPhone: any(named: 'pickupContactPhone'),
            deliveryAddress: any(named: 'deliveryAddress'),
            deliveryLatitude: any(named: 'deliveryLatitude'),
            deliveryLongitude: any(named: 'deliveryLongitude'),
            recipientName: any(named: 'recipientName'),
            recipientPhone: any(named: 'recipientPhone'),
            packageDescription: any(named: 'packageDescription'),
            packageSize: any(named: 'packageSize'),
          )).thenAnswer((_) async => testOrder);

      // Act
      final result = await useCase.call(
        pickupAddress: '123 Rue Principale',
        pickupLatitude: 12.3456,
        pickupLongitude: -1.2345,
        deliveryAddress: '456 Rue Secondaire',
        deliveryLatitude: 12.4567,
        deliveryLongitude: -1.3456,
        recipientName: 'Marie Martin',
        recipientPhone: '+22671234567',
      );

      // Assert
      expect(result, equals(testOrder));
      expect(result.status, equals(OrderStatus.pending));
    });

    test('should create order with optional parameters', () async {
      // Arrange
      when(() => mockRepository.createOrder(
            pickupAddress: any(named: 'pickupAddress'),
            pickupLatitude: any(named: 'pickupLatitude'),
            pickupLongitude: any(named: 'pickupLongitude'),
            pickupContactName: 'Jean Dupont',
            pickupContactPhone: '+22670123456',
            deliveryAddress: any(named: 'deliveryAddress'),
            deliveryLatitude: any(named: 'deliveryLatitude'),
            deliveryLongitude: any(named: 'deliveryLongitude'),
            recipientName: any(named: 'recipientName'),
            recipientPhone: any(named: 'recipientPhone'),
            packageDescription: 'Colis fragile',
            packageSize: 'medium',
          )).thenAnswer((_) async => testOrder);

      // Act
      final result = await useCase.call(
        pickupAddress: '123 Rue Principale',
        pickupLatitude: 12.3456,
        pickupLongitude: -1.2345,
        pickupContactName: 'Jean Dupont',
        pickupContactPhone: '+22670123456',
        deliveryAddress: '456 Rue Secondaire',
        deliveryLatitude: 12.4567,
        deliveryLongitude: -1.3456,
        recipientName: 'Marie Martin',
        recipientPhone: '+22671234567',
        packageDescription: 'Colis fragile',
        packageSize: 'medium',
      );

      // Assert
      expect(result, isNotNull);
      verify(() => mockRepository.createOrder(
            pickupAddress: '123 Rue Principale',
            pickupLatitude: 12.3456,
            pickupLongitude: -1.2345,
            pickupContactName: 'Jean Dupont',
            pickupContactPhone: '+22670123456',
            deliveryAddress: '456 Rue Secondaire',
            deliveryLatitude: 12.4567,
            deliveryLongitude: -1.3456,
            recipientName: 'Marie Martin',
            recipientPhone: '+22671234567',
            packageDescription: 'Colis fragile',
            packageSize: 'medium',
          )).called(1);
    });

    test('should throw exception when repository throws', () async {
      // Arrange
      when(() => mockRepository.createOrder(
            pickupAddress: any(named: 'pickupAddress'),
            pickupLatitude: any(named: 'pickupLatitude'),
            pickupLongitude: any(named: 'pickupLongitude'),
            pickupContactName: any(named: 'pickupContactName'),
            pickupContactPhone: any(named: 'pickupContactPhone'),
            deliveryAddress: any(named: 'deliveryAddress'),
            deliveryLatitude: any(named: 'deliveryLatitude'),
            deliveryLongitude: any(named: 'deliveryLongitude'),
            recipientName: any(named: 'recipientName'),
            recipientPhone: any(named: 'recipientPhone'),
            packageDescription: any(named: 'packageDescription'),
            packageSize: any(named: 'packageSize'),
          )).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase.call(
          pickupAddress: '123 Rue Principale',
          pickupLatitude: 12.3456,
          pickupLongitude: -1.2345,
          deliveryAddress: '456 Rue Secondaire',
          deliveryLatitude: 12.4567,
          deliveryLongitude: -1.3456,
          recipientName: 'Marie Martin',
          recipientPhone: '+22671234567',
        ),
        throwsException,
      );
    });

    test('should return order with correct price', () async {
      // Arrange
      final orderWithPrice = Order(
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
        price: 3500,
        createdAt: DateTime(2024, 1, 15),
      );
      when(() => mockRepository.createOrder(
            pickupAddress: any(named: 'pickupAddress'),
            pickupLatitude: any(named: 'pickupLatitude'),
            pickupLongitude: any(named: 'pickupLongitude'),
            pickupContactName: any(named: 'pickupContactName'),
            pickupContactPhone: any(named: 'pickupContactPhone'),
            deliveryAddress: any(named: 'deliveryAddress'),
            deliveryLatitude: any(named: 'deliveryLatitude'),
            deliveryLongitude: any(named: 'deliveryLongitude'),
            recipientName: any(named: 'recipientName'),
            recipientPhone: any(named: 'recipientPhone'),
            packageDescription: any(named: 'packageDescription'),
            packageSize: any(named: 'packageSize'),
          )).thenAnswer((_) async => orderWithPrice);

      // Act
      final result = await useCase.call(
        pickupAddress: '123 Rue Principale',
        pickupLatitude: 12.3456,
        pickupLongitude: -1.2345,
        deliveryAddress: '456 Rue Secondaire',
        deliveryLatitude: 12.4567,
        deliveryLongitude: -1.3456,
        recipientName: 'Marie Martin',
        recipientPhone: '+22671234567',
      );

      // Assert
      expect(result.price, equals(3500));
    });
  });
}
