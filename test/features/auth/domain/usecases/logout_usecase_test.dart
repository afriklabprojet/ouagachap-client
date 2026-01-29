import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:ouaga_chap_client/features/auth/domain/usecases/logout_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LogoutUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LogoutUseCase(mockRepository);
  });

  group('LogoutUseCase', () {
    test('should call repository.logout', () async {
      // Arrange
      when(() => mockRepository.logout()).thenAnswer((_) async {});

      // Act
      await useCase.call();

      // Assert
      verify(() => mockRepository.logout()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw exception when repository throws', () async {
      // Arrange
      when(() => mockRepository.logout())
          .thenThrow(Exception('Logout failed'));

      // Act & Assert
      expect(
        () => useCase.call(),
        throwsException,
      );
    });

    test('should complete without error on success', () async {
      // Arrange
      when(() => mockRepository.logout()).thenAnswer((_) async {});

      // Act & Assert
      expect(useCase.call(), completes);
    });

    test('should be idempotent (can be called multiple times)', () async {
      // Arrange
      when(() => mockRepository.logout()).thenAnswer((_) async {});

      // Act
      await useCase.call();
      await useCase.call();

      // Assert
      verify(() => mockRepository.logout()).called(2);
    });

    test('should handle network errors gracefully', () async {
      // Arrange
      when(() => mockRepository.logout())
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () async => await useCase.call(),
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('Network error'),
        )),
      );
    });
  });
}
