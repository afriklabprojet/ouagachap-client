import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:ouaga_chap_client/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:ouaga_chap_client/features/auth/data/models/user_model.dart';
import 'package:ouaga_chap_client/features/auth/data/repositories/auth_repository_impl.dart';

// Mocks
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

// Fake pour UserModel
class FakeUserModel extends Fake implements UserModel {}

void main() {
  late AuthRepositoryImpl repository;
  late MockAuthRemoteDataSource mockRemoteDataSource;
  late MockAuthLocalDataSource mockLocalDataSource;

  setUpAll(() {
    registerFallbackValue(FakeUserModel());
  });

  setUp(() {
    mockRemoteDataSource = MockAuthRemoteDataSource();
    mockLocalDataSource = MockAuthLocalDataSource();
    repository = AuthRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('AuthRepositoryImpl', () {
    group('register', () {
      test('should call remoteDataSource.register with correct parameters', () async {
        // Arrange
        when(() => mockRemoteDataSource.register(
              name: any(named: 'name'),
              phone: any(named: 'phone'),
              email: any(named: 'email'),
            )).thenAnswer((_) async {});

        // Act
        await repository.register(
          name: 'Jean Dupont',
          phone: '+22670123456',
          email: 'jean@example.com',
        );

        // Assert
        verify(() => mockRemoteDataSource.register(
              name: 'Jean Dupont',
              phone: '+22670123456',
              email: 'jean@example.com',
            )).called(1);
      });

      test('should register without email when not provided', () async {
        // Arrange
        when(() => mockRemoteDataSource.register(
              name: any(named: 'name'),
              phone: any(named: 'phone'),
              email: null,
            )).thenAnswer((_) async {});

        // Act
        await repository.register(
          name: 'Jean Dupont',
          phone: '+22670123456',
        );

        // Assert
        verify(() => mockRemoteDataSource.register(
              name: 'Jean Dupont',
              phone: '+22670123456',
              email: null,
            )).called(1);
      });
    });

    group('login', () {
      test('should call remoteDataSource.login with correct phone', () async {
        // Arrange
        when(() => mockRemoteDataSource.login(phone: '+22670123456'))
            .thenAnswer((_) async {});

        // Act
        await repository.login(phone: '+22670123456');

        // Assert
        verify(() => mockRemoteDataSource.login(phone: '+22670123456')).called(1);
      });
    });

    group('verifyOtp', () {
      final testUserModel = UserModel(
        id: 1,
        name: 'Jean Dupont',
        phone: '+22670123456',
        role: 'client',
      );

      test('should verify OTP and save token and user', () async {
        // Arrange
        when(() => mockRemoteDataSource.verifyOtp(
              phone: any(named: 'phone'),
              otp: any(named: 'otp'),
              firebaseVerified: any(named: 'firebaseVerified'),
            )).thenAnswer((_) async => {
              'data': {
                'token': 'test_token_123',
                'user': testUserModel.toJson(),
              },
            });
        when(() => mockLocalDataSource.saveToken(any()))
            .thenAnswer((_) async {});
        when(() => mockLocalDataSource.saveUser(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.verifyOtp(
          phone: '+22670123456',
          otp: '123456',
        );

        // Assert
        expect(result.phone, equals('+22670123456'));
        verify(() => mockLocalDataSource.saveToken('test_token_123')).called(1);
        verify(() => mockLocalDataSource.saveUser(any())).called(1);
      });

      test('should pass firebaseVerified flag correctly', () async {
        // Arrange
        when(() => mockRemoteDataSource.verifyOtp(
              phone: '+22670123456',
              otp: '000000',
              firebaseVerified: true,
            )).thenAnswer((_) async => {
              'data': {
                'token': 'test_token_123',
                'user': testUserModel.toJson(),
              },
            });
        when(() => mockLocalDataSource.saveToken(any()))
            .thenAnswer((_) async {});
        when(() => mockLocalDataSource.saveUser(any()))
            .thenAnswer((_) async {});

        // Act
        await repository.verifyOtp(
          phone: '+22670123456',
          otp: '000000',
          firebaseVerified: true,
        );

        // Assert
        verify(() => mockRemoteDataSource.verifyOtp(
              phone: '+22670123456',
              otp: '000000',
              firebaseVerified: true,
            )).called(1);
      });
    });

    group('getCurrentUser', () {
      final testUserModel = UserModel(
        id: 1,
        name: 'Jean Dupont',
        phone: '+22670123456',
        role: 'client',
      );

      test('should return local user when available', () async {
        // Arrange
        when(() => mockLocalDataSource.getUser())
            .thenAnswer((_) async => testUserModel);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, equals(testUserModel));
        verifyNever(() => mockRemoteDataSource.getCurrentUser());
      });

      test('should fetch from remote when no local user and has token', () async {
        // Arrange
        when(() => mockLocalDataSource.getUser())
            .thenAnswer((_) async => null);
        when(() => mockLocalDataSource.getToken())
            .thenAnswer((_) async => 'valid_token');
        when(() => mockRemoteDataSource.getCurrentUser())
            .thenAnswer((_) async => testUserModel);
        when(() => mockLocalDataSource.saveUser(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, equals(testUserModel));
        verify(() => mockRemoteDataSource.getCurrentUser()).called(1);
        verify(() => mockLocalDataSource.saveUser(testUserModel)).called(1);
      });

      test('should return null when no token', () async {
        // Arrange
        when(() => mockLocalDataSource.getUser())
            .thenAnswer((_) async => null);
        when(() => mockLocalDataSource.getToken())
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isNull);
        verifyNever(() => mockRemoteDataSource.getCurrentUser());
      });

      test('should return null when remote fetch fails', () async {
        // Arrange
        when(() => mockLocalDataSource.getUser())
            .thenAnswer((_) async => null);
        when(() => mockLocalDataSource.getToken())
            .thenAnswer((_) async => 'valid_token');
        when(() => mockRemoteDataSource.getCurrentUser())
            .thenThrow(Exception('Network error'));

        // Act
        final result = await repository.getCurrentUser();

        // Assert
        expect(result, isNull);
      });
    });

    group('isLoggedIn', () {
      test('should return true when token exists', () async {
        // Arrange
        when(() => mockLocalDataSource.getToken())
            .thenAnswer((_) async => 'valid_token');

        // Act
        final result = await repository.isLoggedIn();

        // Assert
        expect(result, isTrue);
      });

      test('should return false when no token', () async {
        // Arrange
        when(() => mockLocalDataSource.getToken())
            .thenAnswer((_) async => null);

        // Act
        final result = await repository.isLoggedIn();

        // Assert
        expect(result, isFalse);
      });

      test('should return false when token is empty', () async {
        // Arrange
        when(() => mockLocalDataSource.getToken())
            .thenAnswer((_) async => '');

        // Act
        final result = await repository.isLoggedIn();

        // Assert
        expect(result, isFalse);
      });
    });

    group('logout', () {
      test('should clear local data after remote logout', () async {
        // Arrange
        when(() => mockRemoteDataSource.logout())
            .thenAnswer((_) async {});
        when(() => mockLocalDataSource.clearAll())
            .thenAnswer((_) async {});

        // Act
        await repository.logout();

        // Assert
        verify(() => mockRemoteDataSource.logout()).called(1);
        verify(() => mockLocalDataSource.clearAll()).called(1);
      });

      test('should clear local data even if remote logout fails', () async {
        // Arrange
        when(() => mockRemoteDataSource.logout())
            .thenThrow(Exception('Network error'));
        when(() => mockLocalDataSource.clearAll())
            .thenAnswer((_) async {});

        // Act
        await repository.logout();

        // Assert
        verify(() => mockLocalDataSource.clearAll()).called(1);
      });
    });

    group('updateProfile', () {
      final updatedUserModel = UserModel(
        id: 1,
        name: 'Jean Updated',
        phone: '+22670123456',
        email: 'new@example.com',
        role: 'client',
      );

      test('should update profile and save user locally', () async {
        // Arrange
        when(() => mockRemoteDataSource.updateProfile(
              name: 'Jean Updated',
              email: 'new@example.com',
              avatar: null,
            )).thenAnswer((_) async => updatedUserModel);
        when(() => mockLocalDataSource.saveUser(any()))
            .thenAnswer((_) async {});

        // Act
        final result = await repository.updateProfile(
          name: 'Jean Updated',
          email: 'new@example.com',
        );

        // Assert
        expect(result.name, equals('Jean Updated'));
        expect(result.email, equals('new@example.com'));
        verify(() => mockLocalDataSource.saveUser(updatedUserModel)).called(1);
      });
    });

    group('getToken', () {
      test('should return token from local data source', () async {
        // Arrange
        when(() => mockLocalDataSource.getToken())
            .thenAnswer((_) async => 'stored_token');

        // Act
        final result = await repository.getToken();

        // Assert
        expect(result, equals('stored_token'));
      });
    });
  });
}
