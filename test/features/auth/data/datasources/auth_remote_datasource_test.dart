import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/core/network/api_client.dart';
import 'package:ouaga_chap_client/features/auth/data/datasources/auth_remote_datasource.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late AuthRemoteDataSourceImpl dataSource;
  late MockApiClient mockApiClient;

  setUp(() {
    mockApiClient = MockApiClient();
    dataSource = AuthRemoteDataSourceImpl(mockApiClient);
  });

  group('AuthRemoteDataSourceImpl', () {
    group('register', () {
      test('should call apiClient.post with correct data', () async {
        // Arrange
        when(() => mockApiClient.post(
              'auth/register',
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: 'auth/register'),
              statusCode: 201,
              data: {'success': true},
            ));

        // Act
        await dataSource.register(
          name: 'Jean Dupont',
          phone: '+22670123456',
          email: 'jean@example.com',
        );

        // Assert
        verify(() => mockApiClient.post(
              'auth/register',
              data: {
                'name': 'Jean Dupont',
                'phone': '+22670123456',
                'email': 'jean@example.com',
              },
            )).called(1);
      });

      test('should not include email if null', () async {
        // Arrange
        when(() => mockApiClient.post(
              'auth/register',
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: 'auth/register'),
              statusCode: 201,
            ));

        // Act
        await dataSource.register(
          name: 'Jean Dupont',
          phone: '+22670123456',
        );

        // Assert
        verify(() => mockApiClient.post(
              'auth/register',
              data: {
                'name': 'Jean Dupont',
                'phone': '+22670123456',
              },
            )).called(1);
      });
    });

    group('login', () {
      test('should call apiClient.post with phone', () async {
        // Arrange
        when(() => mockApiClient.post(
              'auth/otp/send',
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: 'auth/otp/send'),
              statusCode: 200,
            ));

        // Act
        await dataSource.login(phone: '+22670123456');

        // Assert
        verify(() => mockApiClient.post(
              'auth/otp/send',
              data: {'phone': '+22670123456'},
            )).called(1);
      });
    });

    group('verifyOtp', () {
      test('should return map with user and token data', () async {
        // Arrange
        final responseData = {
          'data': {
            'token': 'test_token',
            'user': {
              'id': 1,
              'name': 'Jean',
              'phone': '+22670123456',
              'role': 'client',
            },
          },
        };
        when(() => mockApiClient.post(
              'auth/otp/verify',
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: 'auth/otp/verify'),
              statusCode: 200,
              data: responseData,
            ));

        // Act
        final result = await dataSource.verifyOtp(
          phone: '+22670123456',
          otp: '123456',
        );

        // Assert
        expect(result, equals(responseData));
      });

      test('should include firebase_verified when true', () async {
        // Arrange
        when(() => mockApiClient.post(
              'auth/otp/verify',
              data: {
                'phone': '+22670123456',
                'code': '000000',
                'firebase_verified': true,
              },
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: 'auth/otp/verify'),
              statusCode: 200,
              data: {'data': {}},
            ));

        // Act
        await dataSource.verifyOtp(
          phone: '+22670123456',
          otp: '000000',
          firebaseVerified: true,
        );

        // Assert
        verify(() => mockApiClient.post(
              'auth/otp/verify',
              data: {
                'phone': '+22670123456',
                'code': '000000',
                'firebase_verified': true,
              },
            )).called(1);
      });
    });

    group('getCurrentUser', () {
      test('should return UserModel from response', () async {
        // Arrange
        final userData = {
          'id': 1,
          'name': 'Jean Dupont',
          'phone': '+22670123456',
          'email': 'jean@example.com',
          'role': 'client',
        };
        when(() => mockApiClient.get('auth/me'))
            .thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: 'auth/me'),
              statusCode: 200,
              data: {'data': userData},
            ));

        // Act
        final result = await dataSource.getCurrentUser();

        // Assert
        expect(result.id, equals(1));
        expect(result.name, equals('Jean Dupont'));
        expect(result.phone, equals('+22670123456'));
      });

      test('should handle response without data wrapper', () async {
        // Arrange
        final userData = {
          'id': 1,
          'name': 'Jean Dupont',
          'phone': '+22670123456',
          'role': 'client',
        };
        when(() => mockApiClient.get('auth/me'))
            .thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: 'auth/me'),
              statusCode: 200,
              data: userData,
            ));

        // Act
        final result = await dataSource.getCurrentUser();

        // Assert
        expect(result.id, equals(1));
      });
    });

    group('updateProfile', () {
      test('should call apiClient.put with profile data', () async {
        // Arrange
        final userData = {
          'id': 1,
          'name': 'Jean Updated',
          'phone': '+22670123456',
          'email': 'new@example.com',
          'role': 'client',
        };
        when(() => mockApiClient.put(
              'auth/profile',
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: 'auth/profile'),
              statusCode: 200,
              data: {'data': userData},
            ));

        // Act
        final result = await dataSource.updateProfile(
          name: 'Jean Updated',
          email: 'new@example.com',
        );

        // Assert
        expect(result.name, equals('Jean Updated'));
        expect(result.email, equals('new@example.com'));
      });

      test('should only include provided fields', () async {
        // Arrange
        when(() => mockApiClient.put(
              'auth/profile',
              data: {'name': 'Only Name'},
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: 'auth/profile'),
              statusCode: 200,
              data: {
                'data': {
                  'id': 1,
                  'name': 'Only Name',
                  'phone': '+226',
                  'role': 'client',
                }
              },
            ));

        // Act
        await dataSource.updateProfile(name: 'Only Name');

        // Assert
        verify(() => mockApiClient.put(
              'auth/profile',
              data: {'name': 'Only Name'},
            )).called(1);
      });

      test('should include avatar when provided', () async {
        // Arrange
        when(() => mockApiClient.put(
              'auth/profile',
              data: {
                'name': 'Test Name',
                'avatar': 'https://example.com/avatar.jpg',
              },
            )).thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: 'auth/profile'),
              statusCode: 200,
              data: {
                'data': {
                  'id': 1,
                  'name': 'Test Name',
                  'phone': '+226',
                  'role': 'client',
                  'avatar': 'https://example.com/avatar.jpg',
                }
              },
            ));

        // Act
        final result = await dataSource.updateProfile(
          name: 'Test Name',
          avatar: 'https://example.com/avatar.jpg',
        );

        // Assert
        verify(() => mockApiClient.put(
              'auth/profile',
              data: {
                'name': 'Test Name',
                'avatar': 'https://example.com/avatar.jpg',
              },
            )).called(1);
        expect(result.name, equals('Test Name'));
      });
    });

    group('logout', () {
      test('should call apiClient.post on logout endpoint', () async {
        // Arrange
        when(() => mockApiClient.post(any()))
            .thenAnswer((_) async => Response(
              requestOptions: RequestOptions(path: '/auth/logout'),
              statusCode: 200,
            ));

        // Act
        await dataSource.logout();

        // Assert
        verify(() => mockApiClient.post('/auth/logout', data: null, queryParameters: null, options: null)).called(1);
      });
    });
  });
}
