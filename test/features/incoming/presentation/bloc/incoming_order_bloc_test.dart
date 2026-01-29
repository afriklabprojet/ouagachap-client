import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/incoming/presentation/bloc/incoming_order_bloc.dart';
import 'package:ouaga_chap_client/features/incoming/presentation/bloc/incoming_order_event.dart';
import 'package:ouaga_chap_client/features/incoming/presentation/bloc/incoming_order_state.dart';
import 'package:ouaga_chap_client/features/incoming/data/repositories/incoming_order_repository.dart';
import 'package:ouaga_chap_client/features/incoming/domain/entities/incoming_order.dart';

class MockIncomingOrderRepository extends Mock implements IncomingOrderRepository {}

void main() {
  late IncomingOrderBloc bloc;
  late MockIncomingOrderRepository mockRepository;

  setUp(() {
    mockRepository = MockIncomingOrderRepository();
    bloc = IncomingOrderBloc(mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  final testOrder = IncomingOrder(
    id: '1',
    orderNumber: 'ORD-001',
    status: 'pending',
    statusLabel: 'En attente',
    senderName: 'John Doe',
    senderPhone: '+22670000000',
    packageDescription: 'Colis test',
    dropoffAddress: 'Bobo-Dioulasso',
    dropoffLatitude: 11.178,
    dropoffLongitude: -4.297,
    packageSize: 'medium',
    totalPrice: 2500,
    recipientConfirmed: false,
    createdAt: DateTime(2024, 1, 15),
  );

  final testStats = const IncomingOrderStats(
    total: 10,
    pending: 5,
    inTransit: 3,
    delivered: 2,
  );

  final testOrdersData = {
    'orders': [testOrder],
    'stats': testStats,
  };

  final testTrackingData = {
    'order_id': '1',
    'order_number': 'ORD-001',
    'status': 'in_transit',
    'status_label': 'En cours de livraison',
    'courier': {'name': 'Jean', 'phone': '+22670000001'},
    'destination': {'address': 'Bobo-Dioulasso'},
    'eta_minutes': 30,
    'eta_text': '30 minutes',
  };

  group('IncomingOrderBloc', () {
    test('initial state is IncomingOrderInitial', () {
      expect(bloc.state, isA<IncomingOrderInitial>());
    });

    group('LoadIncomingOrders', () {
      test('emits [IncomingOrderLoading, IncomingOrderLoaded] when getIncomingOrders succeeds', () async {
        // Arrange
        when(() => mockRepository.getIncomingOrders(status: any(named: 'status')))
            .thenAnswer((_) async => testOrdersData);

        // Assert
        final expected = [
          isA<IncomingOrderLoading>(),
          isA<IncomingOrderLoaded>()
              .having((s) => s.orders.length, 'orders.length', 1)
              .having((s) => s.stats.total, 'stats.total', 10),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        // Act
        bloc.add(const LoadIncomingOrders());
      });

      test('emits [IncomingOrderLoading, IncomingOrderLoaded] with status filter', () async {
        // Arrange
        when(() => mockRepository.getIncomingOrders(status: 'pending'))
            .thenAnswer((_) async => testOrdersData);

        // Assert
        final expected = [
          isA<IncomingOrderLoading>(),
          isA<IncomingOrderLoaded>().having(
            (s) => s.activeFilter,
            'activeFilter',
            'pending',
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        // Act
        bloc.add(const LoadIncomingOrders(status: 'pending'));
      });

      test('emits [IncomingOrderLoading, IncomingOrderError] when getIncomingOrders fails', () async {
        // Arrange
        when(() => mockRepository.getIncomingOrders(status: any(named: 'status')))
            .thenThrow(Exception('Network error'));

        // Assert
        final expected = [
          isA<IncomingOrderLoading>(),
          isA<IncomingOrderError>(),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        // Act
        bloc.add(const LoadIncomingOrders());
      });
    });

    group('LoadIncomingOrderDetails', () {
      test('emits [IncomingOrderLoading, IncomingOrderDetailsLoaded] when getIncomingOrderDetails succeeds', () async {
        // Arrange
        when(() => mockRepository.getIncomingOrderDetails(any()))
            .thenAnswer((_) async => testOrder);

        // Assert
        final expected = [
          isA<IncomingOrderLoading>(),
          isA<IncomingOrderDetailsLoaded>().having(
            (s) => s.order.id,
            'order.id',
            '1',
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        // Act
        bloc.add(const LoadIncomingOrderDetails('1'));
      });

      test('emits [IncomingOrderLoading, IncomingOrderError] when getIncomingOrderDetails fails with 404', () async {
        // Arrange
        when(() => mockRepository.getIncomingOrderDetails(any()))
            .thenThrow(Exception('404 Not Found'));

        // Assert
        final expected = [
          isA<IncomingOrderLoading>(),
          isA<IncomingOrderError>().having(
            (s) => s.message,
            'message',
            'Colis non trouvé',
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        // Act
        bloc.add(const LoadIncomingOrderDetails('999'));
      });
    });

    group('TrackIncomingOrder', () {
      test('emits IncomingOrderTrackingLoaded when trackOrder succeeds', () async {
        // Arrange
        when(() => mockRepository.trackOrder(any()))
            .thenAnswer((_) async => testTrackingData);

        // Assert
        final expected = [
          isA<IncomingOrderTrackingLoaded>()
              .having((s) => s.orderId, 'orderId', '1')
              .having((s) => s.status, 'status', 'in_transit')
              .having((s) => s.etaMinutes, 'etaMinutes', 30),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        // Act
        bloc.add(const TrackIncomingOrder('1'));
      });

      test('emits IncomingOrderError when trackOrder fails', () async {
        // Arrange
        when(() => mockRepository.trackOrder(any()))
            .thenThrow(Exception('Server error'));

        // Assert
        final expected = [
          isA<IncomingOrderError>(),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        // Act
        bloc.add(const TrackIncomingOrder('1'));
      });
    });

    group('ConfirmIncomingOrderReceipt', () {
      test('emits [IncomingOrderLoading, IncomingOrderReceiptConfirmed] when confirmReceipt succeeds', () async {
        // Arrange
        when(() => mockRepository.confirmReceipt(any(), any()))
            .thenAnswer((_) async {});
        when(() => mockRepository.getIncomingOrderDetails(any()))
            .thenAnswer((_) async => testOrder);

        // Assert
        final expected = [
          isA<IncomingOrderLoading>(),
          isA<IncomingOrderReceiptConfirmed>(),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        // Act
        bloc.add(const ConfirmIncomingOrderReceipt(
          orderId: '1',
          confirmationCode: 'ABC123',
        ));
      });

      test('emits [IncomingOrderLoading, IncomingOrderError] when confirmReceipt fails with 400', () async {
        // Arrange
        when(() => mockRepository.confirmReceipt(any(), any()))
            .thenThrow(Exception('400 Bad Request'));

        // Assert
        final expected = [
          isA<IncomingOrderLoading>(),
          isA<IncomingOrderError>().having(
            (s) => s.message,
            'message',
            'Requête invalide',
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        // Act
        bloc.add(const ConfirmIncomingOrderReceipt(
          orderId: '1',
          confirmationCode: 'WRONG',
        ));
      });
    });

    group('RefreshIncomingOrders', () {
      test('emits IncomingOrderLoaded when refresh succeeds', () async {
        // Arrange
        when(() => mockRepository.getIncomingOrders(status: any(named: 'status')))
            .thenAnswer((_) async => testOrdersData);

        // Assert
        final expected = [
          isA<IncomingOrderLoaded>(),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        // Act
        bloc.add(const RefreshIncomingOrders());
      });

      test('emits IncomingOrderError when refresh fails', () async {
        // Arrange
        when(() => mockRepository.getIncomingOrders(status: any(named: 'status')))
            .thenThrow(Exception('Network error'));

        // Assert
        final expected = [
          isA<IncomingOrderError>(),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        // Act
        bloc.add(const RefreshIncomingOrders());
      });

      test('uses current filter when refreshing', () async {
        // First load with filter
        when(() => mockRepository.getIncomingOrders(status: 'pending'))
            .thenAnswer((_) async => testOrdersData);
        when(() => mockRepository.getIncomingOrders(status: any(named: 'status')))
            .thenAnswer((_) async => testOrdersData);

        bloc.add(const LoadIncomingOrders(status: 'pending'));
        await Future.delayed(const Duration(milliseconds: 150));

        // Now refresh - should use 'pending' filter
        bloc.add(const RefreshIncomingOrders());
        await Future.delayed(const Duration(milliseconds: 150));

        // Verify the filter was used
        verify(() => mockRepository.getIncomingOrders(status: 'pending')).called(2);
      });
    });
  });
}
