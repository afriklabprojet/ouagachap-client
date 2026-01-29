import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:ouaga_chap_client/features/auth/domain/usecases/login_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late LoginUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = LoginUseCase(mockRepository);
  });

  group('LoginUseCase', () {
    const testPhone = '+22670123456';

    test('should call repository.login with correct phone', () async {
      // Arrange
      when(() => mockRepository.login(phone: testPhone))
          .thenAnswer((_) async {});

      // Act
      await useCase.call(phone: testPhone);

      // Assert
      verify(() => mockRepository.login(phone: testPhone)).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should throw exception when repository throws', () async {
      // Arrange
      when(() => mockRepository.login(phone: testPhone))
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => useCase.call(phone: testPhone),
        throwsException,
      );
    });

    test('should handle different phone formats', () async {
      // Arrange
      const phones = [
        '+22670123456',
        '70123456',
        '+226 70 12 34 56',
      ];

      for (final phone in phones) {
        when(() => mockRepository.login(phone: phone))
            .thenAnswer((_) async {});

        // Act
        await useCase.call(phone: phone);

        // Assert
        verify(() => mockRepository.login(phone: phone)).called(1);
      }
    });
  });
}
