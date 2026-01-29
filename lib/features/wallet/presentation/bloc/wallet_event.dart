import 'package:equatable/equatable.dart';

abstract class WalletEvent extends Equatable {
  const WalletEvent();

  @override
  List<Object?> get props => [];
}

class LoadWallet extends WalletEvent {
  const LoadWallet();
}

class InitiateRecharge extends WalletEvent {
  final int amount;
  final String provider;
  final String phoneNumber;

  const InitiateRecharge({
    required this.amount,
    required this.provider,
    required this.phoneNumber,
  });

  @override
  List<Object?> get props => [amount, provider, phoneNumber];
}
