import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/services/geocoding_service.dart';

// ---------------------------------------------------------------------------
// State
// ---------------------------------------------------------------------------

class CreateOrderFormState extends Equatable {
  final int currentStep;

  // Pickup
  final double pickupLatitude;
  final double pickupLongitude;
  final bool pickupCoordsSet;

  // Delivery
  final double deliveryLatitude;
  final double deliveryLongitude;
  final bool deliveryCoordsSet;
  final String selectedPackageSize;

  // Payment
  final String selectedPaymentMethod;

  // Price
  final double estimatedPrice;
  final double estimatedDistance;
  final double basePrice;
  final double distancePrice;
  final bool isSurge;
  final double surgeMultiplier;

  // Flags
  final bool isGpsLoading;
  final bool orderCreated;

  // Error/info messages (null = pas de message)
  final String? errorMessage;
  final String? infoMessage;

  const CreateOrderFormState({
    this.currentStep = 0,
    this.pickupLatitude = 12.3714,
    this.pickupLongitude = -1.5197,
    this.pickupCoordsSet = false,
    this.deliveryLatitude = 12.3814,
    this.deliveryLongitude = -1.5097,
    this.deliveryCoordsSet = false,
    this.selectedPackageSize = 'small',
    this.selectedPaymentMethod = 'cash',
    this.estimatedPrice = 0,
    this.estimatedDistance = 0,
    this.basePrice = 0,
    this.distancePrice = 0,
    this.isSurge = false,
    this.surgeMultiplier = 1.0,
    this.isGpsLoading = false,
    this.orderCreated = false,
    this.errorMessage,
    this.infoMessage,
  });

  CreateOrderFormState copyWith({
    int? currentStep,
    double? pickupLatitude,
    double? pickupLongitude,
    bool? pickupCoordsSet,
    double? deliveryLatitude,
    double? deliveryLongitude,
    bool? deliveryCoordsSet,
    String? selectedPackageSize,
    String? selectedPaymentMethod,
    double? estimatedPrice,
    double? estimatedDistance,
    double? basePrice,
    double? distancePrice,
    bool? isSurge,
    double? surgeMultiplier,
    bool? isGpsLoading,
    bool? orderCreated,
    String? errorMessage,
    String? infoMessage,
    bool clearError = false,
    bool clearInfo = false,
  }) {
    return CreateOrderFormState(
      currentStep: currentStep ?? this.currentStep,
      pickupLatitude: pickupLatitude ?? this.pickupLatitude,
      pickupLongitude: pickupLongitude ?? this.pickupLongitude,
      pickupCoordsSet: pickupCoordsSet ?? this.pickupCoordsSet,
      deliveryLatitude: deliveryLatitude ?? this.deliveryLatitude,
      deliveryLongitude: deliveryLongitude ?? this.deliveryLongitude,
      deliveryCoordsSet: deliveryCoordsSet ?? this.deliveryCoordsSet,
      selectedPackageSize: selectedPackageSize ?? this.selectedPackageSize,
      selectedPaymentMethod:
          selectedPaymentMethod ?? this.selectedPaymentMethod,
      estimatedPrice: estimatedPrice ?? this.estimatedPrice,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      basePrice: basePrice ?? this.basePrice,
      distancePrice: distancePrice ?? this.distancePrice,
      isSurge: isSurge ?? this.isSurge,
      surgeMultiplier: surgeMultiplier ?? this.surgeMultiplier,
      isGpsLoading: isGpsLoading ?? this.isGpsLoading,
      orderCreated: orderCreated ?? this.orderCreated,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      infoMessage: clearInfo ? null : (infoMessage ?? this.infoMessage),
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    pickupLatitude,
    pickupLongitude,
    pickupCoordsSet,
    deliveryLatitude,
    deliveryLongitude,
    deliveryCoordsSet,
    selectedPackageSize,
    selectedPaymentMethod,
    estimatedPrice,
    estimatedDistance,
    basePrice,
    distancePrice,
    isSurge,
    surgeMultiplier,
    isGpsLoading,
    orderCreated,
    errorMessage,
    infoMessage,
  ];
}

// ---------------------------------------------------------------------------
// Données de coordonnées (callback data)
// ---------------------------------------------------------------------------

class CoordsData {
  final double latitude;
  final double longitude;
  final bool coordsSet;

  const CoordsData({
    required this.latitude,
    required this.longitude,
    required this.coordsSet,
  });
}

// ---------------------------------------------------------------------------
// Cubit
// ---------------------------------------------------------------------------

class CreateOrderFormCubit extends Cubit<CreateOrderFormState> {
  final GeocodingService _geocodingService;

  CreateOrderFormCubit({required GeocodingService geocodingService})
    : _geocodingService = geocodingService,
      super(const CreateOrderFormState());

  // -----------------------------------------------------------------------
  // Step navigation
  // -----------------------------------------------------------------------

  /// Valide l'étape courante puis avance. Retourne true si la page
  /// peut animer vers l'étape suivante.
  bool validateAndAdvance({
    required String pickupAddress,
    required String deliveryAddress,
    required String recipientName,
    required String recipientPhone,
  }) {
    if (state.currentStep >= 2) return false;

    final valid = _validateStep(
      step: state.currentStep,
      pickupAddress: pickupAddress,
      deliveryAddress: deliveryAddress,
      recipientName: recipientName,
      recipientPhone: recipientPhone,
    );

    if (!valid) return false;

    final nextStep = state.currentStep + 1;
    emit(
      state.copyWith(currentStep: nextStep, clearError: true, clearInfo: true),
    );

    if (nextStep == 2) {
      // Signal que le prix doit être calculé — la page dispatche l'event OrderBloc
      emit(state.copyWith(currentStep: nextStep));
    }

    return true;
  }

