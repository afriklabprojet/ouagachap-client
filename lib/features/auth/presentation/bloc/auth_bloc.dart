import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../../core/services/enhanced_notification_service.dart';
import '../../../../core/services/firebase_phone_auth_service.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/register_usecase.dart';
import '../../domain/usecases/verify_otp_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterUseCase registerUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final LoginUseCase loginUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final LogoutUseCase logoutUseCase;
  
  // Service Firebase Phone Auth
  final FirebasePhoneAuthService _firebasePhoneAuth = FirebasePhoneAuthService();
  
  /// Indique si Firebase a réussi à envoyer le SMS OTP
  bool _firebaseOtpSent = false;
  
  // Firebase Phone Auth uniquement sur mobile (Android/iOS)
  // Sur web, on utilise le backend mock car reCAPTCHA est complexe à configurer
  bool get useFirebasePhoneAuth {
    if (kIsWeb) return false;
    return true; // Mobile: utiliser Firebase
  }

  AuthBloc({
    required this.registerUseCase,
    required this.verifyOtpUseCase,
    required this.loginUseCase,
    required this.getCurrentUserUseCase,
    required this.logoutUseCase,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested, transformer: restartable());
    // droppable() → empêche les double-taps sur login/register/OTP
    on<AuthRegisterRequested>(_onAuthRegisterRequested, transformer: droppable());
    on<AuthLoginRequested>(_onAuthLoginRequested, transformer: droppable());
    on<AuthOtpVerificationRequested>(_onAuthOtpVerificationRequested, transformer: droppable());
    on<AuthLogoutRequested>(_onAuthLogoutRequested, transformer: droppable());
    on<AuthResendOtpRequested>(_onAuthResendOtpRequested, transformer: droppable());
    on<UpdateProfileRequested>(_onUpdateProfileRequested, transformer: droppable());
    on<AuthAutoVerified>(_onAuthAutoVerified, transformer: droppable());
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      final user = await getCurrentUserUseCase();
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      // D'abord créer l'utilisateur côté backend
      await registerUseCase(
        name: event.name,
        phone: event.phone,
        email: event.email,
      );
      
      // Puis envoyer le SMS via Firebase si activé
      _firebaseOtpSent = false;
      if (useFirebasePhoneAuth) {
        final result = await _firebasePhoneAuth.sendOtp(phoneNumber: event.phone);
        
        if (result.autoVerified && result.credential != null) {
          // Auto-vérification sur Android - connecter directement
          if (isClosed) return;
          add(AuthAutoVerified(phone: event.phone, credential: result.credential!));
          return;
        }
        
        if (result.success) {
          _firebaseOtpSent = true;
        } else {
          // Firebase a échoué - continuer avec le SMS backup envoyé par le serveur
          debugPrint('⚠️ Firebase Phone Auth échoué: ${result.message} (code: ${result.errorCode})');
          debugPrint('📱 Fallback vers SMS backup du serveur');
          _firebaseOtpSent = false;
          // Ne PAS bloquer - le serveur a déjà envoyé un SMS backup
        }
      }
      
      if (isClosed) return;
      emit(AuthOtpSent(phone: event.phone, isLogin: false));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(message: _extractErrorMessage(e)));
    }
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      // D'abord vérifier que l'utilisateur existe côté backend
      await loginUseCase(phone: event.phone);
      
      // Puis envoyer le SMS via Firebase si activé
      _firebaseOtpSent = false;
      if (useFirebasePhoneAuth) {
        final result = await _firebasePhoneAuth.sendOtp(phoneNumber: event.phone);
        
        if (result.autoVerified && result.credential != null) {
          // Auto-vérification sur Android - connecter directement
          if (isClosed) return;
          add(AuthAutoVerified(phone: event.phone, credential: result.credential!));
          return;
        }
        
        if (result.success) {
          _firebaseOtpSent = true;
        } else {
          // Firebase a échoué - continuer avec le SMS backup envoyé par le serveur
          debugPrint('⚠️ Firebase Phone Auth échoué: ${result.message} (code: ${result.errorCode})');
          debugPrint('📱 Fallback vers SMS backup du serveur');
          _firebaseOtpSent = false;
          // Ne PAS bloquer - le serveur a déjà envoyé un SMS backup
        }
      }
      
      if (isClosed) return;
      emit(AuthOtpSent(phone: event.phone, isLogin: true));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(message: _extractErrorMessage(e)));
    }
  }

  Future<void> _onAuthOtpVerificationRequested(
    AuthOtpVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      String? firebaseIdToken;
      
      // Vérifier le code OTP via Firebase SEULEMENT si Firebase a envoyé le SMS
      if (useFirebasePhoneAuth && _firebaseOtpSent) {
        final firebaseResult = await _firebasePhoneAuth.verifyOtp(otp: event.otp);
        
        if (!firebaseResult.success) {
          emit(AuthError(message: firebaseResult.message));
          return;
        }
        
        // Récupérer le ID Token Firebase pour l'envoyer au backend
        firebaseIdToken = firebaseResult.idToken;
        debugPrint('✅ Firebase OTP vérifié, idToken obtenu: ${firebaseIdToken?.substring(0, 20)}...');
      }
      
      // Authentifier côté backend avec le token Firebase (ou code OTP en fallback)
      final user = await verifyOtpUseCase(
        phone: event.phone,
        otp: event.otp,
        firebaseIdToken: firebaseIdToken,
      );
      
      // Vérifier que l'utilisateur est un client
      if (!user.isClient) {
        // Déconnecter l'utilisateur si ce n'est pas un client
        try {
          await logoutUseCase();
        } catch (_) {}
        emit(const AuthError(
          message: 'Cette application est réservée aux clients. '
              'Si vous êtes coursier, veuillez utiliser l\'application Coursier OUAGA CHAP.',
        ));
        return;
      }
      
      // Enregistrer le token FCM après connexion réussie
      _registerFcmToken();
      
      // Émettre un message de bienvenue
      emit(const AuthSuccess(message: 'Connexion réussie ! Bienvenue sur OUAGA CHAP.'));
      
      // Puis émettre l'état authentifié après un court délai
      await Future.delayed(const Duration(milliseconds: 500));
      if (isClosed) return;
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(message: _extractErrorMessage(e)));
    }
  }
  
  /// Handler pour l'auto-vérification (Android uniquement)
  Future<void> _onAuthAutoVerified(
    AuthAutoVerified event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      debugPrint('📱 Auto-vérification Firebase, connexion backend...');
      
      // Se connecter avec le credential pour obtenir le idToken
      final firebaseAuth = FirebaseAuth.instance;
      final userCredential = await firebaseAuth.signInWithCredential(event.credential);
      if (isClosed) return;
      final idToken = await userCredential.user?.getIdToken();
      
      if (idToken == null) {
        if (isClosed) return;
        emit(const AuthError(message: 'Erreur lors de la récupération du token Firebase'));
        return;
      }
      
      // Authentifier côté backend avec le token Firebase
      final user = await verifyOtpUseCase(
        phone: event.phone,
        otp: '000000', // Non utilisé car firebaseIdToken est fourni
        firebaseIdToken: idToken,
      );
      if (isClosed) return;
      
      // Vérifier que l'utilisateur est un client
      if (!user.isClient) {
        try {
          await logoutUseCase();
        } catch (_) {}
        if (isClosed) return;
        emit(const AuthError(
          message: 'Cette application est réservée aux clients. '
              'Si vous êtes coursier, veuillez utiliser l\'application Coursier OUAGA CHAP.',
        ));
        return;
      }
      
      // Enregistrer le token FCM après connexion réussie
      _registerFcmToken();
      
      if (isClosed) return;
      emit(AuthAuthenticated(user: user));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(message: _extractErrorMessage(e)));
    }
  }

  /// Enregistrer le token FCM sur le serveur
  Future<void> _registerFcmToken() async {
    try {
      final apiClient = getIt<ApiClient>();
      await EnhancedFirebaseNotificationService().registerTokenWithBackend(apiClient);
      debugPrint('✅ Token FCM enregistré avec succès');
    } catch (e) {
      debugPrint('⚠️ Erreur enregistrement FCM token: $e');
    }
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      // Supprimer le token FCM
      await EnhancedFirebaseNotificationService().deleteToken();
      
      await logoutUseCase();
      emit(AuthUnauthenticated());
    } catch (e) {
      emit(AuthError(message: _extractErrorMessage(e)));
    }
  }

  Future<void> _onAuthResendOtpRequested(
    AuthResendOtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    
    try {
      // Demander au backend de renvoyer (pour mise à jour des logs)
      // loginUseCase re-déclenche l'envoi OTP côté backend pour les 2 cas
      // (login et register) car l'utilisateur existe déjà après l'inscription initiale
      await loginUseCase(phone: event.phone);
      if (isClosed) return;
      
      // Renvoyer le SMS via Firebase si activé
      if (useFirebasePhoneAuth) {
        final result = await _firebasePhoneAuth.resendOtp(phoneNumber: event.phone);
        if (isClosed) return;
        
        if (result.autoVerified && result.credential != null) {
          add(AuthAutoVerified(phone: event.phone, credential: result.credential!));
          return;
        }
        
        if (!result.success) {
          emit(AuthError(message: result.message));
          return;
        }
      }
      
      if (isClosed) return;
      emit(AuthOtpSent(phone: event.phone, isLogin: event.isLogin));
    } catch (e) {
      if (isClosed) return;
      emit(AuthError(message: _extractErrorMessage(e)));
    }
  }

  String _extractErrorMessage(dynamic error) {
    if (error is DioException) {
      final response = error.response;
      final statusCode = response?.statusCode;
      
      // Extraire le message du serveur si disponible
      String? serverMessage;
      if (response?.data is Map) {
        serverMessage = response?.data['message'] ?? response?.data['error']?['message'];
      }
      
      switch (statusCode) {
        case 401:
          // Identifiants invalides
          return serverMessage ?? 'Identifiants invalides. Vérifiez votre numéro de téléphone et réessayez.';
        
        case 403:
          // Compte non approuvé ou accès refusé
          if (serverMessage != null && serverMessage.toLowerCase().contains('approuvé')) {
            return 'Votre compte est en attente de validation par un administrateur. Vous serez notifié dès l\'approbation.';
          }
          if (serverMessage != null && serverMessage.toLowerCase().contains('suspendu')) {
            return 'Votre compte a été suspendu. Contactez le support pour plus d\'informations.';
          }
          return serverMessage ?? 'Accès refusé. Votre compte n\'est pas encore actif.';
        
        case 404:
          // Utilisateur non trouvé
          return 'Aucun compte trouvé avec ce numéro. Veuillez vous inscrire d\'abord.';
        
        case 422:
          // Validation échouée
          if (serverMessage != null) {
            if (serverMessage.toLowerCase().contains('téléphone') || serverMessage.toLowerCase().contains('phone')) {
              return 'Ce numéro de téléphone est déjà utilisé ou invalide.';
            }
            if (serverMessage.toLowerCase().contains('email')) {
              return 'Cette adresse email est déjà utilisée ou invalide.';
            }
            if (serverMessage.toLowerCase().contains('otp')) {
              return 'Code OTP invalide ou expiré. Demandez un nouveau code.';
            }
            return serverMessage;
          }
          return 'Données invalides. Vérifiez vos informations.';
        
        case 429:
          // Trop de requêtes
          return 'Trop de tentatives. Veuillez patienter quelques minutes avant de réessayer.';
        
        case 500:
        case 502:
        case 503:
          // Erreurs serveur
          return 'Erreur serveur temporaire. Veuillez réessayer dans quelques instants.';
        
        default:
          // Erreurs réseau
          if (error.type == DioExceptionType.connectionTimeout) {
            return 'Délai de connexion dépassé. Vérifiez votre connexion internet.';
          }
          if (error.type == DioExceptionType.receiveTimeout) {
            return 'Le serveur met trop de temps à répondre. Réessayez plus tard.';
          }
          if (error.type == DioExceptionType.connectionError) {
            return 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.';
          }
          return serverMessage ?? 'Une erreur est survenue. Réessayez.';
      }
    }
    
    // Erreur générique
    return error.toString().length > 100 
        ? 'Une erreur est survenue. Réessayez.' 
        : error.toString();
  }

  Future<void> _onUpdateProfileRequested(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentState = state;
    if (currentState is! AuthAuthenticated) return;

    try {
      final apiClient = getIt<ApiClient>();
      
      // Préparer les données du formulaire
      final Map<String, dynamic> formDataMap = {
        'name': event.name,
        if (event.email != null) 'email': event.email,
      };
      
      // Ajouter l'avatar si présent (utiliser les bytes pour le web)
      if (event.avatarBytes != null && event.avatarFile != null) {
        formDataMap['avatar'] = MultipartFile.fromBytes(
          event.avatarBytes!,
          filename: event.avatarFile!.name,
        );
      }
      
      final formData = FormData.fromMap(formDataMap);

      // Envoyer la requête
      await apiClient.post(
        'user/profile',
        data: formData,
      );
      if (isClosed) return;

      // Recharger l'utilisateur mis à jour
      final user = await getCurrentUserUseCase();
      if (isClosed) return;
      if (user != null) {
        emit(AuthAuthenticated(user: user));
      }
    } catch (e) {
      debugPrint('Erreur mise à jour profil: $e');
      if (isClosed) return;
      emit(AuthError(message: _extractErrorMessage(e)));
    }
  }
}
