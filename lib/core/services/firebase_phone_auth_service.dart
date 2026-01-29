import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service pour gérer l'authentification Firebase Phone (SMS OTP)
class FirebasePhoneAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // Stockage temporaire du verification ID
  String? _verificationId;
  int? _resendToken;
  
  /// Obtenir l'ID de vérification actuel
  String? get verificationId => _verificationId;
  
  /// Envoyer un code OTP par SMS
  /// Retourne un Future qui complète quand le code est envoyé
  Future<PhoneAuthResult> sendOtp({
    required String phoneNumber,
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final completer = Completer<PhoneAuthResult>();
    
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: timeout,
        forceResendingToken: _resendToken,
        
        // Appelé quand la vérification est terminée automatiquement (Android)
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('📱 Firebase: Auto-vérification complétée');
          // Sur Android, le code peut être vérifié automatiquement
          if (!completer.isCompleted) {
            completer.complete(PhoneAuthResult(
              success: true,
              autoVerified: true,
              credential: credential,
              message: 'Vérification automatique réussie',
            ));
          }
        },
        
        // Appelé quand la vérification échoue
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('❌ Firebase Phone Auth Error: ${e.code} - ${e.message}');
          if (!completer.isCompleted) {
            completer.complete(PhoneAuthResult(
              success: false,
              message: _getErrorMessage(e.code),
              errorCode: e.code,
            ));
          }
        },
        
        // Appelé quand le code SMS est envoyé
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('✅ Firebase: Code SMS envoyé, verificationId: $verificationId');
          _verificationId = verificationId;
          _resendToken = resendToken;
          
          if (!completer.isCompleted) {
            completer.complete(PhoneAuthResult(
              success: true,
              verificationId: verificationId,
              message: 'Code SMS envoyé avec succès',
            ));
          }
        },
        
        // Appelé quand le timeout expire
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('⏱️ Firebase: Timeout auto-retrieval');
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      debugPrint('❌ Erreur sendOtp: $e');
      if (!completer.isCompleted) {
        completer.complete(PhoneAuthResult(
          success: false,
          message: 'Erreur lors de l\'envoi du code SMS',
        ));
      }
    }
    
    return completer.future;
  }
  
  /// Vérifier le code OTP entré par l'utilisateur
  Future<PhoneAuthResult> verifyOtp({
    required String otp,
    String? verificationId,
  }) async {
    final verId = verificationId ?? _verificationId;
    
    if (verId == null) {
      return PhoneAuthResult(
        success: false,
        message: 'Session expirée. Veuillez renvoyer le code.',
        errorCode: 'session-expired',
      );
    }
    
    try {
      // Créer le credential avec le code OTP
      final credential = PhoneAuthProvider.credential(
        verificationId: verId,
        smsCode: otp,
      );
      
      // Vérifier le credential (sans se connecter)
      // On utilise signInWithCredential pour valider le code
      final userCredential = await _auth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        debugPrint('✅ Firebase: Code OTP vérifié avec succès');
        
        // Obtenir le token Firebase pour l'envoyer au backend
        final idToken = await userCredential.user!.getIdToken();
        
        return PhoneAuthResult(
          success: true,
          message: 'Code vérifié avec succès',
          credential: credential,
          firebaseUser: userCredential.user,
          idToken: idToken,
        );
      } else {
        return PhoneAuthResult(
          success: false,
          message: 'Erreur de vérification',
        );
      }
    } on FirebaseAuthException catch (e) {
      debugPrint('❌ Firebase verify error: ${e.code} - ${e.message}');
      return PhoneAuthResult(
        success: false,
        message: _getErrorMessage(e.code),
        errorCode: e.code,
      );
    } catch (e) {
      debugPrint('❌ Erreur verifyOtp: $e');
      return PhoneAuthResult(
        success: false,
        message: 'Erreur lors de la vérification du code',
      );
    }
  }
  
  /// Renvoyer le code OTP
  Future<PhoneAuthResult> resendOtp({required String phoneNumber}) async {
    return sendOtp(phoneNumber: phoneNumber);
  }
  
  /// Déconnecter l'utilisateur Firebase
  Future<void> signOut() async {
    await _auth.signOut();
    _verificationId = null;
    _resendToken = null;
  }
  
  /// Obtenir l'utilisateur Firebase actuel
  User? get currentUser => _auth.currentUser;
  
  /// Stream des changements d'état d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();
  
  /// Convertir les codes d'erreur Firebase en messages français
  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-phone-number':
        return 'Numéro de téléphone invalide';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      case 'quota-exceeded':
        return 'Quota SMS dépassé. Réessayez demain.';
      case 'invalid-verification-code':
        return 'Code OTP invalide';
      case 'session-expired':
        return 'Session expirée. Renvoyez le code.';
      case 'credential-already-in-use':
        return 'Ce numéro est déjà utilisé par un autre compte';
      case 'network-request-failed':
        return 'Erreur réseau. Vérifiez votre connexion.';
      case 'app-not-authorized':
        return 'Application non autorisée';
      case 'captcha-check-failed':
        return 'Vérification reCAPTCHA échouée';
      case 'missing-phone-number':
        return 'Numéro de téléphone manquant';
      default:
        return 'Erreur: $code';
    }
  }
}

/// Résultat d'une opération d'authentification phone
class PhoneAuthResult {
  final bool success;
  final String message;
  final String? errorCode;
  final String? verificationId;
  final bool autoVerified;
  final PhoneAuthCredential? credential;
  final User? firebaseUser;
  final String? idToken;
  
  PhoneAuthResult({
    required this.success,
    required this.message,
    this.errorCode,
    this.verificationId,
    this.autoVerified = false,
    this.credential,
    this.firebaseUser,
    this.idToken,
  });
}
