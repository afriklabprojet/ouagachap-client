import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/auth/domain/entities/user.dart';
import 'package:ouaga_chap_client/features/auth/presentation/bloc/auth_state.dart';

void main() {
  group('AuthState', () {
    group('AuthInitial', () {
      test('is a subclass of AuthState', () {
        expect(AuthInitial(), isA<AuthState>());
      });

      test('props returns empty list', () {
        expect(AuthInitial().props, isEmpty);
      });

      test('two AuthInitial are equal', () {
        expect(AuthInitial(), equals(AuthInitial()));
      });
    });

    group('AuthLoading', () {
      test('is a subclass of AuthState', () {
        expect(AuthLoading(), isA<AuthState>());
      });

      test('props returns empty list', () {
        expect(AuthLoading().props, isEmpty);
      });

      test('two AuthLoading are equal', () {
        expect(AuthLoading(), equals(AuthLoading()));
      });
    });

    group('AuthOtpSent', () {
      test('is a subclass of AuthState', () {
        const state = AuthOtpSent(phone: '70000000', isLogin: true);
        expect(state, isA<AuthState>());
      });

      test('stores phone and isLogin', () {
        const state = AuthOtpSent(phone: '70123456', isLogin: false);
        
        expect(state.phone, '70123456');
        expect(state.isLogin, false);
      });

      test('props returns phone and isLogin', () {
        const state = AuthOtpSent(phone: '70000000', isLogin: true);
        
        expect(state.props, contains('70000000'));
        expect(state.props, contains(true));
      });

      test('two AuthOtpSent with same data are equal', () {
        const state1 = AuthOtpSent(phone: '70000000', isLogin: true);
        const state2 = AuthOtpSent(phone: '70000000', isLogin: true);
        
        expect(state1, equals(state2));
      });

      test('two AuthOtpSent with different phone are not equal', () {
        const state1 = AuthOtpSent(phone: '70000000', isLogin: true);
        const state2 = AuthOtpSent(phone: '70111111', isLogin: true);
        
        expect(state1, isNot(equals(state2)));
      });

      test('two AuthOtpSent with different isLogin are not equal', () {
        const state1 = AuthOtpSent(phone: '70000000', isLogin: true);
        const state2 = AuthOtpSent(phone: '70000000', isLogin: false);
        
        expect(state1, isNot(equals(state2)));
      });
    });

    group('AuthAuthenticated', () {
      late User user;

      setUp(() {
        user = const User(
          id: 1,
          name: 'Test User',
          phone: '70000000',
        );
      });

      test('is a subclass of AuthState', () {
        expect(AuthAuthenticated(user: user), isA<AuthState>());
      });

      test('stores user', () {
        final state = AuthAuthenticated(user: user);
        
        expect(state.user, user);
        expect(state.user.name, 'Test User');
      });

      test('props returns user', () {
        final state = AuthAuthenticated(user: user);
        
        expect(state.props, contains(user));
      });

      test('two AuthAuthenticated with same user are equal', () {
        final state1 = AuthAuthenticated(user: user);
        final state2 = AuthAuthenticated(user: user);
        
        expect(state1, equals(state2));
      });

      test('two AuthAuthenticated with different users are not equal', () {
        const user2 = User(
          id: 2,
          name: 'Other User',
          phone: '70111111',
        );
        
        final state1 = AuthAuthenticated(user: user);
        final state2 = AuthAuthenticated(user: user2);
        
        expect(state1, isNot(equals(state2)));
      });
    });

    group('AuthUnauthenticated', () {
      test('is a subclass of AuthState', () {
        expect(AuthUnauthenticated(), isA<AuthState>());
      });

      test('props returns empty list', () {
        expect(AuthUnauthenticated().props, isEmpty);
      });

      test('two AuthUnauthenticated are equal', () {
        expect(AuthUnauthenticated(), equals(AuthUnauthenticated()));
      });
    });

    group('AuthError', () {
      test('is a subclass of AuthState', () {
        const state = AuthError(message: 'Test error');
        expect(state, isA<AuthState>());
      });

      test('stores message', () {
        const state = AuthError(message: 'Something went wrong');
        
        expect(state.message, 'Something went wrong');
      });

      test('props returns message', () {
        const state = AuthError(message: 'Error message');
        
        expect(state.props, contains('Error message'));
      });

      test('two AuthError with same message are equal', () {
        const state1 = AuthError(message: 'Error');
        const state2 = AuthError(message: 'Error');
        
        expect(state1, equals(state2));
      });

      test('two AuthError with different messages are not equal', () {
        const state1 = AuthError(message: 'Error 1');
        const state2 = AuthError(message: 'Error 2');
        
        expect(state1, isNot(equals(state2)));
      });
    });

    group('AuthProfileUpdated', () {
      late User user;

      setUp(() {
        user = const User(
          id: 1,
          name: 'Updated User',
          phone: '70000000',
        );
      });

      test('is a subclass of AuthState', () {
        expect(AuthProfileUpdated(user: user), isA<AuthState>());
      });

      test('stores user', () {
        final state = AuthProfileUpdated(user: user);
        
        expect(state.user, user);
      });

      test('props returns user', () {
        final state = AuthProfileUpdated(user: user);
        
        expect(state.props, contains(user));
      });

      test('two AuthProfileUpdated with same user are equal', () {
        final state1 = AuthProfileUpdated(user: user);
        final state2 = AuthProfileUpdated(user: user);
        
        expect(state1, equals(state2));
      });
    });

    group('State transitions', () {
      test('different states are not equal', () {
        const user = User(
          id: 1,
          name: 'Test',
          phone: '70000000',
        );

        final states = [
          AuthInitial(),
          AuthLoading(),
          const AuthOtpSent(phone: '70000000', isLogin: true),
          AuthAuthenticated(user: user),
          AuthUnauthenticated(),
          const AuthError(message: 'Error'),
          AuthProfileUpdated(user: user),
        ];

        // Verify each state is unique compared to others of different type
        for (var i = 0; i < states.length; i++) {
          for (var j = 0; j < states.length; j++) {
            if (i != j && states[i].runtimeType != states[j].runtimeType) {
              expect(states[i], isNot(equals(states[j])));
            }
          }
        }
      });
    });
  });
}
