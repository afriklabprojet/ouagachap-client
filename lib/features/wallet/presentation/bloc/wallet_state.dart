import 'package:equatable/equatable.dart';
import '../../domain/entities/wallet.dart';

abstract class WalletState extends Equatable {
  const WalletState();

  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {}

class WalletLoading extends WalletState {}

class WalletLoaded extends WalletState {
  final Wallet wallet;

  const WalletLoaded({required this.wallet});

  @override
  List<Object?> get props => [wallet];
}

class WalletError extends WalletState {
  final String message;

  const WalletError({required this.message});

  @override
  List<Object?> get props => [message];
}

class RechargeLoading extends WalletState {
  final Wallet? currentWallet;

  const RechargeLoading({this.currentWallet});

  @override
  List<Object?> get props => [currentWallet];
}

class RechargeSuccess extends WalletState {
  final String message;
  final Wallet? wallet;

  const RechargeSuccess({required this.message, this.wallet});

  @override
  List<Object?> get props => [message, wallet];
}

class RechargeError extends WalletState {
  final String message;
  final Wallet? currentWallet;

  const RechargeError({required this.message, this.currentWallet});

  @override
  List<Object?> get props => [message, currentWallet];
}
