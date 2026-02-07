import 'package:equatable/equatable.dart';
import '../../domain/entities/saved_address.dart';

enum AddressStatus { initial, loading, loaded, error }

class AddressState extends Equatable {
  final AddressStatus status;
  final List<SavedAddress> addresses;
  final String? errorMessage;
  final bool isCreating;
  final bool isDeleting;

  const AddressState({
    this.status = AddressStatus.initial,
    this.addresses = const [],
    this.errorMessage,
    this.isCreating = false,
    this.isDeleting = false,
  });

  AddressState copyWith({
    AddressStatus? status,
    List<SavedAddress>? addresses,
    String? errorMessage,
    bool? isCreating,
    bool? isDeleting,
  }) {
    return AddressState(
      status: status ?? this.status,
      addresses: addresses ?? this.addresses,
      errorMessage: errorMessage,
      isCreating: isCreating ?? this.isCreating,
      isDeleting: isDeleting ?? this.isDeleting,
    );
  }

  /// Get default address or first address
  SavedAddress? get defaultAddress {
    if (addresses.isEmpty) return null;
    return addresses.firstWhere(
      (a) => a.isDefault,
      orElse: () => addresses.first,
    );
  }

  /// Get addresses by type
  List<SavedAddress> byType(AddressType type) {
    return addresses.where((a) => a.type == type).toList();
  }

  @override
  List<Object?> get props => [status, addresses, errorMessage, isCreating, isDeleting];
}
