import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/order/presentation/bloc/order_bloc.dart';
import 'package:ouaga_chap_client/features/order/presentation/bloc/order_event.dart';
import 'package:ouaga_chap_client/features/order/presentation/bloc/order_state.dart';
import 'package:ouaga_chap_client/features/order/domain/usecases/create_order_usecase.dart';
import 'package:ouaga_chap_client/features/order/domain/usecases/get_orders_usecase.dart';
import 'package:ouaga_chap_client/features/order/domain/usecases/get_order_details_usecase.dart';
import 'package:ouaga_chap_client/features/order/domain/usecases/cancel_order_usecase.dart';
import 'package:ouaga_chap_client/features/order/domain/entities/order.dart';

class MockCreateOrderUseCase extends Mock implements CreateOrderUseCase {}
class MockGetOrdersUseCase extends Mock implements GetOrdersUseCase {}
class MockGetOrderDetailsUseCase extends Mock implements GetOrderDetailsUseCase {}
class MockCancelOrderUseCase extends Mock implements CancelOrderUseCase {}

void main() {
  late OrderBloc bloc;
  late MockCreateOrderUseCase mockCreateOrder;
  late MockGetOrdersUseCase mockGetOrders;
  late MockGetOrderDetailsUseCase mockGetOrderDetails;
  late MockCancelOrderUseCase mockCancelOrder;

  setUp(() {
    mockCreateOrder = MockCreateOrderUseCase();
    mockGetOrders = MockGetOrdersUseCase();
    mockGetOrderDetails = MockGetOrderDetailsUseCase();
    mockCancelOrder = MockCancelOrderUseCase();
    
    bloc = OrderBloc(
      createOrderUseCase: mockCreateOrder,
      getOrdersUseCase: mockGetOrders,
      getOrderDetailsUseCase: mockGetOrderDetails,
      cancelOrderUseCase: mockCancelOrder,
    );
  });

  tearDown(() {
    bloc.close();
  });

  final testOrder = Order(
    id: 1,
    trackingNumber: 'TRK-001',
    pickupAddress: 'Ouagadougou Centre',
    pickupLatitude: 12.3686,
    pickupLongitude: -1.5275,
    deliveryAddress: 'Ouaga 2000',
    deliveryLatitude: 12.3486,
    deliveryLongitude: -1.5075,
    recipientName: 'Jean Dupont',
    recipientPhone: '+22670000000',
    packageDescription: 'Documents',
    packageSize: 'small',
    distance: 5.5,
    price: 1600,
    status: OrderStatus.pending,
    createdAt: DateTime(2024, 1, 15),
  );

  final testOrdersList = [
    testOrder,
    Order(
      id: 2,
      trackingNumber: 'TRK-002',
      pickupAddress: 'Place des Nations',
      pickupLatitude: 12.3686,
      pickupLongitude: -1.5275,
      deliveryAddress: 'Koulouba',
      deliveryLatitude: 12.3886,
      deliveryLongitude: -1.5475,
      recipientName: 'Marie Martin',
      recipientPhone: '+22671111111',
      distance: 3.2,
      price: 1140,
      status: OrderStatus.delivered,
      createdAt: DateTime(2024, 1, 14),
    ),
  ];

  group('OrderBloc', () {
    test('initial state is OrderInitial', () {
      expect(bloc.state, isA<OrderInitial>());
    });

    group('CreateOrderRequested', () {
      test('emits [OrderLoading, OrderCreated] when createOrder succeeds', () async {
        // Arrange
        when(() => mockCreateOrder(
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

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<OrderLoading>(),
            isA<OrderCreated>().having((s) => s.order.id, 'order.id', 1),
          ]),
        );

        // Act
        bloc.add(const CreateOrderRequested(
          pickupAddress: 'Ouagadougou Centre',
          pickupLatitude: 12.3686,
          pickupLongitude: -1.5275,
          deliveryAddress: 'Ouaga 2000',
          deliveryLatitude: 12.3486,
          deliveryLongitude: -1.5075,
          recipientName: 'Jean Dupont',
          recipientPhone: '+22670000000',
        ));
      });

      test('emits [OrderLoading, OrderError] when createOrder fails', () async {
        // Arrange
        when(() => mockCreateOrder(
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
        )).thenThrow(Exception('Server error'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<OrderLoading>(),
            isA<OrderError>(),
          ]),
        );

        // Act
        bloc.add(const CreateOrderRequested(
          pickupAddress: 'Ouagadougou Centre',
          pickupLatitude: 12.3686,
          pickupLongitude: -1.5275,
          deliveryAddress: 'Ouaga 2000',
          deliveryLatitude: 12.3486,
          deliveryLongitude: -1.5075,
          recipientName: 'Jean Dupont',
          recipientPhone: '+22670000000',
        ));
      });
    });

    group('GetOrdersRequested', () {
      test('emits [OrderLoading, OrdersLoaded] when getOrders succeeds', () async {
        // Arrange
        when(() => mockGetOrders(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          status: any(named: 'status'),
        )).thenAnswer((_) async => testOrdersList);

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<OrderLoading>(),
            isA<OrdersLoaded>()
                .having((s) => s.orders.length, 'orders.length', 2)
                .having((s) => s.currentPage, 'currentPage', 1),
          ]),
        );

        // Act
        bloc.add(const GetOrdersRequested());
      });

      test('emits [OrderLoading, OrdersLoaded] with hasMore true when perPage items returned', () async {
        // Arrange - Return 10 items (perPage default is 10)
        final manyOrders = List.generate(10, (i) => Order(
          id: i,
          trackingNumber: 'TRK-00$i',
          pickupAddress: 'Address $i',
          pickupLatitude: 12.0,
          pickupLongitude: -1.0,
          deliveryAddress: 'Dest $i',
          deliveryLatitude: 12.1,
          deliveryLongitude: -1.1,
          recipientName: 'Recipient $i',
          recipientPhone: '+22670000$i',
          distance: 1.0,
          price: 1000,
          status: OrderStatus.pending,
          createdAt: DateTime(2024, 1, 15),
        ));
        
        when(() => mockGetOrders(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          status: any(named: 'status'),
        )).thenAnswer((_) async => manyOrders);

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<OrderLoading>(),
            isA<OrdersLoaded>().having((s) => s.hasMore, 'hasMore', true),
          ]),
        );

        // Act
        bloc.add(const GetOrdersRequested());
      });

      test('emits [OrderLoading, OrderError] when getOrders fails', () async {
        // Arrange
        when(() => mockGetOrders(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          status: any(named: 'status'),
        )).thenThrow(Exception('Network error'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<OrderLoading>(),
            isA<OrderError>(),
          ]),
        );

        // Act
        bloc.add(const GetOrdersRequested());
      });

      test('emits OrderError with 404 message when order not found', () async {
        // Arrange
        when(() => mockGetOrders(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          status: any(named: 'status'),
        )).thenThrow(Exception('DioException with status 404'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<OrderLoading>(),
            isA<OrderError>().having(
              (e) => e.message,
              'message',
              'Commande non trouvée',
            ),
          ]),
        );

        // Act
        bloc.add(const GetOrdersRequested());
      });

      test('emits OrderError with 422 message for invalid data', () async {
        // Arrange
        when(() => mockGetOrders(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          status: any(named: 'status'),
        )).thenThrow(Exception('DioException with status 422'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<OrderLoading>(),
            isA<OrderError>().having(
              (e) => e.message,
              'message',
              'Données invalides',
            ),
          ]),
        );

        // Act
        bloc.add(const GetOrdersRequested());
      });

      test('emits OrderError with connection message for network error', () async {
        // Arrange
        when(() => mockGetOrders(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          status: any(named: 'status'),
        )).thenThrow(Exception('DioException connection failed'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<OrderLoading>(),
            isA<OrderError>().having(
              (e) => e.message,
              'message',
              'Erreur de connexion. Vérifiez votre internet.',
            ),
          ]),
        );

        // Act
        bloc.add(const GetOrdersRequested());
      });

      test('appends orders when loading subsequent pages', () async {
        // First page
        when(() => mockGetOrders(
          page: 1,
          perPage: any(named: 'perPage'),
          status: any(named: 'status'),
        )).thenAnswer((_) async => [testOrder]);
        
        bloc.add(const GetOrdersRequested(page: 1));
        await Future.delayed(const Duration(milliseconds: 150));
        
        expect(bloc.state, isA<OrdersLoaded>());
        expect((bloc.state as OrdersLoaded).orders.length, 1);

        // Second page
        when(() => mockGetOrders(
          page: 2,
          perPage: any(named: 'perPage'),
          status: any(named: 'status'),
        )).thenAnswer((_) async => [testOrdersList[1]]);

        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<OrdersLoaded>()
                .having((s) => s.orders.length, 'orders.length', 2)
                .having((s) => s.currentPage, 'currentPage', 2),
          ]),
        );

        // Act
        bloc.add(const GetOrdersRequested(page: 2));
      });

      test('replaces orders when refresh is true', () async {
        // First load
        when(() => mockGetOrders(
          page: any(named: 'page'),
          perPage: any(named: 'perPage'),
          status: any(named: 'status'),
        )).thenAnswer((_) async => testOrdersList);
        
        bloc.add(const GetOrdersRequested());
        await Future.delayed(const Duration(milliseconds: 150));
        
        expect((bloc.state as OrdersLoaded).orders.length, 2);

        // Refresh with single item
        when(() => mockGetOrders(
          page: 1,
          perPage: any(named: 'perPage'),
          status: any(named: 'status'),
        )).thenAnswer((_) async => [testOrder]);

        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<OrderLoading>(),
            isA<OrdersLoaded>().having((s) => s.orders.length, 'orders.length', 1),
          ]),
        );

        // Act
        bloc.add(const GetOrdersRequested(refresh: true));
      });
    });

    group('GetOrderDetailsRequested', () {
      test('emits [OrderLoading, OrderDetailsLoaded] when getOrderDetails succeeds', () async {
        // Arrange
        when(() => mockGetOrderDetails(any()))
            .thenAnswer((_) async => testOrder);

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<OrderLoading>(),
            isA<OrderDetailsLoaded>().having((s) => s.order.id, 'order.id', 1),
          ]),
        );

        // Act
        bloc.add(const GetOrderDetailsRequested(orderId: 1));
      });

      test('emits [OrderLoading, OrderError] when order not found', () async {
        // Arrange
        when(() => mockGetOrderDetails(any()))
            .thenThrow(Exception('Not Found'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<OrderLoading>(),
            isA<OrderError>(),
          ]),
        );

        // Act
        bloc.add(const GetOrderDetailsRequested(orderId: 999));
      });
    });

    group('CancelOrderRequested', () {
      test('emits [OrderLoading, OrderCancelled] when cancelOrder succeeds', () async {
        // Arrange
        when(() => mockCancelOrder(any(), reason: any(named: 'reason')))
            .thenAnswer((_) async {});

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<OrderLoading>(),
            isA<OrderCancelled>().having((s) => s.orderId, 'orderId', 1),
          ]),
        );

        // Act
        bloc.add(const CancelOrderRequested(orderId: 1, reason: 'Changed my mind'));
      });

      test('emits [OrderLoading, OrderError] when cancelOrder fails', () async {
        // Arrange
        when(() => mockCancelOrder(any(), reason: any(named: 'reason')))
            .thenThrow(Exception('Cannot cancel delivered order'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<OrderLoading>(),
            isA<OrderError>(),
          ]),
        );

        // Act
        bloc.add(const CancelOrderRequested(orderId: 1));
      });
    });

    group('CalculatePriceRequested', () {
      test('emits PriceCalculated with calculated distance and price', () async {
        // Assert
        expectLater(
          bloc.stream,
          emits(isA<PriceCalculated>()
              .having((s) => s.distance, 'distance', greaterThan(0))
              .having((s) => s.price, 'price', greaterThan(500))),
        );

        // Act - Ouagadougou coordinates
        bloc.add(const CalculatePriceRequested(
          pickupLatitude: 12.3686,
          pickupLongitude: -1.5275,
          deliveryLatitude: 12.3486,  // ~2.5km away
          deliveryLongitude: -1.5075,
        ));
      });

      test('calculates correct distance between two points', () async {
        // Arrange - Known coordinates in Ouagadougou
        // Approximately 10km apart
        
        bloc.add(const CalculatePriceRequested(
          pickupLatitude: 12.3686,
          pickupLongitude: -1.5275,
          deliveryLatitude: 12.4686,  // ~11km north
          deliveryLongitude: -1.5275,
        ));
        
        await Future.delayed(const Duration(milliseconds: 100));
        
        final state = bloc.state as PriceCalculated;
        
        // Distance should be approximately 11km (10-12km acceptable)
        expect(state.distance, greaterThan(10));
        expect(state.distance, lessThan(12));
        
        // Price = 500 (base) + distance * 200
        // For ~11km: 500 + 11*200 = ~2700 FCFA
        expect(state.price, greaterThan(2500));
        expect(state.price, lessThan(3000));
      });
    });

    group('StartOrderTrackingRequested', () {
      test('emits OrderTracking when getOrderDetails succeeds', () async {
        // Arrange
        when(() => mockGetOrderDetails(any()))
            .thenAnswer((_) async => testOrder);

        // Assert
        expectLater(
          bloc.stream,
          emits(isA<OrderTracking>().having((s) => s.order.id, 'order.id', 1)),
        );

        // Act
        bloc.add(const StartOrderTrackingRequested(orderId: 1));
      });

      test('emits OrderError when tracking fails', () async {
        // Arrange
        when(() => mockGetOrderDetails(any()))
            .thenThrow(Exception('Network error'));

        // Assert
        expectLater(
          bloc.stream,
          emits(isA<OrderError>()),
        );

        // Act
        bloc.add(const StartOrderTrackingRequested(orderId: 1));
      });
    });

    group('StopOrderTrackingRequested', () {
      test('stops tracking without emitting state', () async {
        // First start tracking
        when(() => mockGetOrderDetails(any()))
            .thenAnswer((_) async => testOrder);
        
        bloc.add(const StartOrderTrackingRequested(orderId: 1));
        await Future.delayed(const Duration(milliseconds: 150));
        
        expect(bloc.state, isA<OrderTracking>());

        // Stop tracking - should not emit new state
        bloc.add(StopOrderTrackingRequested());
        await Future.delayed(const Duration(milliseconds: 100));
        
        // State should remain unchanged
        expect(bloc.state, isA<OrderTracking>());
      });
    });
  });
}
