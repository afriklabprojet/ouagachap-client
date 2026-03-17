import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/error_helpers.dart';
import '../../data/repositories/promo_repository.dart';
import 'promo_event.dart';
import 'promo_state.dart';

class PromoBloc extends Bloc<PromoEvent, PromoState> {
  final PromoRepository _repository;

  PromoBloc(this._repository) : super(const PromoState()) {
    on<LoadPromoCodes>(_onLoadPromoCodes, transformer: restartable());
    on<ValidatePromoCode>(_onValidatePromoCode, transformer: droppable());
    // droppable() → empêche d'appliquer le code promo deux fois
    on<ApplyPromoCode>(_onApplyPromoCode, transformer: droppable());
  }

  Future<void> _onLoadPromoCodes(
    LoadPromoCodes event,
    Emitter<PromoState> emit,
  ) async {
    emit(state.copyWith(status: PromoStatus.loading));
    try {
      final promoCodes = await _repository.getAvailablePromoCodes();
      if (isClosed) return;
      emit(state.copyWith(status: PromoStatus.loaded, promoCodes: promoCodes));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        status: PromoStatus.error,
        errorMessage: extractUserFriendlyError(e),
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
      if (isClosed) return;
      emit(state.copyWith(isValidating: false, validationResult: result));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        isValidating: false,
        errorMessage: extractUserFriendlyError(e),
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
      if (isClosed) return;
      emit(state.copyWith(isValidating: false));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        isValidating: false,
        errorMessage: extractUserFriendlyError(e),
      ));
    }
  }
}
