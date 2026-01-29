import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ouaga_chap_client/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:ouaga_chap_client/features/auth/data/models/user_model.dart';

void main() {
  late AuthLocalDataSourceImpl dataSource;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    dataSource = AuthLocalDataSourceImpl(prefs);
  });

  group('AuthLocalDataSourceImpl', () {
    group('Token operations', () {
      test('saveToken should store token', () async {
        // Act
        await dataSource.saveToken('test_token_123');
        final result = await dataSource.getToken();

        // Assert
        expect(result, equals('test_token_123'));
      });

      test('getToken should return null when no token saved', () async {
        // Act
        final result = await dataSource.getToken();

        // Assert
        expect(result, isNull);
      });

      test('deleteToken should remove stored token', () async {
        // Arrange
        await dataSource.saveToken('test_token');

        // Act
        await dataSource.deleteToken();
        final result = await dataSource.getToken();

        // Assert
        expect(result, isNull);
      });

      test('saveToken should overwrite existing token', () async {
        // Arrange
        await dataSource.saveToken('old_token');

        // Act
        await dataSource.saveToken('new_token');
        final result = await dataSource.getToken();

        // Assert
        expect(result, equals('new_token'));
      });
    });

    group('User operations', () {
      final testUser = UserModel(
        id: 1,
        name: 'Jean Dupont',
        phone: '+22670123456',
        email: 'jean@example.com',
        role: 'client',
      );

      test('saveUser should store user', () async {
        // Act
        await dataSource.saveUser(testUser);
        final result = await dataSource.getUser();

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals(1));
        expect(result.name, equals('Jean Dupont'));
        expect(result.phone, equals('+22670123456'));
      });

      test('getUser should return null when no user saved', () async {
        // Act
        final result = await dataSource.getUser();

        // Assert
        expect(result, isNull);
      });

      test('deleteUser should remove stored user', () async {
        // Arrange
        await dataSource.saveUser(testUser);

        // Act
        await dataSource.deleteUser();
        final result = await dataSource.getUser();

        // Assert
        expect(result, isNull);
      });

      test('getUser should handle invalid JSON gracefully', () async {
        // Arrange
        SharedPreferences.setMockInitialValues({
          'user_data': 'invalid_json',
        });
        final prefs = await SharedPreferences.getInstance();
        final ds = AuthLocalDataSourceImpl(prefs);

        // Act
        final result = await ds.getUser();

        // Assert
        expect(result, isNull);
      });
    });

    group('clearAll', () {
      test('should clear both token and user', () async {
        // Arrange
        await dataSource.saveToken('test_token');
        await dataSource.saveUser(UserModel(
          id: 1,
          name: 'Test',
          phone: '+22670000000',
          role: 'client',
        ));

        // Act
        await dataSource.clearAll();

        // Assert
        expect(await dataSource.getToken(), isNull);
        expect(await dataSource.getUser(), isNull);
      });
    });

    group('Onboarding', () {
      test('hasSeenOnboarding should return false by default', () async {
        // Act
        final result = await dataSource.hasSeenOnboarding();

        // Assert
        expect(result, isFalse);
      });

      test('setHasSeenOnboarding should save onboarding status', () async {
        // Act
        await dataSource.setHasSeenOnboarding(true);
        final result = await dataSource.hasSeenOnboarding();

        // Assert
        expect(result, isTrue);
      });

      test('setHasSeenOnboarding should toggle status', () async {
        // Arrange
        await dataSource.setHasSeenOnboarding(true);

        // Act
        await dataSource.setHasSeenOnboarding(false);
        final result = await dataSource.hasSeenOnboarding();

        // Assert
        expect(result, isFalse);
      });
    });
  });
}
