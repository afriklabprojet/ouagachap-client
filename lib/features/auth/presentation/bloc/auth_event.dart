import 'dart:typed_data';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String phone;
  final String? email;

  const AuthRegisterRequested({
    required this.name,
    required this.phone,
    this.email,
  });

  @override
  List<Object?> get props => [name, phone, email];
}

class AuthLoginRequested extends AuthEvent {
  final String phone;

  const AuthLoginRequested({required this.phone});

  @override
  List<Object?> get props => [phone];
}

class AuthOtpVerificationRequested extends AuthEvent {
  final String phone;
  final String otp;
  final bool isNewUser;

  const AuthOtpVerificationRequested({
    required this.phone,
    required this.otp,
    this.isNewUser = false,
  });

  @override
  List<Object?> get props => [phone, otp, isNewUser];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthResendOtpRequested extends AuthEvent {
  final String phone;
  final bool isLogin;

  const AuthResendOtpRequested({
    required this.phone,
    required this.isLogin,
  });

  @override
  List<Object?> get props => [phone, isLogin];
}

/// Événement pour l'auto-vérification Firebase (Android)
class AuthAutoVerified extends AuthEvent {
  final String phone;
  final PhoneAuthCredential credential;

  const AuthAutoVerified({
    required this.phone,
    required this.credential,
  });

  @override
  List<Object?> get props => [phone, credential];
}

class UpdateProfileRequested extends AuthEvent {
  final String name;
  final String? email;
  final XFile? avatarFile;
  final Uint8List? avatarBytes;

  const UpdateProfileRequested({
    required this.name,
    this.email,
    this.avatarFile,
    this.avatarBytes,
  });

  @override
  List<Object?> get props => [name, email, avatarFile, avatarBytes];
}
