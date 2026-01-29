import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/auth/domain/entities/user.dart';
import 'package:ouaga_chap_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:ouaga_chap_client/features/auth/domain/usecases/get_current_user_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late GetCurrentUserUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = GetCurrentUserUseCase(mockRepository);
  });

  group('GetCurrentUserUseCase', () {
    final testUser = User(
      id: 1,
      name: 'Jean Dupont',
      phone: '+22670123456',
      role: 'client',
    );

    test('should return user when user is logged in', () async {
      // Arrange
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => testUser);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, equals(testUser));
      verify(() => mockRepository.getCurrentUser()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return null when no user is logged in', () async {
      // Arrange
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => null);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isNull);
      verify(() => mockRepository.getCurrentUser()).called(1);
    });

    test('should throw exception when repository throws', () async {
      // Arrange
      when(() => mockRepository.getCurrentUser())
          .thenThrow(Exception('Token expired'));

      // Act & Assert
      expect(
        () => useCase.call(),
        throwsException,
      );
    });

    test('should return user with all properties', () async {
      // Arrange
      final userWithAllProps = User(
        id: 2,
        name: 'Marie Martin',
        phone: '+22671234567',
        email: 'marie@example.com',
        avatar: 'https://example.com/avatar.png',
        role: 'courier',
        isPhoneVerified: true,
        createdAt: DateTime(2024, 1, 15),
      );
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => userWithAllProps);

      // Act
      final result = await useCase.call();

      // Assert
      expect(result, isNotNull);
      expect(result!.id, equals(2));
      expect(result.name, equals('Marie Martin'));
      expect(result.phone, equals('+22671234567'));
      expect(result.email, equals('marie@example.com'));
      expect(result.avatar, equals('https://example.com/avatar.png'));
      expect(result.isCourier, isTrue);
      expect(result.isPhoneVerified, isTrue);
    });

    test('should be called multiple times independently', () async {
      // Arrange
      when(() => mockRepository.getCurrentUser())
          .thenAnswer((_) async => testUser);

      // Act
      await useCase.call();
      await useCase.call();
      await useCase.call();

      // Assert
      verify(() => mockRepository.getCurrentUser()).called(3);
    });
  });
}
