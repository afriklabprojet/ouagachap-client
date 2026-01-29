import 'package:flutter_test/flutter_test.dart';
import 'package:ouaga_chap_client/features/auth/data/models/user_model.dart';

void main() {
  group('UserModel', () {
    group('fromJson', () {
      test('should create UserModel from complete JSON', () {
        // Arrange
        final json = {
          'id': 1,
          'name': 'Jean Dupont',
          'phone': '+22670123456',
          'email': 'jean@example.com',
          'avatar': 'https://example.com/avatar.jpg',
          'role': 'client',
          'is_phone_verified': true,
          'created_at': '2024-01-15T10:30:00.000Z',
        };

        // Act
        final user = UserModel.fromJson(json);

        // Assert
        expect(user.id, equals(1));
        expect(user.name, equals('Jean Dupont'));
        expect(user.phone, equals('+22670123456'));
        expect(user.email, equals('jean@example.com'));
        expect(user.avatar, equals('https://example.com/avatar.jpg'));
        expect(user.role, equals('client'));
        expect(user.isPhoneVerified, isTrue);
      });

      test('should create UserModel with minimal JSON', () {
        // Arrange
        final json = {
          'id': 1,
          'name': 'Jean',
          'phone': '+22670123456',
        };

        // Act
        final user = UserModel.fromJson(json);

        // Assert
        expect(user.id, equals(1));
        expect(user.name, equals('Jean'));
        expect(user.phone, equals('+22670123456'));
        expect(user.email, isNull);
        expect(user.avatar, isNull);
      });

      test('should handle different role values', () {
        // Arrange & Act
        final clientUser = UserModel.fromJson({
          'id': 1,
          'name': 'Client',
          'phone': '+22670000001',
          'role': 'client',
        });

        final courierUser = UserModel.fromJson({
          'id': 2,
          'name': 'Courier',
          'phone': '+22670000002',
          'role': 'courier',
        });

        final adminUser = UserModel.fromJson({
          'id': 3,
          'name': 'Admin',
          'phone': '+22670000003',
          'role': 'admin',
        });

        // Assert
        expect(clientUser.isClient, isTrue);
        expect(courierUser.isCourier, isTrue);
        expect(adminUser.isAdmin, isTrue);
      });

      test('should default role to client when not provided', () {
        // Arrange
        final json = {
          'id': 1,
          'name': 'Jean',
          'phone': '+22670123456',
        };

        // Act
        final user = UserModel.fromJson(json);

        // Assert
        expect(user.role, equals('client'));
        expect(user.isClient, isTrue);
      });
    });

    group('toJson', () {
      test('should convert UserModel to JSON', () {
        // Arrange
        final user = UserModel(
          id: 1,
          name: 'Jean Dupont',
          phone: '+22670123456',
          email: 'jean@example.com',
          avatar: 'https://example.com/avatar.jpg',
          role: 'client',
          isPhoneVerified: true,
          createdAt: DateTime(2024, 1, 15, 10, 30),
        );

        // Act
        final json = user.toJson();

        // Assert
        expect(json['id'], equals(1));
        expect(json['name'], equals('Jean Dupont'));
        expect(json['phone'], equals('+22670123456'));
        expect(json['email'], equals('jean@example.com'));
        expect(json['avatar'], equals('https://example.com/avatar.jpg'));
        expect(json['role'], equals('client'));
        expect(json['is_phone_verified'], isTrue);
      });

      test('should handle null optional fields', () {
        // Arrange
        final user = UserModel(
          id: 1,
          name: 'Jean',
          phone: '+22670123456',
          role: 'client',
        );

        // Act
        final json = user.toJson();

        // Assert
        expect(json['email'], isNull);
        expect(json['avatar'], isNull);
      });
    });

    group('Equality', () {
      test('should be equal when all properties match', () {
        // Arrange
        final user1 = UserModel(
          id: 1,
          name: 'Jean',
          phone: '+22670123456',
          role: 'client',
        );

        final user2 = UserModel(
          id: 1,
          name: 'Jean',
          phone: '+22670123456',
          role: 'client',
        );

        // Assert
        expect(user1, equals(user2));
      });

      test('should not be equal when id differs', () {
        // Arrange
        final user1 = UserModel(
          id: 1,
          name: 'Jean',
          phone: '+22670123456',
          role: 'client',
        );

        final user2 = UserModel(
          id: 2,
          name: 'Jean',
          phone: '+22670123456',
          role: 'client',
        );

        // Assert
        expect(user1, isNot(equals(user2)));
      });
    });

    group('Role checks', () {
      test('isClient should return true for client role', () {
        final user = UserModel(id: 1, name: 'Test', phone: '+226', role: 'client');
        expect(user.isClient, isTrue);
        expect(user.isCourier, isFalse);
        expect(user.isAdmin, isFalse);
      });

      test('isCourier should return true for courier role', () {
        final user = UserModel(id: 1, name: 'Test', phone: '+226', role: 'courier');
        expect(user.isClient, isFalse);
        expect(user.isCourier, isTrue);
        expect(user.isAdmin, isFalse);
      });

      test('isAdmin should return true for admin role', () {
        final user = UserModel(id: 1, name: 'Test', phone: '+226', role: 'admin');
        expect(user.isClient, isFalse);
        expect(user.isCourier, isFalse);
        expect(user.isAdmin, isTrue);
      });
    });

    group('fromEntity', () {
      test('should create UserModel from User entity', () {
        // Arrange
        final user = UserModel(
          id: 1,
          name: 'Jean Dupont',
          phone: '+22670123456',
          email: 'jean@example.com',
          avatar: 'https://example.com/avatar.jpg',
          role: 'client',
          isPhoneVerified: true,
          createdAt: DateTime(2024, 1, 15),
        );

        // Act
        final model = UserModel.fromEntity(user);

        // Assert
        expect(model.id, user.id);
        expect(model.name, user.name);
        expect(model.phone, user.phone);
        expect(model.email, user.email);
        expect(model.avatar, user.avatar);
        expect(model.role, user.role);
        expect(model.isPhoneVerified, user.isPhoneVerified);
        expect(model.createdAt, user.createdAt);
      });

      test('should create UserModel from User entity with null fields', () {
        // Arrange
        final user = UserModel(
          id: 1,
          name: 'Jean',
          phone: '+22670123456',
        );

        // Act
        final model = UserModel.fromEntity(user);

        // Assert
        expect(model.id, user.id);
        expect(model.name, user.name);
        expect(model.phone, user.phone);
        expect(model.email, isNull);
        expect(model.avatar, isNull);
        expect(model.createdAt, isNull);
      });
    });

    group('fromJson edge cases', () {
      test('should set isPhoneVerified from phone_verified_at', () {
        // Arrange
        final json = {
          'id': 1,
          'name': 'Jean',
          'phone': '+22670123456',
          'phone_verified_at': '2024-01-15T10:30:00.000Z',
        };

        // Act
        final user = UserModel.fromJson(json);

        // Assert
        expect(user.isPhoneVerified, isTrue);
      });

      test('should default name to Client when null', () {
        // Arrange
        final json = {
          'id': 1,
          'name': null,
          'phone': '+22670123456',
        };

        // Act
        final user = UserModel.fromJson(json);

        // Assert
        expect(user.name, 'Client');
      });

      test('should handle missing created_at', () {
        // Arrange
        final json = {
          'id': 1,
          'name': 'Jean',
          'phone': '+22670123456',
        };

        // Act
        final user = UserModel.fromJson(json);

        // Assert
        expect(user.createdAt, isNull);
      });
    });
  });
}
