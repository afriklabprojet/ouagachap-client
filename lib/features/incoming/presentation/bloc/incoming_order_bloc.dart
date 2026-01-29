import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/incoming_order_repository.dart';
import '../../domain/entities/incoming_order.dart';
import 'incoming_order_event.dart';
import 'incoming_order_state.dart';

class IncomingOrderBloc extends Bloc<IncomingOrderEvent, IncomingOrderState> {
  final IncomingOrderRepository _repository;
  String? _currentFilter;

  IncomingOrderBloc(this._repository) : super(const IncomingOrderInitial()) {
    on<LoadIncomingOrders>(_onLoadIncomingOrders);
    on<LoadIncomingOrderDetails>(_onLoadDetails);
    on<TrackIncomingOrder>(_onTrackOrder);
    on<ConfirmIncomingOrderReceipt>(_onConfirmReceipt);
    on<RefreshIncomingOrders>(_onRefresh);
  }

  Future<void> _onLoadIncomingOrders(
    LoadIncomingOrders event,
    Emitter<IncomingOrderState> emit,
  ) async {
    emit(const IncomingOrderLoading());
    
    try {
      _currentFilter = event.status;
      final result = await _repository.getIncomingOrders(status: event.status);
      
      emit(IncomingOrderLoaded(
        orders: result['orders'] as List<IncomingOrder>,
        stats: result['stats'] as IncomingOrderStats,
        activeFilter: event.status,
      ));
    } catch (e) {
      emit(IncomingOrderError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onLoadDetails(
    LoadIncomingOrderDetails event,
    Emitter<IncomingOrderState> emit,
  ) async {
    emit(const IncomingOrderLoading());
    
    try {
      final order = await _repository.getIncomingOrderDetails(event.orderId);
      emit(IncomingOrderDetailsLoaded(order));
    } catch (e) {
      emit(IncomingOrderError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onTrackOrder(
    TrackIncomingOrder event,
    Emitter<IncomingOrderState> emit,
  ) async {
    try {
      final data = await _repository.trackOrder(event.orderId);
      
      emit(IncomingOrderTrackingLoaded(
        orderId: data['order_id'] as String,
        orderNumber: data['order_number'] as String,
        status: data['status'] as String,
        statusLabel: data['status_label'] as String,
        courier: data['courier'] as Map<String, dynamic>,
        destination: data['destination'] as Map<String, dynamic>,
        etaMinutes: data['eta_minutes'] as int?,
        etaText: data['eta_text'] as String,
      ));
    } catch (e) {
      emit(IncomingOrderError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onConfirmReceipt(
    ConfirmIncomingOrderReceipt event,
    Emitter<IncomingOrderState> emit,
  ) async {
    emit(const IncomingOrderLoading());
    
    try {
      await _repository.confirmReceipt(event.orderId, event.confirmationCode);
      emit(const IncomingOrderReceiptConfirmed(
        'Réception confirmée ! Le coursier a été notifié.',
      ));
      
      // Recharger les détails après confirmation
      add(LoadIncomingOrderDetails(event.orderId));
    } catch (e) {
      emit(IncomingOrderError(_extractErrorMessage(e)));
    }
  }

  Future<void> _onRefresh(
    RefreshIncomingOrders event,
    Emitter<IncomingOrderState> emit,
  ) async {
    try {
      final result = await _repository.getIncomingOrders(status: _currentFilter);
      
      emit(IncomingOrderLoaded(
        orders: result['orders'] as List<IncomingOrder>,
        stats: result['stats'] as IncomingOrderStats,
        activeFilter: _currentFilter,
      ));
    } catch (e) {
      emit(IncomingOrderError(_extractErrorMessage(e)));
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error.toString().contains('404')) {
      return 'Colis non trouvé';
    }
    if (error.toString().contains('400')) {
      return 'Requête invalide';
    }
    return 'Une erreur est survenue';
  }
}
