import 'package:equatable/equatable.dart';

class User extends Equatable {
  final int id;
  final String name;
  final String phone;
  final String? email;
  final String? avatar;
  final String role;
  final bool isPhoneVerified;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatar,
    this.role = 'client',
    this.isPhoneVerified = false,
    this.createdAt,
  });

  bool get isClient => role == 'client';
  bool get isCourier => role == 'courier';
  bool get isAdmin => role == 'admin';

  @override
  List<Object?> get props => [id, name, phone, email, avatar, role, isPhoneVerified, createdAt];

  User copyWith({
    int? id,
    String? name,
    String? phone,
    String? email,
    String? avatar,
    String? role,
    bool? isPhoneVerified,
    DateTime? createdAt,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatar: avatar ?? this.avatar,
      role: role ?? this.role,
      isPhoneVerified: isPhoneVerified ?? this.isPhoneVerified,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
