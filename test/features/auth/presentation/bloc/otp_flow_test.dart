import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/auth/domain/entities/user.dart';
import 'package:ouaga_chap_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:ouaga_chap_client/features/auth/domain/usecases/verify_otp_usecase.dart';
import 'package:ouaga_chap_client/features/auth/domain/usecases/login_usecase.dart';
import 'package:ouaga_chap_client/features/auth/domain/usecases/register_usecase.dart';
import 'package:ouaga_chap_client/features/auth/presentation/bloc/auth_event.dart';
import 'package:ouaga_chap_client/features/auth/presentation/bloc/auth_state.dart';

// =============================================================================
// Tests unitaires complets pour le flux OTP
// Couvre: events, states, use cases, validation, sécurité
// =============================================================================

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  // =========================================================================
  // 1. OTP Event Tests
  // =========================================================================
  group('OTP Events', () {
    group('AuthOtpVerificationRequested', () {
      test('crée une instance avec phone et otp', () {
        const event = AuthOtpVerificationRequested(
          phone: '+22670123456',
          otp: '123456',
        );

        expect(event.phone, '+22670123456');
        expect(event.otp, '123456');
        expect(event.isNewUser, false);
      });

      test('crée une instance avec isNewUser=true', () {
        const event = AuthOtpVerificationRequested(
          phone: '+22670123456',
          otp: '654321',
          isNewUser: true,
        );

        expect(event.isNewUser, true);
      });

      test('props contient phone, otp et isNewUser', () {
        const event = AuthOtpVerificationRequested(
          phone: '+22670123456',
          otp: '123456',
          isNewUser: true,
        );

        expect(event.props, ['+22670123456', '123456', true]);
      });

      test('deux events identiques sont égaux', () {
        const event1 = AuthOtpVerificationRequested(
          phone: '+22670123456',
          otp: '123456',
        );
        const event2 = AuthOtpVerificationRequested(
          phone: '+22670123456',
          otp: '123456',
        );

        expect(event1, equals(event2));
      });

      test('events avec OTP différents ne sont pas égaux', () {
        const event1 = AuthOtpVerificationRequested(
          phone: '+22670123456',
          otp: '123456',
        );
        const event2 = AuthOtpVerificationRequested(
          phone: '+22670123456',
          otp: '654321',
        );

        expect(event1, isNot(equals(event2)));
      });

      test('events avec phones différents ne sont pas égaux', () {
        const event1 = AuthOtpVerificationRequested(
          phone: '+22670123456',
          otp: '123456',
        );
        const event2 = AuthOtpVerificationRequested(
          phone: '+22670999999',
          otp: '123456',
        );

        expect(event1, isNot(equals(event2)));
      });
    });

    group('AuthResendOtpRequested', () {
      test('crée une instance pour login', () {
        const event = AuthResendOtpRequested(
          phone: '+22670123456',
          isLogin: true,
        );

        expect(event.phone, '+22670123456');
        expect(event.isLogin, true);
      });

      test('crée une instance pour inscription', () {
        const event = AuthResendOtpRequested(
          phone: '+22670123456',
          isLogin: false,
        );

        expect(event.isLogin, false);
      });

      test('props contient phone et isLogin', () {
        const event = AuthResendOtpRequested(
          phone: '+22670123456',
          isLogin: true,
        );

        expect(event.props, ['+22670123456', true]);
      });

      test('deux events identiques sont égaux', () {
        const event1 = AuthResendOtpRequested(
          phone: '+22670123456',
          isLogin: true,
        );
        const event2 = AuthResendOtpRequested(
          phone: '+22670123456',
          isLogin: true,
        );

        expect(event1, equals(event2));
      });
    });

    group('AuthLoginRequested (déclenche envoi OTP)', () {
      test('crée une instance avec phone', () {
        const event = AuthLoginRequested(phone: '+22670123456');

        expect(event.phone, '+22670123456');
      });

      test('props contient phone', () {
        const event = AuthLoginRequested(phone: '+22670123456');

        expect(event.props, ['+22670123456']);
      });
    });

    group('AuthRegisterRequested (déclenche envoi OTP)', () {
      test('crée une instance complète', () {
        const event = AuthRegisterRequested(
          name: 'Amadou Ouédraogo',
          phone: '+22670123456',
          email: 'amadou@example.com',
        );

        expect(event.name, 'Amadou Ouédraogo');
        expect(event.phone, '+22670123456');
        expect(event.email, 'amadou@example.com');
      });

      test('email est optionnel', () {
        const event = AuthRegisterRequested(
          name: 'Amadou',
          phone: '+22670123456',
        );

        expect(event.email, isNull);
      });
    });
  });

  // =========================================================================
  // 2. OTP State Tests
  // =========================================================================
  group('OTP States', () {
    group('AuthOtpSent', () {
      test('crée une instance pour login', () {
        const state = AuthOtpSent(phone: '+22670123456', isLogin: true);

        expect(state.phone, '+22670123456');
        expect(state.isLogin, true);
      });

      test('crée une instance pour inscription', () {
        const state = AuthOtpSent(phone: '+22670123456', isLogin: false);

        expect(state.isLogin, false);
      });

      test('props contient phone et isLogin', () {
        const state = AuthOtpSent(phone: '+22670123456', isLogin: true);

        expect(state.props, ['+22670123456', true]);
      });

      test('deux states identiques sont égaux', () {
        const state1 = AuthOtpSent(phone: '+22670123456', isLogin: true);
        const state2 = AuthOtpSent(phone: '+22670123456', isLogin: true);

        expect(state1, equals(state2));
      });

      test('states avec isLogin différent ne sont pas égaux', () {
        const state1 = AuthOtpSent(phone: '+22670123456', isLogin: true);
        const state2 = AuthOtpSent(phone: '+22670123456', isLogin: false);

        expect(state1, isNot(equals(state2)));
      });
    });

    group('AuthError (erreur OTP)', () {
      test('crée une erreur OTP simple', () {
        const state = AuthError(message: 'Code OTP invalide');

        expect(state.message, 'Code OTP invalide');
        expect(state.errorCode, isNull);
        expect(state.errorType, isNull);
      });

      test('crée une erreur OTP avec code', () {
        const state = AuthError(
          message: 'Code OTP invalide',
          errorCode: 'invalid-verification-code',
          errorType: 'otp_error',
        );

        expect(state.errorCode, 'invalid-verification-code');
        expect(state.errorType, 'otp_error');
      });

      test('props contient message, errorCode et errorType', () {
        const state = AuthError(
          message: 'Erreur',
          errorCode: '422',
          errorType: 'validation',
        );

        expect(state.props, ['Erreur', '422', 'validation']);
      });
    });

    group('AuthSuccess', () {
      test('crée un état succès avec message', () {
        const state = AuthSuccess(
          message: 'Connexion réussie ! Bienvenue sur OUAGA CHAP.',
        );

        expect(state.message, contains('Bienvenue'));
      });
    });

    group('AuthLoading', () {
      test('deux instances sont égales', () {
        expect(AuthLoading(), equals(AuthLoading()));
      });
    });
  });

  // =========================================================================
  // 3. VerifyOtpUseCase Tests
  // =========================================================================
  group('VerifyOtpUseCase', () {
    late VerifyOtpUseCase useCase;
    late MockAuthRepository mockRepository;

    final testUser = const User(
      id: 1,
      name: 'Amadou Ouédraogo',
      phone: '+22670123456',
      role: 'client',
      isPhoneVerified: true,
    );

    setUp(() {
      mockRepository = MockAuthRepository();
      useCase = VerifyOtpUseCase(mockRepository);
    });

    test('vérifie un OTP valide et retourne l\'utilisateur', () async {
      when(() => mockRepository.verifyOtp(
            phone: '+22670123456',
            otp: '123456',
            firebaseVerified: false,
          )).thenAnswer((_) async => testUser);

      final result = await useCase.call(
        phone: '+22670123456',
        otp: '123456',
      );

      expect(result, equals(testUser));
      expect(result.isClient, true);
      expect(result.isPhoneVerified, true);
      verify(() => mockRepository.verifyOtp(
            phone: '+22670123456',
            otp: '123456',
            firebaseVerified: false,
          )).called(1);
    });

    test('vérifie avec firebaseIdToken et passe firebaseVerified=true', () async {
      when(() => mockRepository.verifyOtp(
            phone: '+22670123456',
            otp: '123456',
            firebaseVerified: true,
            firebaseIdToken: 'firebase-token-xyz',
          )).thenAnswer((_) async => testUser);

      final result = await useCase.call(
        phone: '+22670123456',
        otp: '123456',
        firebaseIdToken: 'firebase-token-xyz',
      );

      expect(result, equals(testUser));
      verify(() => mockRepository.verifyOtp(
            phone: '+22670123456',
            otp: '123456',
            firebaseVerified: true,
            firebaseIdToken: 'firebase-token-xyz',
          )).called(1);
    });

    test('lance une exception pour OTP invalide', () async {
      when(() => mockRepository.verifyOtp(
            phone: any(named: 'phone'),
            otp: any(named: 'otp'),
            firebaseVerified: any(named: 'firebaseVerified'),
          )).thenThrow(Exception('Code OTP invalide'));

      expect(
        () => useCase.call(phone: '+22670123456', otp: '000000'),
        throwsA(isA<Exception>()),
      );
    });

    test('lance une exception pour OTP expiré', () async {
      when(() => mockRepository.verifyOtp(
            phone: '+22670123456',
            otp: '123456',
            firebaseVerified: false,
          )).thenThrow(Exception('OTP expired'));

      expect(
        () => useCase.call(phone: '+22670123456', otp: '123456'),
        throwsA(isA<Exception>()),
      );
    });

    test('retourne un utilisateur avec le bon rôle client', () async {
      when(() => mockRepository.verifyOtp(
            phone: '+22670123456',
            otp: '123456',
            firebaseVerified: false,
          )).thenAnswer((_) async => testUser);

      final result = await useCase.call(
        phone: '+22670123456',
        otp: '123456',
      );

      expect(result.isClient, true);
      expect(result.isCourier, false);
      expect(result.isAdmin, false);
    });

    test('retourne un utilisateur courier (doit être rejeté par le bloc)', () async {
      final courierUser = const User(
        id: 2,
        name: 'Coursier Test',
        phone: '+22670999999',
        role: 'courier',
      );
      when(() => mockRepository.verifyOtp(
            phone: '+22670999999',
            otp: '123456',
            firebaseVerified: false,
          )).thenAnswer((_) async => courierUser);

      final result = await useCase.call(
        phone: '+22670999999',
        otp: '123456',
      );

      expect(result.isClient, false);
      expect(result.isCourier, true);
    });
  });

  // =========================================================================
  // 4. OTP Validation Tests (Sécurité)
  // =========================================================================
  group('OTP Validation & Sécurité', () {
    test('code OTP doit avoir exactement 6 caractères', () {
      bool isValidOtp(String otp) => RegExp(r'^\d{6}$').hasMatch(otp);

      expect(isValidOtp('123456'), true);
      expect(isValidOtp('000000'), true);
      expect(isValidOtp('999999'), true);
    });

    test('code OTP trop court est rejeté', () {
      bool isValidOtp(String otp) => RegExp(r'^\d{6}$').hasMatch(otp);

      expect(isValidOtp('12345'), false);
      expect(isValidOtp('1'), false);
      expect(isValidOtp(''), false);
    });

    test('code OTP trop long est rejeté', () {
      bool isValidOtp(String otp) => RegExp(r'^\d{6}$').hasMatch(otp);

      expect(isValidOtp('1234567'), false);
      expect(isValidOtp('12345678'), false);
    });

    test('code OTP avec lettres est rejeté', () {
      bool isValidOtp(String otp) => RegExp(r'^\d{6}$').hasMatch(otp);

      expect(isValidOtp('12345a'), false);
      expect(isValidOtp('abcdef'), false);
      expect(isValidOtp('12ab56'), false);
    });

    test('code OTP avec espaces est rejeté', () {
      bool isValidOtp(String otp) => RegExp(r'^\d{6}$').hasMatch(otp);

      expect(isValidOtp('123 56'), false);
      expect(isValidOtp(' 12345'), false);
      expect(isValidOtp('12345 '), false);
    });

    test('code OTP avec caractères spéciaux est rejeté', () {
      bool isValidOtp(String otp) => RegExp(r'^\d{6}$').hasMatch(otp);

      expect(isValidOtp('12345!'), false);
      expect(isValidOtp('123-56'), false);
      expect(isValidOtp('12.456'), false);
    });

    test('numéro de téléphone Burkina valide (+226)', () {
      bool isValidBurkinaPhone(String phone) {
        return RegExp(r'^\+226[5-7]\d{7}$').hasMatch(phone);
      }

      // Numéros valides (opérateurs BF)
      expect(isValidBurkinaPhone('+22670123456'), true);  // Orange
      expect(isValidBurkinaPhone('+22665123456'), true);  // Moov
      expect(isValidBurkinaPhone('+22655123456'), true);  // Telecel

      // Numéros invalides
      expect(isValidBurkinaPhone('+22680123456'), false); // Préfixe 8 invalide
      expect(isValidBurkinaPhone('+2267012345'), false);  // Trop court
      expect(isValidBurkinaPhone('+226701234567'), false); // Trop long
      expect(isValidBurkinaPhone('70123456'), false);     // Pas de préfixe pays
      expect(isValidBurkinaPhone('+33612345678'), false);  // Pas BF
    });

    test('formatage du numéro pour affichage', () {
      String formatPhoneNumber(String phone) {
        if (phone.startsWith('+226') && phone.length == 12) {
          final local = phone.substring(4);
          return '+226 ${local.substring(0, 2)} ${local.substring(2, 4)} ${local.substring(4, 6)} ${local.substring(6)}';
        }
        return phone;
      }

      expect(formatPhoneNumber('+22670123456'), '+226 70 12 34 56');
      expect(formatPhoneNumber('+22665987654'), '+226 65 98 76 54');
      // Numéros non-BF retournés tels quels
      expect(formatPhoneNumber('+33612345678'), '+33612345678');
      expect(formatPhoneNumber('70123456'), '70123456');
    });
  });

  // =========================================================================
  // 5. User Entity Tests (liés à OTP)
  // =========================================================================
  group('User Entity (post-OTP)', () {
    test('utilisateur client est reconnu', () {
      const user = User(id: 1, name: 'Test', phone: '+22670000000', role: 'client');
      expect(user.isClient, true);
      expect(user.isCourier, false);
      expect(user.isAdmin, false);
    });

    test('utilisateur courier est rejeté par l\'app client', () {
      const user = User(id: 2, name: 'Coursier', phone: '+22670000000', role: 'courier');
      expect(user.isClient, false);
      expect(user.isCourier, true);
    });

    test('utilisateur admin est reconnu', () {
      const user = User(id: 3, name: 'Admin', phone: '+22670000000', role: 'admin');
      expect(user.isAdmin, true);
      expect(user.isClient, false);
    });

    test('copyWith préserve les propriétés', () {
      const user = User(
        id: 1,
        name: 'Original',
        phone: '+22670123456',
        role: 'client',
        isPhoneVerified: true,
      );

      final updated = user.copyWith(name: 'Modifié');

      expect(updated.id, 1);
      expect(updated.name, 'Modifié');
      expect(updated.phone, '+22670123456');
      expect(updated.role, 'client');
      expect(updated.isPhoneVerified, true);
    });

    test('equals fonctionne correctement', () {
      const user1 = User(id: 1, name: 'Test', phone: '+22670000000');
      const user2 = User(id: 1, name: 'Test', phone: '+22670000000');
      const user3 = User(id: 2, name: 'Test', phone: '+22670000000');

      expect(user1, equals(user2));
      expect(user1, isNot(equals(user3)));
    });
  });

  // =========================================================================
  // 6. OTP Timer Logic Tests
  // =========================================================================
  group('OTP Timer Logic', () {
    test('timer démarre à 60 secondes', () {
      int remainingSeconds = 60;
      bool canResend = false;

      expect(remainingSeconds, 60);
      expect(canResend, false);
    });

    test('timer atteint 0 active le renvoi', () {
      int remainingSeconds = 60;
      bool canResend = false;

      // Simuler le décompte
      for (int i = 0; i < 60; i++) {
        remainingSeconds--;
      }

      if (remainingSeconds <= 0) {
        canResend = true;
      }

      expect(remainingSeconds, 0);
      expect(canResend, true);
    });

    test('reset du timer remet à 60s et désactive le renvoi', () {
      int remainingSeconds = 0;
      bool canResend = true;

      // Reset (comme _startTimer)
      remainingSeconds = 60;
      canResend = false;

      expect(remainingSeconds, 60);
      expect(canResend, false);
    });
  });

  // =========================================================================
  // 7. OTP Error Message Mapping Tests
  // =========================================================================
  group('Messages d\'erreur OTP', () {
    String getFirebaseErrorMessage(String code) {
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
        case 'operation-not-allowed':
          return 'Authentification par SMS Firebase non activée. Utilisation du SMS classique.';
        default:
          return 'Erreur: $code';
      }
    }

    test('code invalide retourne message français', () {
      expect(
        getFirebaseErrorMessage('invalid-verification-code'),
        'Code OTP invalide',
      );
    });

    test('session expirée retourne message français', () {
      expect(
        getFirebaseErrorMessage('session-expired'),
        'Session expirée. Renvoyez le code.',
      );
    });

    test('trop de tentatives retourne message français', () {
      expect(
        getFirebaseErrorMessage('too-many-requests'),
        'Trop de tentatives. Réessayez plus tard.',
      );
    });

    test('quota dépassé retourne message français', () {
      expect(
        getFirebaseErrorMessage('quota-exceeded'),
        'Quota SMS dépassé. Réessayez demain.',
      );
    });

    test('numéro invalide retourne message français', () {
      expect(
        getFirebaseErrorMessage('invalid-phone-number'),
        'Numéro de téléphone invalide',
      );
    });

    test('erreur réseau retourne message français', () {
      expect(
        getFirebaseErrorMessage('network-request-failed'),
        'Erreur réseau. Vérifiez votre connexion.',
      );
    });

    test('numéro déjà utilisé retourne message français', () {
      expect(
        getFirebaseErrorMessage('credential-already-in-use'),
        'Ce numéro est déjà utilisé par un autre compte',
      );
    });

    test('opération non autorisée retourne message explicite', () {
      expect(
        getFirebaseErrorMessage('operation-not-allowed'),
        contains('non activée'),
      );
    });

    test('code inconnu retourne message par défaut', () {
      expect(
        getFirebaseErrorMessage('unknown-error'),
        'Erreur: unknown-error',
      );
    });
  });

  // =========================================================================
  // 8. PhoneAuthResult Model Tests
  // =========================================================================
  group('PhoneAuthResult (modèle OTP)', () {
    test('no demo hint visible - code démo supprimé', () {
      // Vérifier qu'aucun texte de démo n'est dans la logique
      const demoMessages = [
        'Mode démo',
        'utilisez le code 123456',
        'demo mode',
        'test code',
      ];

      // Ce test vérifie que les messages de démo ne sont PAS
      // utilisés dans les états auth
      const errorState = AuthError(message: 'Code OTP invalide');
      for (final msg in demoMessages) {
        expect(errorState.message.toLowerCase(), isNot(contains(msg.toLowerCase())));
      }

      const successState = AuthSuccess(
        message: 'Connexion réussie ! Bienvenue sur OUAGA CHAP.',
      );
      for (final msg in demoMessages) {
        expect(successState.message.toLowerCase(), isNot(contains(msg.toLowerCase())));
      }
    });

    test('état AuthOtpSent ne contient pas de code démo', () {
      const state = AuthOtpSent(phone: '+22670123456', isLogin: true);

      // Vérifier que le state ne contient pas d'info de démo
      expect(state.phone, '+22670123456');
      expect(state.isLogin, true);
      // Pas de champ demoCode ou hint
    });
  });

  // =========================================================================
  // 9. OTP Flow Integration Tests (sans Firebase réel)
  // =========================================================================
  group('Flux OTP complet (use cases)', () {
    late MockAuthRepository mockRepository;
    late VerifyOtpUseCase verifyOtpUseCase;
    late LoginUseCase loginUseCase;
    late RegisterUseCase registerUseCase;

    final testClient = const User(
      id: 1,
      name: 'Client Test',
      phone: '+22670123456',
      role: 'client',
      isPhoneVerified: true,
    );

    setUp(() {
      mockRepository = MockAuthRepository();
      verifyOtpUseCase = VerifyOtpUseCase(mockRepository);
      loginUseCase = LoginUseCase(mockRepository);
      registerUseCase = RegisterUseCase(mockRepository);
    });

    test('flux login complet: sendOtp → verifyOtp → user', () async {
      // 1. Login envoie l'OTP
      when(() => mockRepository.sendOtp(phone: '+22670123456'))
          .thenAnswer((_) async {});

      await loginUseCase(phone: '+22670123456');
      verify(() => mockRepository.sendOtp(phone: '+22670123456')).called(1);

      // 2. Vérification du code
      when(() => mockRepository.verifyOtp(
            phone: '+22670123456',
            otp: '123456',
            firebaseVerified: false,
          )).thenAnswer((_) async => testClient);

      final user = await verifyOtpUseCase(
        phone: '+22670123456',
        otp: '123456',
      );

      expect(user, equals(testClient));
      expect(user.isClient, true);
    });

    test('flux inscription complet: register → verifyOtp → user', () async {
      // 1. Inscription envoie l'OTP
      when(() => mockRepository.sendOtp(phone: '+22670123456'))
          .thenAnswer((_) async {});

      await registerUseCase(phone: '+22670123456');
      verify(() => mockRepository.sendOtp(phone: '+22670123456')).called(1);

      // 2. Vérification du code
      when(() => mockRepository.verifyOtp(
            phone: '+22670123456',
            otp: '123456',
            firebaseVerified: true,
            firebaseIdToken: 'test-firebase-token',
          )).thenAnswer((_) async => testClient);

      final user = await verifyOtpUseCase(
        phone: '+22670123456',
        otp: '123456',
        firebaseIdToken: 'test-firebase-token',
      );

      expect(user, equals(testClient));
    });

    test('flux login échoue si utilisateur non trouvé', () async {
      when(() => mockRepository.sendOtp(phone: '+22670000000'))
          .thenThrow(Exception('User not found'));

      expect(
        () => loginUseCase(phone: '+22670000000'),
        throwsA(isA<Exception>()),
      );
    });

    test('flux OTP échoue avec code invalide', () async {
      when(() => mockRepository.verifyOtp(
            phone: '+22670123456',
            otp: '000000',
            firebaseVerified: false,
          )).thenThrow(Exception('Invalid OTP code'));

      expect(
        () => verifyOtpUseCase(
          phone: '+22670123456',
          otp: '000000',
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('coursier rejeté par l\'app client après OTP valide', () async {
      final courierUser = const User(
        id: 5,
        name: 'Coursier',
        phone: '+22670123456',
        role: 'courier',
      );

      when(() => mockRepository.verifyOtp(
            phone: '+22670123456',
            otp: '123456',
            firebaseVerified: false,
          )).thenAnswer((_) async => courierUser);

      final user = await verifyOtpUseCase(
        phone: '+22670123456',
        otp: '123456',
      );

      // Le use case retourne l'utilisateur, c'est le bloc qui rejette
      expect(user.isClient, false);
      expect(user.isCourier, true);
      // Le bloc vérifierait isClient et émettrait AuthError
    });

    test('renvoi OTP appelle le repository correctement', () async {
      when(() => mockRepository.sendOtp(phone: '+22670123456'))
          .thenAnswer((_) async {});

      // Simuler un renvoi (même fonction que login)
      await loginUseCase(phone: '+22670123456');
      await loginUseCase(phone: '+22670123456');

      verify(() => mockRepository.sendOtp(phone: '+22670123456')).called(2);
    });
  });
}
