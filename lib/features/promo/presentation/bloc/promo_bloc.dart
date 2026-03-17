import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/promo_repository.dart';
import 'promo_event.dart';
import 'promo_state.dart';

class PromoBloc extends Bloc<PromoEvent, PromoState> {
  final PromoRepository _repository;

  PromoBloc(this._repository) : super(const PromoState()) {
    on<LoadPromoCodes>(_onLoadPromoCodes);
    on<ValidatePromoCode>(_onValidatePromoCode);
    on<ApplyPromoCode>(_onApplyPromoCode);
  }

  Future<void> _onLoadPromoCodes(
    LoadPromoCodes event,
    Emitter<PromoState> emit,
  ) async {
    emit(state.copyWith(status: PromoStatus.loading));
    try {
      final promoCodes = await _repository.getAvailablePromoCodes();
      emit(state.copyWith(status: PromoStatus.loaded, promoCodes: promoCodes));
    } catch (e) {
      emit(state.copyWith(
        status: PromoStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onValidatePromoCode(
    ValidatePromoCode event,
    Emitter<PromoState> emit,
  ) async {
    emit(state.copyWith(isValidating: true));
    try {
      final result = await _repository.validatePromoCode(
        code: event.code,
        orderAmount: event.orderAmount,
        zoneId: event.zoneId,
      );
      emit(state.copyWith(isValidating: false, validationResult: result));
    } catch (e) {
      emit(state.copyWith(
        isValidating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onApplyPromoCode(
    ApplyPromoCode event,
    Emitter<PromoState> emit,
  ) async {
    emit(state.copyWith(isValidating: true));
    try {
      await _repository.applyPromoCode(
        code: event.code,
        orderId: event.orderId,
      );
      emit(state.copyWith(isValidating: false));
    } catch (e) {
      emit(state.copyWith(
        isValidating: false,
        errorMessage: e.toString(),
      ));
    }
  }
}
