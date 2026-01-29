import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/core/network/api_client.dart';
import 'package:ouaga_chap_client/features/order/data/datasources/order_remote_datasource.dart';
import 'package:ouaga_chap_client/features/order/domain/entities/order.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late OrderRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = OrderRemoteDataSourceImpl(mockApiClient);
  });

  final orderJson = {
    'id': 1,
    'tracking_number': 'OCH-001',
    'pickup_address': '123 Rue A',
    'pickup_latitude': 12.3456,
    'pickup_longitude': -1.2345,
    'delivery_address': '456 Rue B',
    'delivery_latitude': 12.4567,
    'delivery_longitude': -1.3456,
    'recipient_name': 'Marie',
    'recipient_phone': '+22671234567',
    'distance': 5.5,
    'price': 2500.0,
    'status': 'pending',
    'created_at': '2024-01-15T10:30:00.000Z',
  };

  group('OrderRemoteDataSourceImpl', () {
    group('createOrder', () {
      test('should call apiClient.post with order data', () async {
        // Arrange
        when(() => mockApiClient.post(
              'orders',
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: 'orders'),
              statusCode: 201,
              data: {'data': orderJson},
            ));

        // Act
        final result = await dataSource.createOrder(
          pickupAddress: '123 Rue A',
          pickupLatitude: 12.3456,
          pickupLongitude: -1.2345,
          deliveryAddress: '456 Rue B',
          deliveryLatitude: 12.4567,
          deliveryLongitude: -1.3456,
          recipientName: 'Marie',
          recipientPhone: '+22671234567',
        );

        // Assert
        expect(result.id, equals(1));
        expect(result.pickupAddress, equals('123 Rue A'));
        expect(result.recipientName, equals('Marie'));
      });

      test('should include optional parameters when provided', () async {
        // Arrange
        when(() => mockApiClient.post(
              'orders',
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: 'orders'),
              statusCode: 201,
              data: {'data': orderJson},
            ));

        // Act
        await dataSource.createOrder(
          pickupAddress: '123 Rue A',
          pickupLatitude: 12.3456,
          pickupLongitude: -1.2345,
          pickupContactName: 'Jean',
          pickupContactPhone: '+22670000000',
          deliveryAddress: '456 Rue B',
          deliveryLatitude: 12.4567,
          deliveryLongitude: -1.3456,
          recipientName: 'Marie',
          recipientPhone: '+22671234567',
          packageDescription: 'Fragile',
          packageSize: 'medium',
        );

        // Assert
        verify(() => mockApiClient.post(
              'orders',
              data: {
                'pickup_address': '123 Rue A',
                'pickup_latitude': 12.3456,
                'pickup_longitude': -1.2345,
                'pickup_contact_name': 'Jean',
                'pickup_contact_phone': '+22670000000',
                'delivery_address': '456 Rue B',
                'delivery_latitude': 12.4567,
                'delivery_longitude': -1.3456,
                'recipient_name': 'Marie',
                'recipient_phone': '+22671234567',
                'package_description': 'Fragile',
                'package_size': 'medium',
              },
            )).called(1);
      });
    });

    group('getOrders', () {
      test('should return list of orders with pagination', () async {
        // Arrange
        when(() => mockApiClient.get(
              'orders',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: 'orders'),
              statusCode: 200,
              data: {'data': [orderJson]},
            ));

        // Act
        final result = await dataSource.getOrders(page: 1, perPage: 10);

        // Assert
        expect(result.length, equals(1));
        expect(result.first.id, equals(1));
      });

      test('should filter by status when provided', () async {
        // Arrange
        when(() => mockApiClient.get(
              'orders',
              queryParameters: {
                'page': 1,
                'per_page': 10,
                'status': 'pending',
              },
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: 'orders'),
              statusCode: 200,
              data: {'data': [orderJson]},
            ));

        // Act
        await dataSource.getOrders(status: OrderStatus.pending);

        // Assert
        verify(() => mockApiClient.get(
              'orders',
              queryParameters: {
                'page': 1,
                'per_page': 10,
                'status': 'pending',
              },
            )).called(1);
      });

      test('should return empty list when data is null', () async {
        // Arrange
        when(() => mockApiClient.get(
              'orders',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: 'orders'),
              statusCode: 200,
              data: {'data': null},
            ));

        // Act
        final result = await dataSource.getOrders();

        // Assert
        expect(result, isEmpty);
      });
    });

    group('getOrderDetails', () {
      test('should return order details by id', () async {
        // Arrange
        when(() => mockApiClient.get('/orders/1'))
            .thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: '/orders/1'),
              statusCode: 200,
              data: {'data': orderJson},
            ));

        // Act
        final result = await dataSource.getOrderDetails(1);

        // Assert
        expect(result.id, equals(1));
        expect(result.trackingNumber, equals('OCH-001'));
      });
    });

    group('cancelOrder', () {
      test('should cancel order without reason', () async {
        // Arrange
        when(() => mockApiClient.post(
              '/orders/1/cancel',
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: '/orders/1/cancel'),
              statusCode: 200,
            ));

        // Act
        await dataSource.cancelOrder(1);

        // Assert
        verify(() => mockApiClient.post(
              '/orders/1/cancel',
              data: {},
            )).called(1);
      });

      test('should cancel order with reason', () async {
        // Arrange
        when(() => mockApiClient.post(
              '/orders/1/cancel',
              data: {'reason': 'Changed mind'},
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: '/orders/1/cancel'),
              statusCode: 200,
            ));

        // Act
        await dataSource.cancelOrder(1, reason: 'Changed mind');

        // Assert
        verify(() => mockApiClient.post(
              '/orders/1/cancel',
              data: {'reason': 'Changed mind'},
            )).called(1);
      });
    });

    group('calculatePrice', () {
      test('should return calculated price', () async {
        // Arrange
        when(() => mockApiClient.post(any(), data: any(named: 'data')))
            .thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: 'orders/calculate-price'),
              statusCode: 200,
              data: {'data': {'price': 2500.0}},
            ));

        // Act
        final result = await dataSource.calculatePrice(
          pickupLatitude: 12.3456,
          pickupLongitude: -1.2345,
          deliveryLatitude: 12.4567,
          deliveryLongitude: -1.3456,
        );

        // Assert
        expect(result, equals(2500.0));
      });
    });
  });
}
