import 'package:equatable/equatable.dart';

import '../../domain/entities/promo_code.dart';

enum PromoStatus { initial, loading, loaded, error }

class PromoState extends Equatable {
  final PromoStatus status;
  final List<PromoCode> promoCodes;
  final String? errorMessage;
  final Map<String, dynamic>? validationResult;
  final bool isValidating;

  const PromoState({
    this.status = PromoStatus.initial,
    this.promoCodes = const [],
    this.errorMessage,
    this.validationResult,
    this.isValidating = false,
  });

  PromoState copyWith({
    PromoStatus? status,
    List<PromoCode>? promoCodes,
    String? errorMessage,
    Map<String, dynamic>? validationResult,
    bool? isValidating,
  }) {
    return PromoState(
      status: status ?? this.status,
      promoCodes: promoCodes ?? this.promoCodes,
      errorMessage: errorMessage,
      validationResult: validationResult ?? this.validationResult,
      isValidating: isValidating ?? this.isValidating,
    );
  }

  @override
  List<Object?> get props =>
      [status, promoCodes, errorMessage, validationResult, isValidating];
}
