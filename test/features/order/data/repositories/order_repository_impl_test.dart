import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/order/data/datasources/order_remote_datasource.dart';
import 'package:ouaga_chap_client/features/order/data/models/order_model.dart';
import 'package:ouaga_chap_client/features/order/data/repositories/order_repository_impl.dart';
import 'package:ouaga_chap_client/features/order/domain/entities/order.dart';

class MockOrderRemoteDataSource extends Mock implements OrderRemoteDataSource {}

void main() {
  late OrderRepositoryImpl repository;
  late MockOrderRemoteDataSource mockRemoteDataSource;

  setUp(() {
    mockRemoteDataSource = MockOrderRemoteDataSource();
    repository = OrderRepositoryImpl(remoteDataSource: mockRemoteDataSource);
  });

  final testOrderModel = OrderModel(
    id: 1,
    trackingNumber: 'OCH-001',
    pickupAddress: '123 Rue A',
    pickupLatitude: 12.3456,
    pickupLongitude: -1.2345,
    deliveryAddress: '456 Rue B',
    deliveryLatitude: 12.4567,
    deliveryLongitude: -1.3456,
    recipientName: 'Marie Martin',
    recipientPhone: '+22671234567',
    distance: 5.5,
    price: 2500,
    status: OrderStatus.pending,
    createdAt: DateTime(2024, 1, 15),
  );

  group('OrderRepositoryImpl', () {
    group('createOrder', () {
      test('should create order via remote data source', () async {
        // Arrange
        when(() => mockRemoteDataSource.createOrder(
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
            )).thenAnswer((_) async => testOrderModel);

        // Act
        final result = await repository.createOrder(
          pickupAddress: '123 Rue A',
          pickupLatitude: 12.3456,
          pickupLongitude: -1.2345,
          deliveryAddress: '456 Rue B',
          deliveryLatitude: 12.4567,
          deliveryLongitude: -1.3456,
          recipientName: 'Marie Martin',
          recipientPhone: '+22671234567',
        );

        // Assert
        expect(result, equals(testOrderModel));
        verify(() => mockRemoteDataSource.createOrder(
              pickupAddress: '123 Rue A',
              pickupLatitude: 12.3456,
              pickupLongitude: -1.2345,
              pickupContactName: null,
              pickupContactPhone: null,
              deliveryAddress: '456 Rue B',
              deliveryLatitude: 12.4567,
              deliveryLongitude: -1.3456,
              recipientName: 'Marie Martin',
              recipientPhone: '+22671234567',
              packageDescription: null,
              packageSize: null,
            )).called(1);
      });

      test('should pass optional parameters when provided', () async {
        // Arrange
        when(() => mockRemoteDataSource.createOrder(
              pickupAddress: any(named: 'pickupAddress'),
              pickupLatitude: any(named: 'pickupLatitude'),
              pickupLongitude: any(named: 'pickupLongitude'),
              pickupContactName: 'Jean',
              pickupContactPhone: '+22670000000',
              deliveryAddress: any(named: 'deliveryAddress'),
              deliveryLatitude: any(named: 'deliveryLatitude'),
              deliveryLongitude: any(named: 'deliveryLongitude'),
              recipientName: any(named: 'recipientName'),
              recipientPhone: any(named: 'recipientPhone'),
              packageDescription: 'Colis fragile',
              packageSize: 'medium',
            )).thenAnswer((_) async => testOrderModel);

        // Act
        await repository.createOrder(
          pickupAddress: '123 Rue A',
          pickupLatitude: 12.3456,
          pickupLongitude: -1.2345,
          pickupContactName: 'Jean',
          pickupContactPhone: '+22670000000',
          deliveryAddress: '456 Rue B',
          deliveryLatitude: 12.4567,
          deliveryLongitude: -1.3456,
          recipientName: 'Marie Martin',
          recipientPhone: '+22671234567',
          packageDescription: 'Colis fragile',
          packageSize: 'medium',
        );

        // Assert
        verify(() => mockRemoteDataSource.createOrder(
              pickupAddress: '123 Rue A',
              pickupLatitude: 12.3456,
              pickupLongitude: -1.2345,
              pickupContactName: 'Jean',
              pickupContactPhone: '+22670000000',
              deliveryAddress: '456 Rue B',
              deliveryLatitude: 12.4567,
              deliveryLongitude: -1.3456,
              recipientName: 'Marie Martin',
              recipientPhone: '+22671234567',
              packageDescription: 'Colis fragile',
              packageSize: 'medium',
            )).called(1);
      });
    });

    group('getOrders', () {
      test('should return list of orders with default pagination', () async {
        // Arrange
        when(() => mockRemoteDataSource.getOrders(
              page: 1,
              perPage: 10,
              status: null,
            )).thenAnswer((_) async => [testOrderModel]);

        // Act
        final result = await repository.getOrders();

        // Assert
        expect(result, isNotEmpty);
        expect(result.first, equals(testOrderModel));
      });

      test('should filter by status when provided', () async {
        // Arrange
        when(() => mockRemoteDataSource.getOrders(
              page: 1,
              perPage: 10,
              status: OrderStatus.pending,
            )).thenAnswer((_) async => [testOrderModel]);

        // Act
        final result = await repository.getOrders(status: OrderStatus.pending);

        // Assert
        expect(result.every((o) => o.status == OrderStatus.pending), isTrue);
      });

      test('should use custom pagination', () async {
        // Arrange
        when(() => mockRemoteDataSource.getOrders(
              page: 2,
              perPage: 5,
              status: null,
            )).thenAnswer((_) async => []);

        // Act
        await repository.getOrders(page: 2, perPage: 5);

        // Assert
        verify(() => mockRemoteDataSource.getOrders(
              page: 2,
              perPage: 5,
              status: null,
            )).called(1);
      });
    });

    group('getOrderDetails', () {
      test('should return order details by id', () async {
        // Arrange
        when(() => mockRemoteDataSource.getOrderDetails(1))
            .thenAnswer((_) async => testOrderModel);

        // Act
        final result = await repository.getOrderDetails(1);

        // Assert
        expect(result, equals(testOrderModel));
        expect(result.id, equals(1));
      });

      test('should throw when order not found', () async {
        // Arrange
        when(() => mockRemoteDataSource.getOrderDetails(999))
            .thenThrow(Exception('Order not found'));

        // Act & Assert
        expect(
          () => repository.getOrderDetails(999),
          throwsException,
        );
      });
    });

    group('cancelOrder', () {
      test('should cancel order without reason', () async {
        // Arrange
        when(() => mockRemoteDataSource.cancelOrder(1, reason: null))
            .thenAnswer((_) async {});

        // Act
        await repository.cancelOrder(1);

        // Assert
        verify(() => mockRemoteDataSource.cancelOrder(1, reason: null)).called(1);
      });

      test('should cancel order with reason', () async {
        // Arrange
        when(() => mockRemoteDataSource.cancelOrder(1, reason: 'Changed mind'))
            .thenAnswer((_) async {});

        // Act
        await repository.cancelOrder(1, reason: 'Changed mind');

        // Assert
        verify(() => mockRemoteDataSource.cancelOrder(1, reason: 'Changed mind')).called(1);
      });
    });

    group('calculatePrice', () {
      test('should calculate price based on coordinates', () async {
        // Arrange
        when(() => mockRemoteDataSource.calculatePrice(
              pickupLatitude: 12.3456,
              pickupLongitude: -1.2345,
              deliveryLatitude: 12.4567,
              deliveryLongitude: -1.3456,
            )).thenAnswer((_) async => 2500.0);

        // Act
        final result = await repository.calculatePrice(
          pickupLatitude: 12.3456,
          pickupLongitude: -1.2345,
          deliveryLatitude: 12.4567,
          deliveryLongitude: -1.3456,
        );

        // Assert
        expect(result, equals(2500.0));
      });
    });

    group('trackOrder', () {
      test('should return a stream of order updates', () async {
        // Arrange
        when(() => mockRemoteDataSource.getOrderDetails(1))
            .thenAnswer((_) async => testOrderModel);

        // Act
        final stream = repository.trackOrder(1);

        // Assert
        expect(stream, isA<Stream<Order>>());
      });

      test('trackOrder stream emits order from getOrderDetails', () async {
        // Arrange
        when(() => mockRemoteDataSource.getOrderDetails(1))
            .thenAnswer((_) async => testOrderModel);

        // Act
        final stream = repository.trackOrder(1);
        final order = await stream.first;

        // Assert
        expect(order, equals(testOrderModel));
        verify(() => mockRemoteDataSource.getOrderDetails(1)).called(1);
      });
    });
  });
}
