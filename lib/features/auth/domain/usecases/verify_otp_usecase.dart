import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository _repository;

  VerifyOtpUseCase(this._repository);

  Future<User> call({
    required String phone,
    required String otp,
    bool firebaseVerified = false,
    String? firebaseIdToken,
  }) async {
    return await _repository.verifyOtp(
      phone: phone, 
      otp: firebaseIdToken ?? otp, // Si token Firebase, l'envoyer comme code
      firebaseVerified: firebaseVerified || firebaseIdToken != null,
    );
  }
}
