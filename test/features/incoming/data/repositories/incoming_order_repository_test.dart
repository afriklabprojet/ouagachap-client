import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/incoming/data/datasources/incoming_order_remote_datasource.dart';
import 'package:ouaga_chap_client/features/incoming/data/repositories/incoming_order_repository.dart';
import 'package:ouaga_chap_client/features/incoming/domain/entities/incoming_order.dart';

class MockIncomingOrderRemoteDataSource extends Mock
    implements IncomingOrderRemoteDataSource {}

void main() {
  late IncomingOrderRepository repository;
  late MockIncomingOrderRemoteDataSource mockDataSource;

  setUp(() {
    mockDataSource = MockIncomingOrderRemoteDataSource();
    repository = IncomingOrderRepository(mockDataSource);
  });

  group('IncomingOrderRepository', () {
    group('getIncomingOrders', () {
      test('calls datasource without status filter', () async {
        final result = {
          'orders': [],
          'stats': {'total': 0, 'pending': 0, 'in_transit': 0, 'delivered': 0},
        };

        when(() => mockDataSource.getIncomingOrders())
            .thenAnswer((_) async => result);

        final response = await repository.getIncomingOrders();

        expect(response, result);
        verify(() => mockDataSource.getIncomingOrders()).called(1);
      });

      test('calls datasource with status filter', () async {
        final result = {
          'orders': [],
          'stats': {'total': 2, 'pending': 2, 'in_transit': 0, 'delivered': 0},
        };

        when(() => mockDataSource.getIncomingOrders(status: 'pending'))
            .thenAnswer((_) async => result);

        final response = await repository.getIncomingOrders(status: 'pending');

        expect(response, result);
        verify(() => mockDataSource.getIncomingOrders(status: 'pending')).called(1);
      });

      test('propagates exception from datasource', () async {
        when(() => mockDataSource.getIncomingOrders())
            .thenThrow(Exception('Network error'));

        expect(
          () => repository.getIncomingOrders(),
          throwsException,
        );
      });
    });

    group('getIncomingOrderDetails', () {
      test('returns order from datasource', () async {
        final order = IncomingOrder(
          id: 'order1',
          orderNumber: 'ORD001',
          status: 'pending',
          statusLabel: 'En attente',
          senderName: 'John',
          senderPhone: '70123456',
          dropoffAddress: 'Address B',
          dropoffLatitude: 12.3,
          dropoffLongitude: -1.5,
          packageSize: 'small',
          totalPrice: 1500.0,
          recipientConfirmed: false,
          createdAt: DateTime(2024, 1, 15),
        );

        when(() => mockDataSource.getIncomingOrderDetails('order1'))
            .thenAnswer((_) async => order);

        final result = await repository.getIncomingOrderDetails('order1');

        expect(result, order);
        verify(() => mockDataSource.getIncomingOrderDetails('order1')).called(1);
      });

      test('propagates exception from datasource', () async {
        when(() => mockDataSource.getIncomingOrderDetails(any()))
            .thenThrow(Exception('Not found'));

        expect(
          () => repository.getIncomingOrderDetails('invalid'),
          throwsException,
        );
      });
    });

    group('trackOrder', () {
      test('returns tracking data from datasource', () async {
        final trackingData = {
          'orderId': 'order1',
          'orderNumber': 'ORD001',
          'status': 'in_transit',
          'courier': {'name': 'Jean', 'phone': '70000000'},
          'etaMinutes': 15,
        };

        when(() => mockDataSource.trackOrder('order1'))
            .thenAnswer((_) async => trackingData);

        final result = await repository.trackOrder('order1');

        expect(result, trackingData);
        verify(() => mockDataSource.trackOrder('order1')).called(1);
      });

      test('propagates exception from datasource', () async {
        when(() => mockDataSource.trackOrder(any()))
            .thenThrow(Exception('Tracking unavailable'));

        expect(
          () => repository.trackOrder('order1'),
          throwsException,
        );
      });
    });

    group('confirmReceipt', () {
      test('calls datasource with correct parameters', () async {
        when(() => mockDataSource.confirmReceipt('order1', 'CODE123'))
            .thenAnswer((_) async {});

        await repository.confirmReceipt('order1', 'CODE123');

        verify(() => mockDataSource.confirmReceipt('order1', 'CODE123')).called(1);
      });

      test('propagates exception from datasource', () async {
        when(() => mockDataSource.confirmReceipt(any(), any()))
            .thenThrow(Exception('Invalid code'));

        expect(
          () => repository.confirmReceipt('order1', 'WRONG'),
          throwsException,
        );
      });
    });

    group('searchByOrderNumber', () {
      test('calls datasource with correct parameters', () async {
        final searchResult = {
          'found': true,
          'order': {'id': 'order1', 'orderNumber': 'ORD001'},
        };

        when(() => mockDataSource.searchByOrderNumber(
              orderNumber: 'ORD001',
              phone: '70123456',
            )).thenAnswer((_) async => searchResult);

        final result = await repository.searchByOrderNumber(
          orderNumber: 'ORD001',
          phone: '70123456',
        );

        expect(result, searchResult);
        verify(() => mockDataSource.searchByOrderNumber(
              orderNumber: 'ORD001',
              phone: '70123456',
            )).called(1);
      });

      test('returns not found result', () async {
        final searchResult = {'found': false};

        when(() => mockDataSource.searchByOrderNumber(
              orderNumber: 'INVALID',
              phone: '00000000',
            )).thenAnswer((_) async => searchResult);

        final result = await repository.searchByOrderNumber(
          orderNumber: 'INVALID',
          phone: '00000000',
        );

        expect(result['found'], false);
      });

      test('propagates exception from datasource', () async {
        when(() => mockDataSource.searchByOrderNumber(
              orderNumber: any(named: 'orderNumber'),
              phone: any(named: 'phone'),
            )).thenThrow(Exception('Search failed'));

        expect(
          () => repository.searchByOrderNumber(
            orderNumber: 'ORD001',
            phone: '70123456',
          ),
          throwsException,
        );
      });
    });
  });
}
