import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/address_repository.dart';
import 'address_event.dart';
import 'address_state.dart';

class AddressBloc extends Bloc<AddressEvent, AddressState> {
  final AddressRepository _repository;

  AddressBloc(this._repository) : super(const AddressState()) {
    on<LoadAddresses>(_onLoadAddresses);
    on<CreateAddress>(_onCreateAddress);
    on<UpdateAddress>(_onUpdateAddress);
    on<DeleteAddress>(_onDeleteAddress);
    on<SetDefaultAddress>(_onSetDefaultAddress);
  }

  Future<void> _onLoadAddresses(
    LoadAddresses event,
    Emitter<AddressState> emit,
  ) async {
    emit(state.copyWith(status: AddressStatus.loading));

    try {
      final addresses = await _repository.getAddresses();
      emit(state.copyWith(
        status: AddressStatus.loaded,
        addresses: addresses,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AddressStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onCreateAddress(
    CreateAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(state.copyWith(isCreating: true));

    try {
      final newAddress = await _repository.createAddress(
        label: event.label,
        address: event.address,
        latitude: event.latitude,
        longitude: event.longitude,
        contactName: event.contactName,
        contactPhone: event.contactPhone,
        instructions: event.instructions,
        isDefault: event.isDefault,
        type: event.type,
      );

      // Update list
      List<SavedAddress> updatedAddresses;
      if (newAddress.isDefault) {
        // Unset other defaults
        updatedAddresses = state.addresses
            .map((a) => a.copyWith(isDefault: false))
            .toList();
        updatedAddresses.insert(0, newAddress);
      } else {
        updatedAddresses = [...state.addresses, newAddress];
      }

      emit(state.copyWith(
        isCreating: false,
        addresses: updatedAddresses,
      ));
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdateAddress(
    UpdateAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(state.copyWith(isCreating: true));

    try {
      final updatedAddress = await _repository.updateAddress(
        id: event.id,
        label: event.label,
        address: event.address,
        latitude: event.latitude,
        longitude: event.longitude,
        contactName: event.contactName,
        contactPhone: event.contactPhone,
        instructions: event.instructions,
        isDefault: event.isDefault,
        type: event.type,
      );

      // Update list
      List<SavedAddress> updatedAddresses;
      if (updatedAddress.isDefault) {
        // Unset other defaults
        updatedAddresses = state.addresses.map((a) {
          if (a.id == event.id) return updatedAddress;
          return a.copyWith(isDefault: false);
        }).toList();
      } else {
        updatedAddresses = state.addresses.map((a) {
          if (a.id == event.id) return updatedAddress;
          return a;
        }).toList();
      }

      emit(state.copyWith(
        isCreating: false,
        addresses: updatedAddresses,
      ));
    } catch (e) {
      emit(state.copyWith(
        isCreating: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDeleteAddress(
    DeleteAddress event,
    Emitter<AddressState> emit,
  ) async {
    emit(state.copyWith(isDeleting: true));

    try {
      await _repository.deleteAddress(event.id);

      final deletedAddress = state.addresses.firstWhere((a) => a.id == event.id);
      final updatedAddresses = state.addresses.where((a) => a.id != event.id).toList();

      // If deleted was default, set first remaining as default
      if (deletedAddress.isDefault && updatedAddresses.isNotEmpty) {
        updatedAddresses[0] = updatedAddresses[0].copyWith(isDefault: true);
      }

      emit(state.copyWith(
        isDeleting: false,
        addresses: updatedAddresses,
      ));
    } catch (e) {
      emit(state.copyWith(
        isDeleting: false,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSetDefaultAddress(
    SetDefaultAddress event,
    Emitter<AddressState> emit,
  ) async {
    try {
      await _repository.setDefaultAddress(event.id);

      // Update local state
      final updatedAddresses = state.addresses.map((a) {
        return a.copyWith(isDefault: a.id == event.id);
      }).toList();

      emit(state.copyWith(addresses: updatedAddresses));
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }
}
