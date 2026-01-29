import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/core/network/api_client.dart';
import 'package:ouaga_chap_client/features/incoming/data/datasources/incoming_order_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late IncomingOrderRemoteDataSource dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = IncomingOrderRemoteDataSource(mockApiClient);
  });

  group('IncomingOrderRemoteDataSource', () {
    group('getIncomingOrders', () {
      final testResponse = Response(
        requestOptions: RequestOptions(path: '/incoming-orders'),
        data: {
          'data': {
            'orders': [
              {
                'id': '1',
                'order_number': 'ORD001',
                'status': 'pending',
                'status_label': 'En attente',
                'pickup_contact_name': 'John',
                'pickup_contact_phone': '70000000',
                'dropoff_address': 'Test Address',
                'dropoff_latitude': 12.345,
                'dropoff_longitude': -1.234,
                'package_description': 'Colis test',
                'package_size': 'small',
                'total_price': 1000,
                'recipient_confirmed': false,
                'created_at': '2024-01-15T10:00:00Z',
              }
            ],
            'stats': {
              'total': 1,
              'pending': 1,
              'delivered': 0,
            },
            'pagination': {'current_page': 1, 'total': 1},
          },
        },
      );

      test('should return orders from API', () async {
        // Arrange
        when(() => mockApiClient.get(
              '/incoming-orders',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.getIncomingOrders();

        // Assert
        expect(result['orders'], isNotNull);
        expect(result['stats'], isNotNull);
        verify(() => mockApiClient.get(
              '/incoming-orders',
              queryParameters: {},
            )).called(1);
      });

      test('should pass status filter to API', () async {
        // Arrange
        when(() => mockApiClient.get(
              '/incoming-orders',
              queryParameters: any(named: 'queryParameters'),
            )).thenAnswer((_) async => testResponse);

        // Act
        await dataSource.getIncomingOrders(status: 'pending');

        // Assert
        verify(() => mockApiClient.get(
              '/incoming-orders',
              queryParameters: {'status': 'pending'},
            )).called(1);
      });
    });

    group('getIncomingOrderDetails', () {
      final testResponse = Response(
        requestOptions: RequestOptions(path: '/incoming-orders/123'),
        data: {
          'data': {
            'order': {
              'id': '123',
              'order_number': 'ORD123',
              'status': 'pending',
              'status_label': 'En attente',
              'pickup_contact_name': 'John',
              'pickup_contact_phone': '70000000',
              'dropoff_address': 'Test Address',
              'dropoff_latitude': 12.345,
              'dropoff_longitude': -1.234,
              'package_description': 'Colis test',
              'package_size': 'small',
              'total_price': 1000,
              'recipient_confirmed': false,
              'created_at': '2024-01-15T10:00:00Z',
            },
          },
        },
      );

      test('should return order details from API', () async {
        // Arrange
        when(() => mockApiClient.get('/incoming-orders/123'))
            .thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.getIncomingOrderDetails('123');

        // Assert
        expect(result.id, equals('123'));
        verify(() => mockApiClient.get('/incoming-orders/123')).called(1);
      });
    });

    group('trackOrder', () {
      final testResponse = Response(
        requestOptions: RequestOptions(path: '/incoming-orders/123/track'),
        data: {
          'data': {
            'latitude': 12.345,
            'longitude': -1.234,
            'courier_name': 'Coursier Test',
          },
        },
      );

      test('should return tracking data from API', () async {
        // Arrange
        when(() => mockApiClient.get('/incoming-orders/123/track'))
            .thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.trackOrder('123');

        // Assert
        expect(result['latitude'], equals(12.345));
        expect(result['longitude'], equals(-1.234));
        verify(() => mockApiClient.get('/incoming-orders/123/track')).called(1);
      });
    });

    group('confirmReceipt', () {
      final testResponse = Response(
        requestOptions: RequestOptions(path: '/incoming-orders/123/confirm'),
        data: {'success': true},
      );

      test('should call confirm API with code', () async {
        // Arrange
        when(() => mockApiClient.post(
              '/incoming-orders/123/confirm',
              data: any(named: 'data'),
            )).thenAnswer((_) async => testResponse);

        // Act
        await dataSource.confirmReceipt('123', 'CODE123');

        // Assert
        verify(() => mockApiClient.post(
              '/incoming-orders/123/confirm',
              data: {'confirmation_code': 'CODE123'},
            )).called(1);
      });
    });

    group('searchByOrderNumber', () {
      final testResponse = Response(
        requestOptions: RequestOptions(path: '/track-order'),
        data: {
          'data': {
            'order': {
              'id': 1,
              'order_number': 'ORD001',
              'status': 'in_transit',
            },
          },
        },
      );

      test('should search order by number and phone', () async {
        // Arrange
        when(() => mockApiClient.post(
              '/track-order',
              data: any(named: 'data'),
            )).thenAnswer((_) async => testResponse);

        // Act
        final result = await dataSource.searchByOrderNumber(
          orderNumber: 'ORD001',
          phone: '70123456',
        );

        // Assert
        expect(result['order'], isNotNull);
        verify(() => mockApiClient.post(
              '/track-order',
              data: {
                'order_number': 'ORD001',
                'phone': '70123456',
              },
            )).called(1);
      });
    });
  });
}
