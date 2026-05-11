import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/network/api_client.dart';
import '../../../../core/services/enhanced_notification_service.dart';
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
    String? firebaseIdToken,
  });

  Future<UserModel> getCurrentUser();

  /// Met à jour le profil utilisateur. Supporte l’upload d’avatar
  /// en fichier (mobile) ou en bytes (web).
  Future<UserModel> updateProfile({
    String? name,
    String? email,
    XFile? avatarFile,
    Uint8List? avatarBytes,
  });

  Future<void> logout();

  /// Enregistre le token FCM de l'appareil sur le serveur.
  Future<void> registerFcmToken();

  /// Rafraîchit le token d'authentification
  Future<Map<String, dynamic>> refreshToken();
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
      data: {'name': name, 'phone': phone, if (email != null) 'email': email},
    );
  }

  @override
  Future<void> login({required String phone}) async {
    await _apiClient.post('auth/otp/send', data: {'phone': phone});
  }

  @override
  Future<Map<String, dynamic>> verifyOtp({
    required String phone,
    required String otp,
    String? firebaseIdToken,
  }) async {
    final response = await _apiClient.post(
      'auth/otp/verify',
      data: {
        'phone': phone,
        'code': otp,
        'app_type': 'client',
        if (firebaseIdToken != null) 'firebase_id_token': firebaseIdToken,
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
    XFile? avatarFile,
    Uint8List? avatarBytes,
  }) async {
    final Map<String, dynamic> formDataMap = {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
    };

    if (avatarBytes != null && avatarFile != null) {
      final filename = avatarFile.name;
      final ext = filename.split('.').last.toLowerCase();
      final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';
      // Web : utiliser les bytes ; Mobile : utiliser le fichier directement
      if (avatarFile.path.isEmpty) {
        formDataMap['avatar'] = MultipartFile.fromBytes(
          avatarBytes,
          filename: filename,
          contentType: DioMediaType.parse(mimeType),
        );
      } else {
        formDataMap['avatar'] = await MultipartFile.fromFile(
          avatarFile.path,
          filename: filename,
          contentType: DioMediaType.parse(mimeType),
        );
      }
    }

    final formData = FormData.fromMap(formDataMap);
    final response = await _apiClient.post(
      'user/profile',
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    final data = response.data['data'] ?? response.data;
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  @override
  Future<void> logout() async {
    await _apiClient.post('auth/logout');
  }

  @override
  Future<void> registerFcmToken() async {
    await EnhancedFirebaseNotificationService().registerTokenWithBackend(
      _apiClient,
    );
  }

  @override
  Future<Map<String, dynamic>> refreshToken() async {
    final response = await _apiClient.post('auth/refresh-token');
    return response.data as Map<String, dynamic>;
  }
}
