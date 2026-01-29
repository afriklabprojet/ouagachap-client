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
    bool firebaseVerified = false,
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
    String? avatar,
  });

  /// Récupérer le token d'authentification
  Future<String?> getToken();
}
