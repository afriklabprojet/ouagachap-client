import 'package:equatable/equatable.dart';

abstract class PromoEvent extends Equatable {
  const PromoEvent();

  @override
  List<Object?> get props => [];
}

class LoadPromoCodes extends PromoEvent {
  const LoadPromoCodes();
}

class ValidatePromoCode extends PromoEvent {
  final String code;
  final double orderAmount;
  final int? zoneId;

  const ValidatePromoCode({
    required this.code,
    required this.orderAmount,
    this.zoneId,
  });

  @override
  List<Object?> get props => [code, orderAmount, zoneId];
}

class ApplyPromoCode extends PromoEvent {
  final String code;
  final String orderId;

  const ApplyPromoCode({
    required this.code,
    required this.orderId,
  });

  @override
  List<Object?> get props => [code, orderId];
}
