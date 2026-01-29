import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:ouaga_chap_client/features/auth/domain/entities/user.dart';
import 'package:ouaga_chap_client/features/auth/domain/repositories/auth_repository.dart';
import 'package:ouaga_chap_client/features/auth/domain/usecases/verify_otp_usecase.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late VerifyOtpUseCase useCase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    useCase = VerifyOtpUseCase(mockRepository);
  });

  group('VerifyOtpUseCase', () {
    const testPhone = '+22670123456';
    const testOtp = '123456';
    final testUser = User(
      id: 1,
      name: 'Jean Dupont',
      phone: testPhone,
      role: 'client',
    );

    test('should call repository.verifyOtp and return user', () async {
      // Arrange
      when(() => mockRepository.verifyOtp(
            phone: testPhone,
            otp: testOtp,
            firebaseVerified: false,
          )).thenAnswer((_) async => testUser);

      // Act
      final result = await useCase.call(phone: testPhone, otp: testOtp);

      // Assert
      expect(result, equals(testUser));
      verify(() => mockRepository.verifyOtp(
            phone: testPhone,
            otp: testOtp,
            firebaseVerified: false,
          )).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should pass firebaseVerified=true when specified', () async {
      // Arrange
      when(() => mockRepository.verifyOtp(
            phone: testPhone,
            otp: testOtp,
            firebaseVerified: true,
          )).thenAnswer((_) async => testUser);

      // Act
      final result = await useCase.call(
        phone: testPhone,
        otp: testOtp,
        firebaseVerified: true,
      );

      // Assert
      expect(result, equals(testUser));
      verify(() => mockRepository.verifyOtp(
            phone: testPhone,
            otp: testOtp,
            firebaseVerified: true,
          )).called(1);
    });

    test('should throw exception when OTP is invalid', () async {
      // Arrange
      when(() => mockRepository.verifyOtp(
            phone: any(named: 'phone'),
            otp: any(named: 'otp'),
            firebaseVerified: any(named: 'firebaseVerified'),
          )).thenThrow(Exception('Invalid OTP'));

      // Act & Assert
      expect(
        () => useCase.call(phone: testPhone, otp: '000000'),
        throwsException,
      );
    });

    test('should throw exception when OTP is expired', () async {
      // Arrange
      when(() => mockRepository.verifyOtp(
            phone: testPhone,
            otp: testOtp,
            firebaseVerified: false,
          )).thenThrow(Exception('OTP expired'));

      // Act & Assert
      expect(
        () => useCase.call(phone: testPhone, otp: testOtp),
        throwsException,
      );
    });

    test('should return user with correct properties', () async {
      // Arrange
      final adminUser = User(
        id: 2,
        name: 'Admin User',
        phone: testPhone,
        email: 'admin@example.com',
        role: 'admin',
      );
      when(() => mockRepository.verifyOtp(
            phone: testPhone,
            otp: testOtp,
            firebaseVerified: true,
          )).thenAnswer((_) async => adminUser);

      // Act
      final result = await useCase.call(
        phone: testPhone,
        otp: testOtp,
        firebaseVerified: true,
      );

      // Assert
      expect(result.id, equals(2));
      expect(result.name, equals('Admin User'));
      expect(result.email, equals('admin@example.com'));
      expect(result.isAdmin, isTrue);
    });
  });
}
