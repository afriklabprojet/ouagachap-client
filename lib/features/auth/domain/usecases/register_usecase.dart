import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<void> call({
    required String name,
    required String phone,
    String? email,
  }) async {
    return await _repository.register(
      name: name,
      phone: phone,
      email: email,
    );
  }
}
