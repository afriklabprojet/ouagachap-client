import 'package:equatable/equatable.dart';

/// Modèle pour les informations de contact du support
class ContactInfo extends Equatable {
  final String phone;
  final String phoneDisplay;
  final String email;
  final String whatsapp;
  final String whatsappMessage;
  final WorkingHours workingHours;
  final SocialLinks social;
  final Address address;

  const ContactInfo({
    required this.phone,
    required this.phoneDisplay,
    required this.email,
    required this.whatsapp,
    required this.whatsappMessage,
    required this.workingHours,
    required this.social,
    required this.address,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      phone: json['phone'] ?? '',
      phoneDisplay: json['phone_display'] ?? '',
      email: json['email'] ?? '',
      whatsapp: json['whatsapp'] ?? '',
      whatsappMessage: json['whatsapp_message'] ?? '',
      workingHours: WorkingHours.fromJson(json['working_hours'] ?? {}),
      social: SocialLinks.fromJson(json['social'] ?? {}),
      address: Address.fromJson(json['address'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [phone, email, whatsapp, workingHours, social, address];
}

class WorkingHours extends Equatable {
  final String days;
  final String hours;

  const WorkingHours({required this.days, required this.hours});

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      days: json['days'] ?? '',
      hours: json['hours'] ?? '',
    );
  }

  @override
  List<Object?> get props => [days, hours];
}

class SocialLinks extends Equatable {
  final String facebook;
  final String instagram;
  final String twitter;

  const SocialLinks({
    required this.facebook,
    required this.instagram,
    required this.twitter,
  });

  factory SocialLinks.fromJson(Map<String, dynamic> json) {
    return SocialLinks(
      facebook: json['facebook'] ?? '',
      instagram: json['instagram'] ?? '',
      twitter: json['twitter'] ?? '',
    );
  }

  @override
  List<Object?> get props => [facebook, instagram, twitter];
}

class Address extends Equatable {
  final String street;
  final String city;
  final String country;

  const Address({
    required this.street,
    required this.city,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      country: json['country'] ?? '',
    );
  }

  String get fullAddress => '$street, $city, $country';

  @override
  List<Object?> get props => [street, city, country];
}
