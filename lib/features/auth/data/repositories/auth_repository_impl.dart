import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<void> register({
    required String name,
    required String phone,
    String? email,
  }) async {
    await remoteDataSource.register(
      name: name,
      phone: phone,
      email: email,
    );
  }

  @override
  Future<void> login({required String phone}) async {
    await remoteDataSource.login(phone: phone);
  }

  @override
  Future<User> verifyOtp({
    required String phone,
    required String otp,
    bool firebaseVerified = false,
  }) async {
    final response = await remoteDataSource.verifyOtp(
      phone: phone,
      otp: otp,
      firebaseVerified: firebaseVerified,
    );

    // La réponse API est: { success, message, data: { user, token } }
    final data = response['data'] as Map<String, dynamic>? ?? response;
    
    // Extraire le token
    final token = data['token'] as String? ?? response['token'] as String?;
    
    if (token != null) {
      await localDataSource.saveToken(token);
    }

    // Extraire l'utilisateur
    final userData = data['user'] as Map<String, dynamic>? ?? data;
    final user = UserModel.fromJson(userData);
    await localDataSource.saveUser(user);
    
    return user;
  }

  @override
  Future<User?> getCurrentUser() async {
    // D'abord essayer de récupérer depuis le cache local
    final localUser = await localDataSource.getUser();
    if (localUser != null) {
      return localUser;
    }

    // Sinon récupérer depuis l'API
    final token = await localDataSource.getToken();
    if (token == null) return null;

    try {
      final user = await remoteDataSource.getCurrentUser();
      await localDataSource.saveUser(user);
      return user;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await localDataSource.getToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<void> logout() async {
    try {
      await remoteDataSource.logout();
    } catch (_) {
      // Ignorer les erreurs réseau lors de la déconnexion
    } finally {
      await localDataSource.clearAll();
    }
  }

  @override
  Future<User> updateProfile({
    String? name,
    String? email,
    String? avatar,
  }) async {
    final user = await remoteDataSource.updateProfile(
      name: name,
      email: email,
      avatar: avatar,
    );
    await localDataSource.saveUser(user);
    return user;
  }

  @override
  Future<String?> getToken() async {
    return await localDataSource.getToken();
  }
}
