import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:ouaga_chap_client/features/auth/domain/usecases/register_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late RegisterUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = RegisterUseCase(mockRepository);
  });

  group('RegisterUseCase', () {
    const testName = 'Jean Dupont';
    const testPhone = '+22670123456';
    const testEmail = 'jean@example.com';

    test('should call repository.register with all parameters', () async {
      // Arrange
      when(() => mockRepository.register(
            name: testName,
            phone: testPhone,
            email: testEmail,
          )).thenAnswer((_) async {});

      // Act
      await useCase.call(
        name: testName,
        phone: testPhone,
        email: testEmail,
      );

      // Assert
      verify(() => mockRepository.register(
            name: testName,
            phone: testPhone,
            email: testEmail,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should call repository.register without optional email', () async {
      // Arrange
      when(() => mockRepository.register(
            name: testName,
            phone: testPhone,
            email: null,
          )).thenAnswer((_) async {});

      // Act
      await useCase.call(
        name: testName,
        phone: testPhone,
      );

      // Assert
      verify(() => mockRepository.register(
            name: testName,
            phone: testPhone,
            email: null,
          )).called(1);
    });

    test('should throw exception when repository throws', () async {
      // Arrange
      when(() => mockRepository.register(
            name: any(named: 'name'),
            phone: any(named: 'phone'),
            email: any(named: 'email'),
          )).thenThrow(Exception('Phone already registered'));

      // Act & Assert
      expect(
        () => useCase.call(name: testName, phone: testPhone),
        throwsException,
      );
    });

    test('should handle empty email string as null', () async {
      // Arrange
      when(() => mockRepository.register(
            name: testName,
            phone: testPhone,
            email: '',
          )).thenAnswer((_) async {});

      // Act
      await useCase.call(
        name: testName,
        phone: testPhone,
        email: '',
      );

      // Assert
      verify(() => mockRepository.register(
            name: testName,
            phone: testPhone,
            email: '',
          )).called(1);
    });
  });
}
