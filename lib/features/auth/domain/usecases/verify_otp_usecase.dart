import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class VerifyOtpUseCase {
  final AuthRepository _repository;

  VerifyOtpUseCase(this._repository);

  Future<User> call({
    required String phone,
    required String otp,
    String? firebaseIdToken,
  }) async {
    return await _repository.verifyOtp(
      phone: phone, 
      otp: otp,
      firebaseIdToken: firebaseIdToken,
    );
  }
}
