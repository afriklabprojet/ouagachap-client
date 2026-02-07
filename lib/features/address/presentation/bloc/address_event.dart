import 'package:equatable/equatable.dart';

abstract class AddressEvent extends Equatable {
  const AddressEvent();

  @override
  List<Object?> get props => [];
}

/// Load all saved addresses
class LoadAddresses extends AddressEvent {
  const LoadAddresses();
}

/// Create a new address
class CreateAddress extends AddressEvent {
  final String label;
  final String address;
  final double latitude;
  final double longitude;
  final String? contactName;
  final String? contactPhone;
  final String? instructions;
  final bool isDefault;
  final String type;

  const CreateAddress({
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.contactName,
    this.contactPhone,
    this.instructions,
    this.isDefault = false,
    this.type = 'other',
  });

  @override
  List<Object?> get props => [
        label,
        address,
        latitude,
        longitude,
        contactName,
        contactPhone,
        instructions,
        isDefault,
        type,
      ];
}

/// Update an existing address
class UpdateAddress extends AddressEvent {
  final int id;
  final String? label;
  final String? address;
  final double? latitude;
  final double? longitude;
  final String? contactName;
  final String? contactPhone;
  final String? instructions;
  final bool? isDefault;
  final String? type;

  const UpdateAddress({
    required this.id,
    this.label,
    this.address,
    this.latitude,
    this.longitude,
    this.contactName,
    this.contactPhone,
    this.instructions,
    this.isDefault,
    this.type,
  });

  @override
  List<Object?> get props => [
        id,
        label,
        address,
        latitude,
        longitude,
        contactName,
        contactPhone,
        instructions,
        isDefault,
        type,
      ];
}

/// Delete an address
class DeleteAddress extends AddressEvent {
  final int id;

  const DeleteAddress(this.id);

  @override
  List<Object?> get props => [id];
}

/// Set an address as default
class SetDefaultAddress extends AddressEvent {
  final int id;

  const SetDefaultAddress(this.id);

  @override
  List<Object?> get props => [id];
}
