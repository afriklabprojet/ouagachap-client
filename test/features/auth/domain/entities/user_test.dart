import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/auth/domain/entities/user.dart';

void main() {
  group('User Entity', () {
    late User user;

    setUp(() {
      user = const User(
        id: 1,
        name: 'John Doe',
        phone: '70123456',
        email: 'john@example.com',
        avatar: 'https://example.com/avatar.png',
        role: 'client',
        isPhoneVerified: true,
        createdAt: null,
      );
    });

    group('Constructor', () {
      test('creates user with required fields', () {
        const minimalUser = User(
          id: 1,
          name: 'Test',
          phone: '70000000',
        );

        expect(minimalUser.id, 1);
        expect(minimalUser.name, 'Test');
        expect(minimalUser.phone, '70000000');
        expect(minimalUser.email, isNull);
        expect(minimalUser.avatar, isNull);
        expect(minimalUser.role, 'client');
        expect(minimalUser.isPhoneVerified, false);
        expect(minimalUser.createdAt, isNull);
      });

      test('creates user with all fields', () {
        final now = DateTime.now();
        final fullUser = User(
          id: 1,
          name: 'John Doe',
          phone: '70123456',
          email: 'john@example.com',
          avatar: 'avatar.png',
          role: 'courier',
          isPhoneVerified: true,
          createdAt: now,
        );

        expect(fullUser.id, 1);
        expect(fullUser.name, 'John Doe');
        expect(fullUser.phone, '70123456');
        expect(fullUser.email, 'john@example.com');
        expect(fullUser.avatar, 'avatar.png');
        expect(fullUser.role, 'courier');
        expect(fullUser.isPhoneVerified, true);
        expect(fullUser.createdAt, now);
      });
    });

    group('Role checks', () {
      test('isClient returns true for client role', () {
        expect(user.isClient, isTrue);
        expect(user.isCourier, isFalse);
        expect(user.isAdmin, isFalse);
      });

      test('isCourier returns true for courier role', () {
        final courier = user.copyWith(role: 'courier');
        expect(courier.isClient, isFalse);
        expect(courier.isCourier, isTrue);
        expect(courier.isAdmin, isFalse);
      });

      test('isAdmin returns true for admin role', () {
        final admin = user.copyWith(role: 'admin');
        expect(admin.isClient, isFalse);
        expect(admin.isCourier, isFalse);
        expect(admin.isAdmin, isTrue);
      });
    });

    group('copyWith', () {
      test('copies with no changes', () {
        final copy = user.copyWith();
        expect(copy, equals(user));
      });

      test('copies with id change', () {
        final copy = user.copyWith(id: 2);
        expect(copy.id, 2);
        expect(copy.name, user.name);
      });

      test('copies with name change', () {
        final copy = user.copyWith(name: 'Jane Doe');
        expect(copy.name, 'Jane Doe');
        expect(copy.id, user.id);
      });

      test('copies with phone change', () {
        final copy = user.copyWith(phone: '70999999');
        expect(copy.phone, '70999999');
      });

      test('copies with email change', () {
        final copy = user.copyWith(email: 'new@example.com');
        expect(copy.email, 'new@example.com');
      });

      test('copies with avatar change', () {
        final copy = user.copyWith(avatar: 'new_avatar.png');
        expect(copy.avatar, 'new_avatar.png');
      });

      test('copies with role change', () {
        final copy = user.copyWith(role: 'courier');
        expect(copy.role, 'courier');
        expect(copy.isCourier, isTrue);
      });

      test('copies with isPhoneVerified change', () {
        final copy = user.copyWith(isPhoneVerified: false);
        expect(copy.isPhoneVerified, isFalse);
      });

      test('copies with createdAt change', () {
        final newDate = DateTime(2024, 1, 1);
        final copy = user.copyWith(createdAt: newDate);
        expect(copy.createdAt, newDate);
      });
    });

    group('Equatable', () {
      test('users with same data are equal', () {
        const user1 = User(
          id: 1,
          name: 'Test',
          phone: '70000000',
        );
        const user2 = User(
          id: 1,
          name: 'Test',
          phone: '70000000',
        );

        expect(user1, equals(user2));
      });

      test('users with different id are not equal', () {
        const user1 = User(
          id: 1,
          name: 'Test',
          phone: '70000000',
        );
        const user2 = User(
          id: 2,
          name: 'Test',
          phone: '70000000',
        );

        expect(user1, isNot(equals(user2)));
      });

      test('users with different name are not equal', () {
        const user1 = User(
          id: 1,
          name: 'Test1',
          phone: '70000000',
        );
        const user2 = User(
          id: 1,
          name: 'Test2',
          phone: '70000000',
        );

        expect(user1, isNot(equals(user2)));
      });

      test('props returns correct list', () {
        expect(user.props, contains(user.id));
        expect(user.props, contains(user.name));
        expect(user.props, contains(user.phone));
        expect(user.props, contains(user.email));
        expect(user.props, contains(user.role));
      });
    });
  });
}
