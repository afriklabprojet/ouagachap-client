import 'package:equatable/equatable.dart';

enum AddressType { home, work, other }

class SavedAddress extends Equatable {
  final int id;
  final String label;
  final String address;
  final double latitude;
  final double longitude;
  final String? contactName;
  final String? contactPhone;
  final String? instructions;
  final bool isDefault;
  final AddressType type;
  final DateTime createdAt;
  final DateTime updatedAt;

  const SavedAddress({
    required this.id,
    required this.label,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.contactName,
    this.contactPhone,
    this.instructions,
    this.isDefault = false,
    this.type = AddressType.other,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SavedAddress.fromJson(Map<String, dynamic> json) {
    return SavedAddress(
      id: json['id'] as int,
      label: json['label'] as String,
      address: json['address'] as String,
      latitude: double.parse(json['latitude'].toString()),
      longitude: double.parse(json['longitude'].toString()),
      contactName: json['contact_name'] as String?,
      contactPhone: json['contact_phone'] as String?,
      instructions: json['instructions'] as String?,
      isDefault: json['is_default'] == true || json['is_default'] == 1,
      type: _parseType(json['type'] as String?),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'contact_name': contactName,
      'contact_phone': contactPhone,
      'instructions': instructions,
      'is_default': isDefault,
      'type': type.name,
    };
  }

  static AddressType _parseType(String? type) {
    switch (type) {
      case 'home':
        return AddressType.home;
      case 'work':
        return AddressType.work;
      default:
        return AddressType.other;
    }
  }

  String get icon {
    switch (type) {
      case AddressType.home:
        return '🏠';
      case AddressType.work:
        return '🏢';
      case AddressType.other:
        return '📍';
    }
  }

  String get displayLabel => '$icon $label';

  SavedAddress copyWith({
    int? id,
    String? label,
    String? address,
    double? latitude,
    double? longitude,
    String? contactName,
    String? contactPhone,
    String? instructions,
    bool? isDefault,
    AddressType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SavedAddress(
      id: id ?? this.id,
      label: label ?? this.label,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      contactName: contactName ?? this.contactName,
      contactPhone: contactPhone ?? this.contactPhone,
      instructions: instructions ?? this.instructions,
      isDefault: isDefault ?? this.isDefault,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

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
