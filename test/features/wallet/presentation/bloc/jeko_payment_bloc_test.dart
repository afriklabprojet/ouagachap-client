import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/wallet/presentation/bloc/jeko_payment_bloc.dart';
import 'package:ouaga_chap_client/features/wallet/presentation/bloc/jeko_payment_event.dart';
import 'package:ouaga_chap_client/features/wallet/presentation/bloc/jeko_payment_state.dart';
import 'package:ouaga_chap_client/features/wallet/data/repositories/jeko_payment_repository.dart';
import 'package:ouaga_chap_client/features/wallet/data/datasources/jeko_payment_datasource.dart';

class MockJekoPaymentRepository extends Mock implements JekoPaymentRepository {}

void main() {
  late JekoPaymentBloc bloc;
  late MockJekoPaymentRepository mockRepository;

  setUp(() {
    mockRepository = MockJekoPaymentRepository();
    bloc = JekoPaymentBloc(mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  final testPaymentMethods = [
    JekoPaymentMethod(code: 'orange_money', name: 'Orange Money', icon: '🍊'),
    JekoPaymentMethod(code: 'moov_money', name: 'Moov Money', icon: '📱'),
  ];

  final testTransaction = JekoTransaction(
    id: 1,
    jekoId: 'JEKO123',
    reference: 'REF001',
    type: 'wallet_recharge',
    amount: 5000,
    currency: 'XOF',
    fees: 100,
    status: 'pending',
    statusLabel: 'En attente',
    paymentMethod: 'orange_money',
    paymentMethodName: 'Orange Money',
    createdAt: DateTime(2024, 1, 15),
  );

  final testSuccessfulTransaction = JekoTransaction(
    id: 1,
    jekoId: 'JEKO123',
    reference: 'REF001',
    type: 'wallet_recharge',
    amount: 5000,
    currency: 'XOF',
    fees: 100,
    status: 'success',
    statusLabel: 'Réussi',
    paymentMethod: 'orange_money',
    paymentMethodName: 'Orange Money',
    createdAt: DateTime(2024, 1, 15),
    executedAt: DateTime(2024, 1, 15, 10, 30),
  );

  final testPaymentResult = JekoPaymentResult(
    success: true,
    message: 'Paiement initié',
    transactionId: 1,
    jekoId: 'JEKO123',
    redirectUrl: 'https://pay.jeko.com/123',
    amount: 5000,
    paymentMethod: 'orange_money',
  );

  final testFailedPaymentResult = JekoPaymentResult(
    success: false,
    message: 'Solde insuffisant',
  );

  group('JekoPaymentBloc', () {
    test('initial state is correct', () {
      expect(bloc.state.status, JekoPaymentStatus.initial);
      expect(bloc.state.paymentMethods, isEmpty);
      expect(bloc.state.paymentResult, isNull);
    });

    group('LoadPaymentMethods', () {
      test('emits methodsLoaded when getPaymentMethods succeeds', () async {
        // Arrange
        when(() => mockRepository.getPaymentMethods())
            .thenAnswer((_) async => testPaymentMethods);

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.loadingMethods),
            predicate<JekoPaymentState>((s) => 
                s.status == JekoPaymentStatus.methodsLoaded && 
                s.paymentMethods.length == 2),
          ]),
        );

        // Act
        bloc.add(LoadPaymentMethods());
      });

      test('emits error when getPaymentMethods fails', () async {
        // Arrange
        when(() => mockRepository.getPaymentMethods())
            .thenThrow(Exception('Network error'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.loadingMethods),
            predicate<JekoPaymentState>((s) => 
                s.status == JekoPaymentStatus.error && 
                s.errorMessage != null),
          ]),
        );

        // Act
        bloc.add(LoadPaymentMethods());
      });
    });

    group('InitiateWalletRecharge', () {
      test('emits paymentInitiated when initiateWalletRecharge succeeds', () async {
        // Arrange
        when(() => mockRepository.initiateWalletRecharge(
          amount: any(named: 'amount'),
          paymentMethod: any(named: 'paymentMethod'),
        )).thenAnswer((_) async => testPaymentResult);

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.initiatingPayment),
            predicate<JekoPaymentState>((s) => 
                s.status == JekoPaymentStatus.paymentInitiated && 
                s.paymentResult?.success == true),
          ]),
        );

        // Act
        bloc.add(const InitiateWalletRecharge(amount: 5000, paymentMethod: 'orange_money'));
      });

      test('emits error when initiateWalletRecharge returns unsuccessful result', () async {
        // Arrange
        when(() => mockRepository.initiateWalletRecharge(
          amount: any(named: 'amount'),
          paymentMethod: any(named: 'paymentMethod'),
        )).thenAnswer((_) async => testFailedPaymentResult);

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.initiatingPayment),
            predicate<JekoPaymentState>((s) => 
                s.status == JekoPaymentStatus.error && 
                s.errorMessage == 'Solde insuffisant'),
          ]),
        );

        // Act
        bloc.add(const InitiateWalletRecharge(amount: 5000, paymentMethod: 'orange_money'));
      });

      test('emits error when initiateWalletRecharge throws', () async {
        // Arrange
        when(() => mockRepository.initiateWalletRecharge(
          amount: any(named: 'amount'),
          paymentMethod: any(named: 'paymentMethod'),
        )).thenThrow(Exception('Server error'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.initiatingPayment),
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.error),
          ]),
        );

        // Act
        bloc.add(const InitiateWalletRecharge(amount: 5000, paymentMethod: 'orange_money'));
      });
    });

    group('InitiateOrderPayment', () {
      test('emits paymentInitiated when initiateOrderPayment succeeds', () async {
        // Arrange
        when(() => mockRepository.initiateOrderPayment(
          orderId: any(named: 'orderId'),
          paymentMethod: any(named: 'paymentMethod'),
        )).thenAnswer((_) async => testPaymentResult);

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.initiatingPayment),
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.paymentInitiated),
          ]),
        );

        // Act
        bloc.add(const InitiateOrderPayment(orderId: '123', paymentMethod: 'orange_money'));
      });

      test('emits error when initiateOrderPayment returns failure', () async {
        // Arrange
        when(() => mockRepository.initiateOrderPayment(
          orderId: any(named: 'orderId'),
          paymentMethod: any(named: 'paymentMethod'),
        )).thenAnswer((_) async => testFailedPaymentResult);

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.initiatingPayment),
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.error),
          ]),
        );

        // Act
        bloc.add(const InitiateOrderPayment(orderId: '123', paymentMethod: 'orange_money'));
      });

      test('emits error when initiateOrderPayment throws', () async {
        // Arrange
        when(() => mockRepository.initiateOrderPayment(
          orderId: any(named: 'orderId'),
          paymentMethod: any(named: 'paymentMethod'),
        )).thenThrow(Exception('Server error'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.initiatingPayment),
            predicate<JekoPaymentState>((s) => 
                s.status == JekoPaymentStatus.error && 
                s.errorMessage != null),
          ]),
        );

        // Act
        bloc.add(const InitiateOrderPayment(orderId: '123', paymentMethod: 'orange_money'));
      });
    });

    group('CheckTransactionStatus', () {
      test('emits statusChecked when checkTransactionStatus succeeds', () async {
        // Arrange
        when(() => mockRepository.checkTransactionStatus(any()))
            .thenAnswer((_) async => testTransaction);

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.checkingStatus),
            predicate<JekoPaymentState>((s) => 
                s.status == JekoPaymentStatus.statusChecked && 
                s.currentTransaction?.id == 1),
          ]),
        );

        // Act
        bloc.add(const CheckTransactionStatus(1));
      });

      test('emits error when checkTransactionStatus fails', () async {
        // Arrange
        when(() => mockRepository.checkTransactionStatus(any()))
            .thenThrow(Exception('Transaction not found'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.checkingStatus),
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.error),
          ]),
        );

        // Act
        bloc.add(const CheckTransactionStatus(999));
      });
    });

    group('LoadTransactionHistory', () {
      test('emits historyLoaded when getTransactionHistory succeeds', () async {
        // Arrange
        when(() => mockRepository.getTransactionHistory(page: any(named: 'page')))
            .thenAnswer((_) async => [testTransaction]);

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.loadingHistory),
            predicate<JekoPaymentState>((s) => 
                s.status == JekoPaymentStatus.historyLoaded && 
                s.transactionHistory.length == 1),
          ]),
        );

        // Act
        bloc.add(const LoadTransactionHistory());
      });

      test('appends to history when loading page > 1', () async {
        // Arrange - first load
        when(() => mockRepository.getTransactionHistory(page: 1))
            .thenAnswer((_) async => [testTransaction]);
        when(() => mockRepository.getTransactionHistory(page: 2))
            .thenAnswer((_) async => [testSuccessfulTransaction]);

        // First load
        bloc.add(const LoadTransactionHistory(page: 1));
        await Future.delayed(const Duration(milliseconds: 150));
        
        expect(bloc.state.transactionHistory.length, 1);

        // Load page 2
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.loadingHistory),
            predicate<JekoPaymentState>((s) => 
                s.status == JekoPaymentStatus.historyLoaded && 
                s.transactionHistory.length == 2 &&
                s.currentPage == 2),
          ]),
        );

        bloc.add(const LoadTransactionHistory(page: 2));
      });

      test('sets hasMoreHistory to false when less than 20 transactions returned', () async {
        // Arrange
        when(() => mockRepository.getTransactionHistory(page: any(named: 'page')))
            .thenAnswer((_) async => [testTransaction]); // Only 1 transaction

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.loadingHistory),
            predicate<JekoPaymentState>((s) => 
                s.status == JekoPaymentStatus.historyLoaded && 
                s.hasMoreHistory == false),
          ]),
        );

        // Act
        bloc.add(const LoadTransactionHistory());
      });

      test('emits error when getTransactionHistory fails', () async {
        // Arrange
        when(() => mockRepository.getTransactionHistory(page: any(named: 'page')))
            .thenThrow(Exception('Network error'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.loadingHistory),
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.error),
          ]),
        );

        // Act
        bloc.add(const LoadTransactionHistory());
      });
    });

    group('PaymentSuccessCallback', () {
      test('emits success when paymentSuccessCallback succeeds', () async {
        // Arrange
        when(() => mockRepository.paymentSuccessCallback(any()))
            .thenAnswer((_) async => testSuccessfulTransaction);

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.checkingStatus),
            predicate<JekoPaymentState>((s) => 
                s.status == JekoPaymentStatus.success && 
                s.currentTransaction?.status == 'success'),
          ]),
        );

        // Act
        bloc.add(const PaymentSuccessCallback(1));
      });

      test('emits error when paymentSuccessCallback fails', () async {
        // Arrange
        when(() => mockRepository.paymentSuccessCallback(any()))
            .thenThrow(Exception('Callback failed'));

        // Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.checkingStatus),
            predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.error),
          ]),
        );

        // Act
        bloc.add(const PaymentSuccessCallback(1));
      });
    });

    group('PaymentErrorCallback', () {
      test('emits error state when called', () async {
        // Arrange
        when(() => mockRepository.paymentErrorCallback(any()))
            .thenAnswer((_) async {});

        // Assert
        expectLater(
          bloc.stream,
          emits(predicate<JekoPaymentState>((s) => 
              s.status == JekoPaymentStatus.error && 
              s.errorMessage == 'Le paiement a échoué ou a été annulé')),
        );

        // Act
        bloc.add(const PaymentErrorCallback(1));
      });

      test('emits error even when paymentErrorCallback throws', () async {
        // Arrange
        when(() => mockRepository.paymentErrorCallback(any()))
            .thenThrow(Exception('Network error'));

        // Assert
        expectLater(
          bloc.stream,
          emits(predicate<JekoPaymentState>((s) => s.status == JekoPaymentStatus.error)),
        );

        // Act
        bloc.add(const PaymentErrorCallback(1));
      });
    });

    group('ResetPaymentState', () {
      test('resets state to initial', () async {
        // First initiate a payment
        when(() => mockRepository.getPaymentMethods())
            .thenAnswer((_) async => testPaymentMethods);
        
        bloc.add(LoadPaymentMethods());
        await Future.delayed(const Duration(milliseconds: 150));
        
        expect(bloc.state.status, JekoPaymentStatus.methodsLoaded);

        // Reset
        expectLater(
          bloc.stream,
          emits(predicate<JekoPaymentState>((s) => 
              s.status == JekoPaymentStatus.initial &&
              s.paymentResult == null &&
              s.currentTransaction == null &&
              s.errorMessage == null)),
        );

        bloc.add(ResetPaymentState());
      });
    });
  });
}
