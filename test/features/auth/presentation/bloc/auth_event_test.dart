import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/auth/presentation/bloc/auth_event.dart';

void main() {
  group('AuthEvent', () {
    group('AuthCheckRequested', () {
      test('is a subclass of AuthEvent', () {
        expect(AuthCheckRequested(), isA<AuthEvent>());
      });

      test('props returns empty list', () {
        expect(AuthCheckRequested().props, isEmpty);
      });

      test('two AuthCheckRequested are equal', () {
        expect(AuthCheckRequested(), equals(AuthCheckRequested()));
      });
    });

    group('AuthRegisterRequested', () {
      test('is a subclass of AuthEvent', () {
        const event = AuthRegisterRequested(
          name: 'Test User',
          phone: '70000000',
        );
        expect(event, isA<AuthEvent>());
      });

      test('stores name, phone and email', () {
        const event = AuthRegisterRequested(
          name: 'Test User',
          phone: '70123456',
          email: 'test@example.com',
        );

        expect(event.name, 'Test User');
        expect(event.phone, '70123456');
        expect(event.email, 'test@example.com');
      });

      test('email is optional', () {
        const event = AuthRegisterRequested(
          name: 'Test User',
          phone: '70000000',
        );

        expect(event.email, isNull);
      });

      test('props returns name, phone and email', () {
        const event = AuthRegisterRequested(
          name: 'Test',
          phone: '70000000',
          email: 'test@test.com',
        );

        expect(event.props, contains('Test'));
        expect(event.props, contains('70000000'));
        expect(event.props, contains('test@test.com'));
      });

      test('two AuthRegisterRequested with same data are equal', () {
        const event1 = AuthRegisterRequested(
          name: 'Test',
          phone: '70000000',
        );
        const event2 = AuthRegisterRequested(
          name: 'Test',
          phone: '70000000',
        );

        expect(event1, equals(event2));
      });

      test('two AuthRegisterRequested with different data are not equal', () {
        const event1 = AuthRegisterRequested(
          name: 'Test1',
          phone: '70000000',
        );
        const event2 = AuthRegisterRequested(
          name: 'Test2',
          phone: '70000000',
        );

        expect(event1, isNot(equals(event2)));
      });
    });

    group('AuthLoginRequested', () {
      test('is a subclass of AuthEvent', () {
        const event = AuthLoginRequested(phone: '70000000');
        expect(event, isA<AuthEvent>());
      });

      test('stores phone', () {
        const event = AuthLoginRequested(phone: '70123456');
        expect(event.phone, '70123456');
      });

      test('props returns phone', () {
        const event = AuthLoginRequested(phone: '70000000');
        expect(event.props, contains('70000000'));
      });

      test('two AuthLoginRequested with same phone are equal', () {
        const event1 = AuthLoginRequested(phone: '70000000');
        const event2 = AuthLoginRequested(phone: '70000000');
        expect(event1, equals(event2));
      });

      test('two AuthLoginRequested with different phone are not equal', () {
        const event1 = AuthLoginRequested(phone: '70000000');
        const event2 = AuthLoginRequested(phone: '70111111');
        expect(event1, isNot(equals(event2)));
      });
    });

    group('AuthOtpVerificationRequested', () {
      test('is a subclass of AuthEvent', () {
        const event = AuthOtpVerificationRequested(
          phone: '70000000',
          otp: '123456',
        );
        expect(event, isA<AuthEvent>());
      });

      test('stores phone and otp', () {
        const event = AuthOtpVerificationRequested(
          phone: '70123456',
          otp: '654321',
        );

        expect(event.phone, '70123456');
        expect(event.otp, '654321');
      });

      test('props returns phone and otp', () {
        const event = AuthOtpVerificationRequested(
          phone: '70000000',
          otp: '123456',
        );

        expect(event.props, contains('70000000'));
        expect(event.props, contains('123456'));
      });

      test('two AuthOtpVerificationRequested with same data are equal', () {
        const event1 = AuthOtpVerificationRequested(
          phone: '70000000',
          otp: '123456',
        );
        const event2 = AuthOtpVerificationRequested(
          phone: '70000000',
          otp: '123456',
        );
        expect(event1, equals(event2));
      });

      test('two AuthOtpVerificationRequested with different otp are not equal', () {
        const event1 = AuthOtpVerificationRequested(
          phone: '70000000',
          otp: '123456',
        );
        const event2 = AuthOtpVerificationRequested(
          phone: '70000000',
          otp: '654321',
        );
        expect(event1, isNot(equals(event2)));
      });
    });

    group('AuthLogoutRequested', () {
      test('is a subclass of AuthEvent', () {
        expect(AuthLogoutRequested(), isA<AuthEvent>());
      });

      test('props returns empty list', () {
        expect(AuthLogoutRequested().props, isEmpty);
      });

      test('two AuthLogoutRequested are equal', () {
        expect(AuthLogoutRequested(), equals(AuthLogoutRequested()));
      });
    });

    group('AuthResendOtpRequested', () {
      test('is a subclass of AuthEvent', () {
        const event = AuthResendOtpRequested(
          phone: '70000000',
          isLogin: true,
        );
        expect(event, isA<AuthEvent>());
      });

      test('stores phone and isLogin', () {
        const event = AuthResendOtpRequested(
          phone: '70123456',
          isLogin: false,
        );

        expect(event.phone, '70123456');
        expect(event.isLogin, false);
      });

      test('two AuthResendOtpRequested with same data are equal', () {
        const event1 = AuthResendOtpRequested(
          phone: '70000000',
          isLogin: true,
        );
        const event2 = AuthResendOtpRequested(
          phone: '70000000',
          isLogin: true,
        );
        expect(event1, equals(event2));
      });
    });

    group('UpdateProfileRequested', () {
      test('is a subclass of AuthEvent', () {
        const event = UpdateProfileRequested(name: 'Test User');
        expect(event, isA<AuthEvent>());
      });

      test('stores name and optional email', () {
        const event = UpdateProfileRequested(
          name: 'Test User',
          email: 'test@example.com',
        );

        expect(event.name, 'Test User');
        expect(event.email, 'test@example.com');
      });

      test('email is optional', () {
        const event = UpdateProfileRequested(name: 'Test User');
        expect(event.email, isNull);
      });

      test('avatarFile is optional', () {
        const event = UpdateProfileRequested(name: 'Test User');
        expect(event.avatarFile, isNull);
      });

      test('avatarBytes is optional', () {
        const event = UpdateProfileRequested(name: 'Test User');
        expect(event.avatarBytes, isNull);
      });

      test('props returns name, email, avatarFile, avatarBytes', () {
        const event = UpdateProfileRequested(
          name: 'Test',
          email: 'test@test.com',
        );

        expect(event.props, contains('Test'));
        expect(event.props, contains('test@test.com'));
      });

      test('two UpdateProfileRequested with same data are equal', () {
        const event1 = UpdateProfileRequested(
          name: 'Test',
          email: 'test@test.com',
        );
        const event2 = UpdateProfileRequested(
          name: 'Test',
          email: 'test@test.com',
        );

        expect(event1, equals(event2));
      });

      test('two UpdateProfileRequested with different name are not equal', () {
        const event1 = UpdateProfileRequested(name: 'Test1');
        const event2 = UpdateProfileRequested(name: 'Test2');

        expect(event1, isNot(equals(event2)));
      });
    });

    group('Event types are distinct', () {
      test('different events are not equal', () {
        final checkEvent = AuthCheckRequested();
        const registerEvent = AuthRegisterRequested(
          name: 'Test',
          phone: '70000000',
        );
        const loginEvent = AuthLoginRequested(phone: '70000000');
        const otpEvent = AuthOtpVerificationRequested(
          phone: '70000000',
          otp: '123456',
        );
        final logoutEvent = AuthLogoutRequested();
        const updateEvent = UpdateProfileRequested(name: 'Test');

        expect(checkEvent, isNot(equals(registerEvent)));
        expect(registerEvent, isNot(equals(loginEvent)));
        expect(loginEvent, isNot(equals(otpEvent)));
        expect(otpEvent, isNot(equals(logoutEvent)));
        expect(logoutEvent, isNot(equals(updateEvent)));
      });
    });
  });
}
