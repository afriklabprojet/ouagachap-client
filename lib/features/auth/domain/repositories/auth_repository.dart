import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

import '../entities/user.dart';

abstract class AuthRepository {
  /// Inscription avec numéro de téléphone
  Future<void> register({
    required String name,
    required String phone,
    String? email,
  });

  /// Connexion avec numéro de téléphone
  Future<void> login({required String phone});

  /// Vérification du code OTP
  Future<User> verifyOtp({
    required String phone,
    required String otp,
    String? firebaseIdToken,
  });

  /// Récupérer l'utilisateur connecté
  Future<User?> getCurrentUser();

  /// Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn();

  /// Déconnexion
  Future<void> logout();

  /// Mettre à jour le profil
  Future<User> updateProfile({
    String? name,
    String? email,
    XFile? avatarFile,
    Uint8List? avatarBytes,
  });

  /// Enregistrer le token FCM sur le serveur après connexion
  Future<void> registerFcmToken();

  /// Récupérer le token d'authentification
  Future<String?> getToken();

  /// Rafraîchit le token d'authentification
  Future<String> refreshToken();
}
