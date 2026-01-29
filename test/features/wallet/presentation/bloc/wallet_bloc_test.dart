import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/wallet/presentation/bloc/wallet_bloc.dart';
import 'package:ouaga_chap_client/features/wallet/presentation/bloc/wallet_event.dart';
import 'package:ouaga_chap_client/features/wallet/presentation/bloc/wallet_state.dart';
import 'package:ouaga_chap_client/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:ouaga_chap_client/features/wallet/domain/entities/wallet.dart';

class MockWalletRepository extends Mock implements WalletRepository {}

void main() {
  late WalletBloc bloc;
  late MockWalletRepository mockRepository;

  setUp(() {
    mockRepository = MockWalletRepository();
    bloc = WalletBloc(walletRepository: mockRepository);
  });

  tearDown(() {
    bloc.close();
  });

  const testWallet = Wallet(id: '1', balance: 5000, currency: 'XOF');
  const updatedWallet = Wallet(id: '1', balance: 10000, currency: 'XOF');

  group('WalletBloc', () {
    test('initial state is WalletInitial', () {
      expect(bloc.state, isA<WalletInitial>());
    });

    group('LoadWallet', () {
      test('emits [WalletLoading, WalletLoaded] when getWallet succeeds', () async {
        // Arrange
        when(() => mockRepository.getWallet()).thenAnswer((_) async => testWallet);

        // Assert
        final expected = [
          isA<WalletLoading>(),
          isA<WalletLoaded>().having(
            (state) => state.wallet,
            'wallet',
            testWallet,
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        // Act
        bloc.add(const LoadWallet());
      });

      test('emits [WalletLoading, WalletError] when getWallet fails', () async {
        // Arrange
        when(() => mockRepository.getWallet()).thenThrow(Exception('Network error'));

        // Assert
        final expected = [
          isA<WalletLoading>(),
          isA<WalletError>().having(
            (state) => state.message,
            'message',
            contains('Exception'),
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        // Act
        bloc.add(const LoadWallet());
      });
    });

    group('InitiateRecharge', () {
      test('emits [RechargeLoading, RechargeSuccess] when initiateRecharge succeeds', () async {
        // Arrange
        when(() => mockRepository.initiateRecharge(
          amount: any(named: 'amount'),
          provider: any(named: 'provider'),
          phoneNumber: any(named: 'phoneNumber'),
        )).thenAnswer((_) async => {'message': 'Recharge réussie', 'success': true});
        
        when(() => mockRepository.getWallet()).thenAnswer((_) async => updatedWallet);

        // Assert
        final expected = [
          isA<RechargeLoading>(),
          isA<RechargeSuccess>().having(
            (state) => state.message,
            'message',
            'Recharge réussie',
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        // Act
        bloc.add(const InitiateRecharge(
          amount: 5000,
          provider: 'orange_money',
          phoneNumber: '+22670000000',
        ));
      });

      test('emits [RechargeLoading, RechargeSuccess] with default message when response has no message', () async {
        // Arrange
        when(() => mockRepository.initiateRecharge(
          amount: any(named: 'amount'),
          provider: any(named: 'provider'),
          phoneNumber: any(named: 'phoneNumber'),
        )).thenAnswer((_) async => {'success': true});
        
        when(() => mockRepository.getWallet()).thenAnswer((_) async => updatedWallet);

        // Assert
        final expected = [
          isA<RechargeLoading>(),
          isA<RechargeSuccess>().having(
            (state) => state.message,
            'message',
            'Recharge initiée avec succès',
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        // Act
        bloc.add(const InitiateRecharge(
          amount: 5000,
          provider: 'orange_money',
          phoneNumber: '+22670000000',
        ));
      });

      test('emits [RechargeLoading, RechargeError] when initiateRecharge fails', () async {
        // Arrange
        when(() => mockRepository.initiateRecharge(
          amount: any(named: 'amount'),
          provider: any(named: 'provider'),
          phoneNumber: any(named: 'phoneNumber'),
        )).thenThrow(Exception('Payment failed'));

        // Assert
        final expected = [
          isA<RechargeLoading>(),
          isA<RechargeError>().having(
            (state) => state.message,
            'message',
            contains('Payment failed'),
          ),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        // Act
        bloc.add(const InitiateRecharge(
          amount: 5000,
          provider: 'orange_money',
          phoneNumber: '+22670000000',
        ));
      });

      test('emits RechargeSuccess with currentWallet when getWallet fails after successful recharge', () async {
        // First load the wallet
        when(() => mockRepository.getWallet()).thenAnswer((_) async => testWallet);
        bloc.add(const LoadWallet());
        await Future.delayed(const Duration(milliseconds: 100));

        // Now setup recharge to succeed but getWallet to fail
        when(() => mockRepository.initiateRecharge(
          amount: any(named: 'amount'),
          provider: any(named: 'provider'),
          phoneNumber: any(named: 'phoneNumber'),
        )).thenAnswer((_) async => {'message': 'Recharge réussie'});
        
        when(() => mockRepository.getWallet()).thenThrow(Exception('Network error'));

        // Assert - we expect RechargeSuccess with the old wallet
        final expected = [
          isA<RechargeLoading>(),
          isA<RechargeSuccess>(),
        ];

        expectLater(bloc.stream, emitsInOrder(expected));

        // Act
        bloc.add(const InitiateRecharge(
          amount: 5000,
          provider: 'orange_money',
          phoneNumber: '+22670000000',
        ));
      });

      test('preserves current wallet in RechargeLoading state', () async {
        // First load the wallet to have a current state
        when(() => mockRepository.getWallet()).thenAnswer((_) async => testWallet);
        bloc.add(const LoadWallet());
        
        // Wait for the wallet to be loaded
        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<WalletLoading>(),
            isA<WalletLoaded>(),
          ]),
        );

        // Setup for recharge
        when(() => mockRepository.initiateRecharge(
          amount: any(named: 'amount'),
          provider: any(named: 'provider'),
          phoneNumber: any(named: 'phoneNumber'),
        )).thenAnswer((_) async => {'message': 'Success'});

        // Assert RechargeLoading has currentWallet
        expectLater(
          bloc.stream,
          emitsThrough(isA<RechargeLoading>().having(
            (state) => state.currentWallet,
            'currentWallet',
            testWallet,
          )),
        );

        // Act
        bloc.add(const InitiateRecharge(
          amount: 5000,
          provider: 'orange_money',
          phoneNumber: '+22670000000',
        ));
      });
    });
  });
}
