import 'package:equatable/equatable.dart';

class Wallet extends Equatable {
  final String id;
  final int balance;
  final String currency;

  const Wallet({
    required this.id,
    required this.balance,
    this.currency = 'XOF',
  });

  @override
  List<Object?> get props => [id, balance, currency];
}
