import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<void> register({
    required String name,
    required String phone,
    String? email,
  });
  
  Future<void> login({required String phone});
  
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    bool firebaseVerified = false,
  });
  
  Future<UserModel> getCurrentUser();
  
  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? avatar,
  });
  
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  AuthRemoteDataSourceImpl(this._apiClient);

  @override
  Future<void> register({
    required String name,
    required String phone,
    String? email,
  }) async {
    await _apiClient.post(
      'auth/register',
      data: {
        'name': name,
        'phone': phone,
        if (email != null) 'email': email,
      },
    );
  }

  @override
  Future<void> login({required String phone}) async {
    await _apiClient.post(
      'auth/otp/send',
      data: {'phone': phone},
    );
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    bool firebaseVerified = false,
  }) async {
    final response = await _apiClient.post(
      'auth/otp/verify',
      data: {
        'phone': phone,
        'code': otp, // L'API attend 'code' pas 'otp'
        'app_type': 'client', // Identifier cette app comme client
        if (firebaseVerified) 'firebase_verified': true,
      },
    );
    
    return response.data as Map<String, dynamic>;
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get('auth/me');
    final data = response.data['data'] ?? response.data;
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<UserModel> updateProfile({
    String? name,
    String? email,
    String? avatar,
  }) async {
    final response = await _apiClient.put(
      'auth/profile',
      data: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (avatar != null) 'avatar': avatar,
      },
    );
    
    final data = response.data['data'] ?? response.data;
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await _apiClient.post('/auth/logout');
  }
}
