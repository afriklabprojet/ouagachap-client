import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/auth/domain/entities/user.dart';
import 'package:ouaga_chap_client/features/auth/presentation/bloc/auth_state.dart';
import 'package:ouaga_chap_client/features/auth/presentation/bloc/auth_event.dart';

void main() {
  group('AuthEvent', () {
    group('AuthCheckRequested', () {
      test('creates instance', () {
        final event = AuthCheckRequested();

        expect(event, isA<AuthEvent>());
      });

      test('props is empty', () {
        final event = AuthCheckRequested();

        expect(event.props, isEmpty);
      });

      test('two instances are equal', () {
        final event1 = AuthCheckRequested();
        final event2 = AuthCheckRequested();

        expect(event1, equals(event2));
      });
    });

    group('AuthRegisterRequested', () {
      test('creates instance with required fields', () {
        const event = AuthRegisterRequested(
          name: 'John Doe',
          phone: '70123456',
        );

        expect(event.name, 'John Doe');
        expect(event.phone, '70123456');
        expect(event.email, isNull);
      });

      test('creates instance with email', () {
        const event = AuthRegisterRequested(
          name: 'John Doe',
          phone: '70123456',
          email: 'john@example.com',
        );

        expect(event.name, 'John Doe');
        expect(event.phone, '70123456');
        expect(event.email, 'john@example.com');
      });

      test('props contains name, phone, and email', () {
        const event = AuthRegisterRequested(
          name: 'John',
          phone: '70123456',
          email: 'john@test.com',
        );

        expect(event.props, ['John', '70123456', 'john@test.com']);
      });

      test('two events with same props are equal', () {
        const event1 = AuthRegisterRequested(name: 'John', phone: '70123456');
        const event2 = AuthRegisterRequested(name: 'John', phone: '70123456');

        expect(event1, equals(event2));
      });

      test('two events with different props are not equal', () {
        const event1 = AuthRegisterRequested(name: 'John', phone: '70123456');
        const event2 = AuthRegisterRequested(name: 'Jane', phone: '70123456');

        expect(event1, isNot(equals(event2)));
      });
    });

    group('AuthLoginRequested', () {
      test('creates instance with phone', () {
        const event = AuthLoginRequested(phone: '70123456');

        expect(event.phone, '70123456');
      });

      test('props contains phone', () {
        const event = AuthLoginRequested(phone: '70123456');

        expect(event.props, ['70123456']);
      });

      test('two events with same phone are equal', () {
        const event1 = AuthLoginRequested(phone: '70123456');
        const event2 = AuthLoginRequested(phone: '70123456');

        expect(event1, equals(event2));
      });

      test('two events with different phones are not equal', () {
        const event1 = AuthLoginRequested(phone: '70123456');
        const event2 = AuthLoginRequested(phone: '70654321');

        expect(event1, isNot(equals(event2)));
      });
    });

    group('AuthOtpVerificationRequested', () {
      test('creates instance with phone and otp', () {
        const event = AuthOtpVerificationRequested(
          phone: '70123456',
          otp: '123456',
        );

        expect(event.phone, '70123456');
        expect(event.otp, '123456');
      });

      test('props contains phone and otp', () {
        const event = AuthOtpVerificationRequested(
          phone: '70123456',
          otp: '123456',
        );

        expect(event.props, ['70123456', '123456']);
      });

      test('two events with same props are equal', () {
        const event1 = AuthOtpVerificationRequested(
          phone: '70123456',
          otp: '123456',
        );
        const event2 = AuthOtpVerificationRequested(
          phone: '70123456',
          otp: '123456',
        );

        expect(event1, equals(event2));
      });
    });

    group('AuthLogoutRequested', () {
      test('creates instance', () {
        final event = AuthLogoutRequested();

        expect(event, isA<AuthEvent>());
      });

      test('props is empty', () {
        final event = AuthLogoutRequested();

        expect(event.props, isEmpty);
      });

      test('two instances are equal', () {
        final event1 = AuthLogoutRequested();
        final event2 = AuthLogoutRequested();

        expect(event1, equals(event2));
      });
    });

    group('AuthResendOtpRequested', () {
      test('creates instance with phone and isLogin', () {
        const event = AuthResendOtpRequested(
          phone: '70123456',
          isLogin: true,
        );

        expect(event.phone, '70123456');
        expect(event.isLogin, true);
      });

      test('props contains phone and isLogin', () {
        const event = AuthResendOtpRequested(
          phone: '70123456',
          isLogin: false,
        );

        expect(event.props, ['70123456', false]);
      });

      test('two events with same props are equal', () {
        const event1 = AuthResendOtpRequested(phone: '70123456', isLogin: true);
        const event2 = AuthResendOtpRequested(phone: '70123456', isLogin: true);

        expect(event1, equals(event2));
      });
    });

    group('UpdateProfileRequested', () {
      test('creates instance with required name', () {
        const event = UpdateProfileRequested(name: 'John Doe');

        expect(event.name, 'John Doe');
        expect(event.email, isNull);
        expect(event.avatarFile, isNull);
        expect(event.avatarBytes, isNull);
      });

      test('creates instance with email', () {
        const event = UpdateProfileRequested(
          name: 'John Doe',
          email: 'john@example.com',
        );

        expect(event.name, 'John Doe');
        expect(event.email, 'john@example.com');
      });

      test('props contains name, email, avatarFile and avatarBytes', () {
        const event = UpdateProfileRequested(
          name: 'John Doe',
          email: 'john@example.com',
        );

        expect(event.props, ['John Doe', 'john@example.com', null, null]);
      });
    });
  });

  group('AuthState', () {
    final testUser = User(
      id: 1,
      name: 'John Doe',
      phone: '70123456',
      email: 'john@example.com',
      role: 'client',
      isPhoneVerified: true,
      createdAt: DateTime(2024, 1, 15),
    );

    group('AuthInitial', () {
      test('creates instance', () {
        final state = AuthInitial();

        expect(state, isA<AuthState>());
      });

      test('props is empty', () {
        final state = AuthInitial();

        expect(state.props, isEmpty);
      });

      test('two instances are equal', () {
        final state1 = AuthInitial();
        final state2 = AuthInitial();

        expect(state1, equals(state2));
      });
    });

    group('AuthLoading', () {
      test('creates instance', () {
        final state = AuthLoading();

        expect(state, isA<AuthState>());
      });

      test('props is empty', () {
        final state = AuthLoading();

        expect(state.props, isEmpty);
      });

      test('two instances are equal', () {
        final state1 = AuthLoading();
        final state2 = AuthLoading();

        expect(state1, equals(state2));
      });
    });

    group('AuthOtpSent', () {
      test('creates instance with phone and isLogin', () {
        const state = AuthOtpSent(phone: '70123456', isLogin: true);

        expect(state.phone, '70123456');
        expect(state.isLogin, true);
      });

      test('props contains phone and isLogin', () {
        const state = AuthOtpSent(phone: '70123456', isLogin: false);

        expect(state.props, ['70123456', false]);
      });

      test('two states with same props are equal', () {
        const state1 = AuthOtpSent(phone: '70123456', isLogin: true);
        const state2 = AuthOtpSent(phone: '70123456', isLogin: true);

        expect(state1, equals(state2));
      });

      test('two states with different phone are not equal', () {
        const state1 = AuthOtpSent(phone: '70123456', isLogin: true);
        const state2 = AuthOtpSent(phone: '70654321', isLogin: true);

        expect(state1, isNot(equals(state2)));
      });

      test('two states with different isLogin are not equal', () {
        const state1 = AuthOtpSent(phone: '70123456', isLogin: true);
        const state2 = AuthOtpSent(phone: '70123456', isLogin: false);

        expect(state1, isNot(equals(state2)));
      });
    });

    group('AuthAuthenticated', () {
      test('creates instance with user', () {
        final state = AuthAuthenticated(user: testUser);

        expect(state.user, testUser);
      });

      test('props contains user', () {
        final state = AuthAuthenticated(user: testUser);

        expect(state.props, [testUser]);
      });

      test('two states with same user are equal', () {
        final state1 = AuthAuthenticated(user: testUser);
        final state2 = AuthAuthenticated(user: testUser);

        expect(state1, equals(state2));
      });

      test('two states with different users are not equal', () {
        final otherUser = User(
          id: 2,
          name: 'Jane Doe',
          phone: '70654321',
        );

        final state1 = AuthAuthenticated(user: testUser);
        final state2 = AuthAuthenticated(user: otherUser);

        expect(state1, isNot(equals(state2)));
      });
    });

    group('AuthUnauthenticated', () {
      test('creates instance', () {
        final state = AuthUnauthenticated();

        expect(state, isA<AuthState>());
      });

      test('props is empty', () {
        final state = AuthUnauthenticated();

        expect(state.props, isEmpty);
      });

      test('two instances are equal', () {
        final state1 = AuthUnauthenticated();
        final state2 = AuthUnauthenticated();

        expect(state1, equals(state2));
      });
    });

    group('AuthError', () {
      test('creates instance with message', () {
        const state = AuthError(message: 'Authentication failed');

        expect(state.message, 'Authentication failed');
      });

      test('props contains message', () {
        const state = AuthError(message: 'Error occurred');

        expect(state.props, ['Error occurred']);
      });

      test('two states with same message are equal', () {
        const state1 = AuthError(message: 'Error');
        const state2 = AuthError(message: 'Error');

        expect(state1, equals(state2));
      });

      test('two states with different messages are not equal', () {
        const state1 = AuthError(message: 'Error 1');
        const state2 = AuthError(message: 'Error 2');

        expect(state1, isNot(equals(state2)));
      });
    });

    group('AuthProfileUpdated', () {
      test('creates instance with user', () {
        final state = AuthProfileUpdated(user: testUser);

        expect(state.user, testUser);
      });

      test('props contains user', () {
        final state = AuthProfileUpdated(user: testUser);

        expect(state.props, [testUser]);
      });

      test('two states with same user are equal', () {
        final state1 = AuthProfileUpdated(user: testUser);
        final state2 = AuthProfileUpdated(user: testUser);

        expect(state1, equals(state2));
      });
    });
  });
}