  void goBack() {
    if (state.currentStep > 0) {
      emit(
        state.copyWith(
          currentStep: state.currentStep - 1,
          clearError: true,
          clearInfo: true,
        ),
      );
    }
  }

  // -----------------------------------------------------------------------
  // Validation
  // -----------------------------------------------------------------------

  bool _validateStep({
    required int step,
    required String pickupAddress,
    required String deliveryAddress,
    required String recipientName,
    required String recipientPhone,
  }) {
    switch (step) {
      case 0:
        if (pickupAddress.isEmpty) {
          emit(
            state.copyWith(
              errorMessage: 'Veuillez entrer l\'adresse de récupération',
            ),
          );
          return false;
        }
        if (!state.pickupCoordsSet) {
          autoGeocodeAndProceed(
            address: pickupAddress,
            isPickup: true,
            deliveryAddress: deliveryAddress,
            recipientName: recipientName,
            recipientPhone: recipientPhone,
          );
          return false;
        }
        return true;
      case 1:
        if (deliveryAddress.isEmpty) {
          emit(
            state.copyWith(
              errorMessage: 'Veuillez entrer l\'adresse de livraison',
            ),
          );
          return false;
        }
        if (!state.deliveryCoordsSet) {
          autoGeocodeAndProceed(
            address: deliveryAddress,
            isPickup: false,
            deliveryAddress: deliveryAddress,
            recipientName: recipientName,
            recipientPhone: recipientPhone,
          );
          return false;
        }
        if (recipientName.isEmpty) {
          emit(
            state.copyWith(
              errorMessage: 'Veuillez entrer le nom du destinataire',
            ),
          );
          return false;
        }
        if (recipientPhone.isEmpty) {
          emit(
            state.copyWith(
              errorMessage: 'Veuillez entrer le téléphone du destinataire',
            ),
          );
          return false;
        }
        final digits = recipientPhone.replaceAll(' ', '');
        if (digits.length != 8) {
          emit(
            state.copyWith(
              errorMessage:
                  'Le numéro du destinataire doit contenir 8 chiffres',
            ),
          );
          return false;
        }
        return true;
      default:
        return true;
    }
  }

  // -----------------------------------------------------------------------
  // Geocoding
  // -----------------------------------------------------------------------

  Future<void> autoGeocodeAndProceed({
    required String address,
    required bool isPickup,
    required String deliveryAddress,
    required String recipientName,
    required String recipientPhone,
  }) async {
    emit(
      state.copyWith(
        infoMessage: 'Recherche de la position GPS pour "$address"...',
        clearError: true,
      ),
    );

    final results = await _geocodingService.searchAddress(address);
    if (isClosed) return;

    if (results.isNotEmpty) {
      final result = results.first;
      if (isPickup) {
        emit(
          state.copyWith(
            pickupLatitude: result.latitude,
            pickupLongitude: result.longitude,
            pickupCoordsSet: true,
            clearInfo: true,
          ),
        );
      } else {
        emit(
          state.copyWith(
            deliveryLatitude: result.latitude,
            deliveryLongitude: result.longitude,
            deliveryCoordsSet: true,
            clearInfo: true,
          ),
        );
      }
    } else {
      emit(
        state.copyWith(
          errorMessage:
              'Adresse introuvable. Veuillez sélectionner sur la carte.',
          clearInfo: true,
        ),
      );
    }
  }

  // -----------------------------------------------------------------------
  // Coordonnées manuelles (carte / GPS)
  // -----------------------------------------------------------------------

  void updatePickupCoords(CoordsData data) {
    emit(
      state.copyWith(
        pickupLatitude: data.latitude,
        pickupLongitude: data.longitude,
        pickupCoordsSet: data.coordsSet,
      ),
    );
  }

  void updateDeliveryCoords(CoordsData data) {
    emit(
      state.copyWith(
        deliveryLatitude: data.latitude,
        deliveryLongitude: data.longitude,
        deliveryCoordsSet: data.coordsSet,
      ),
    );
  }

  void setGpsLoading(bool loading) {
    emit(state.copyWith(isGpsLoading: loading));
  }

  // -----------------------------------------------------------------------
  // Sélections
  // -----------------------------------------------------------------------

  void setPackageSize(String size) {
    emit(state.copyWith(selectedPackageSize: size));
  }

  void setPaymentMethod(String method) {
    emit(state.copyWith(selectedPaymentMethod: method));
  }

  // -----------------------------------------------------------------------
  // Prix (reçu via OrderBloc)
  // -----------------------------------------------------------------------

  void updatePrice({
    required double price,
    required double distance,
    required double basePrice,
    required double distancePrice,
    bool isSurge = false,
    double surgeMultiplier = 1.0,
  }) {
    emit(
      state.copyWith(
        estimatedPrice: price,
        estimatedDistance: distance,
        basePrice: basePrice,
        distancePrice: distancePrice,
        isSurge: isSurge,
        surgeMultiplier: surgeMultiplier,
      ),
    );
  }

  void markOrderCreated() {
    emit(state.copyWith(orderCreated: true));
  }

  void clearMessages() {
    emit(state.copyWith(clearError: true, clearInfo: true));
  }
}
