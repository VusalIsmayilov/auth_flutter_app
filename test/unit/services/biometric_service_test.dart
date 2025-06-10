import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';

import 'package:auth_flutter_app/services/biometric_service.dart';
import 'package:auth_flutter_app/data/datasources/local/secure_storage_service.dart';
import 'package:auth_flutter_app/core/errors/exceptions.dart';

import 'biometric_service_test.mocks.dart';

@GenerateMocks([
  LocalAuthentication,
  SecureStorageService,
  Logger,
])
void main() {
  late BiometricService biometricService;
  late MockLocalAuthentication mockLocalAuth;
  late MockSecureStorageService mockStorageService;
  late MockLogger mockLogger;

  setUp(() {
    mockLocalAuth = MockLocalAuthentication();
    mockStorageService = MockSecureStorageService();
    mockLogger = MockLogger();
    biometricService = BiometricService(
      localAuth: mockLocalAuth,
      storageService: mockStorageService,
      logger: mockLogger,
    );
  });

  group('BiometricService', () {
    group('isBiometricAvailable', () {
      test('should return true when biometric is available and device is supported', () async {
        // arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);

        // act
        final result = await biometricService.isBiometricAvailable();

        // assert
        expect(result, true);
        verify(mockLocalAuth.canCheckBiometrics);
        verify(mockLocalAuth.isDeviceSupported());
      });

      test('should return false when biometric is not available', () async {
        // arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => false);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);

        // act
        final result = await biometricService.isBiometricAvailable();

        // assert
        expect(result, false);
      });

      test('should return false when device is not supported', () async {
        // arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => false);

        // act
        final result = await biometricService.isBiometricAvailable();

        // assert
        expect(result, false);
      });

      test('should return false when exception occurs', () async {
        // arrange
        when(mockLocalAuth.canCheckBiometrics).thenThrow(Exception('Test error'));

        // act
        final result = await biometricService.isBiometricAvailable();

        // assert
        expect(result, false);
        verify(mockLogger.e('Error checking biometric availability: Exception: Test error'));
      });
    });

    group('getAvailableBiometrics', () {
      test('should return list of available biometrics', () async {
        // arrange
        const expectedBiometrics = [BiometricType.fingerprint, BiometricType.face];
        when(mockLocalAuth.getAvailableBiometrics())
            .thenAnswer((_) async => expectedBiometrics);

        // act
        final result = await biometricService.getAvailableBiometrics();

        // assert
        expect(result, expectedBiometrics);
        verify(mockLocalAuth.getAvailableBiometrics());
      });

      test('should return empty list when exception occurs', () async {
        // arrange
        when(mockLocalAuth.getAvailableBiometrics())
            .thenThrow(Exception('Test error'));

        // act
        final result = await biometricService.getAvailableBiometrics();

        // assert
        expect(result, isEmpty);
        verify(mockLogger.e('Error getting available biometrics: Exception: Test error'));
      });
    });

    group('isBiometricEnabled', () {
      test('should return true when biometric is enabled in storage', () async {
        // arrange
        when(mockStorageService.isBiometricEnabled())
            .thenAnswer((_) async => true);

        // act
        final result = await biometricService.isBiometricEnabled();

        // assert
        expect(result, true);
        verify(mockStorageService.isBiometricEnabled());
      });

      test('should return false when biometric is disabled in storage', () async {
        // arrange
        when(mockStorageService.isBiometricEnabled())
            .thenAnswer((_) async => false);

        // act
        final result = await biometricService.isBiometricEnabled();

        // assert
        expect(result, false);
      });

      test('should return false when exception occurs', () async {
        // arrange
        when(mockStorageService.isBiometricEnabled())
            .thenThrow(Exception('Storage error'));

        // act
        final result = await biometricService.isBiometricEnabled();

        // assert
        expect(result, false);
        verify(mockLogger.e('Error checking biometric enabled status: Exception: Storage error'));
      });
    });

    group('setBiometricEnabled', () {
      test('should store biometric enabled status', () async {
        // arrange
        when(mockStorageService.storeBiometricEnabled(any))
            .thenAnswer((_) async {});

        // act
        await biometricService.setBiometricEnabled(true);

        // assert
        verify(mockStorageService.storeBiometricEnabled(true));
        verify(mockLogger.d('Biometric authentication enabled'));
      });

      test('should throw BiometricException when storage fails', () async {
        // arrange
        when(mockStorageService.storeBiometricEnabled(any))
            .thenThrow(Exception('Storage error'));

        // act & assert
        expect(
          () async => await biometricService.setBiometricEnabled(true),
          throwsA(isA<BiometricException>()),
        );
        verify(mockLogger.e('Error setting biometric enabled status: Exception: Storage error'));
      });
    });

    group('authenticateWithBiometrics', () {
      test('should return true when authentication is successful', () async {
        // arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockStorageService.isBiometricEnabled()).thenAnswer((_) async => true);
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => true);

        // act
        final result = await biometricService.authenticateWithBiometrics();

        // assert
        expect(result, true);
        verify(mockLocalAuth.authenticate(
          localizedReason: 'Please authenticate to access your account',
          options: anyNamed('options'),
        ));
        verify(mockLogger.d('Biometric authentication successful'));
      });

      test('should return false when authentication fails', () async {
        // arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockStorageService.isBiometricEnabled()).thenAnswer((_) async => true);
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => false);

        // act
        final result = await biometricService.authenticateWithBiometrics();

        // assert
        expect(result, false);
        verify(mockLogger.w('Biometric authentication failed or cancelled by user'));
      });

      test('should throw BiometricException when biometric is not available', () async {
        // arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => false);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);

        // act & assert
        expect(
          () async => await biometricService.authenticateWithBiometrics(),
          throwsA(isA<BiometricException>()),
        );
      });

      test('should throw BiometricException when biometric is not enabled', () async {
        // arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockStorageService.isBiometricEnabled()).thenAnswer((_) async => false);

        // act & assert
        expect(
          () async => await biometricService.authenticateWithBiometrics(),
          throwsA(isA<BiometricException>()),
        );
      });
    });

    group('setupBiometricAuthentication', () {
      const testEmail = 'test@example.com';
      const testPassword = 'hashedPassword123';

      test('should return true when setup is successful', () async {
        // arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => true);
        when(mockStorageService.storeUserPreference(any, any))
            .thenAnswer((_) async {});
        when(mockStorageService.storeBiometricEnabled(any))
            .thenAnswer((_) async {});

        // act
        final result = await biometricService.setupBiometricAuthentication(
          email: testEmail,
          hashedPassword: testPassword,
        );

        // assert
        expect(result, true);
        verify(mockStorageService.storeUserPreference('biometric_email', testEmail));
        verify(mockStorageService.storeUserPreference('biometric_password', testPassword));
        verify(mockStorageService.storeBiometricEnabled(true));
        verify(mockLogger.d('Biometric authentication setup successful for user: $testEmail'));
      });

      test('should return false when user cancels authentication', () async {
        // arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => true);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);
        when(mockLocalAuth.authenticate(
          localizedReason: anyNamed('localizedReason'),
          options: anyNamed('options'),
        )).thenAnswer((_) async => false);

        // act
        final result = await biometricService.setupBiometricAuthentication(
          email: testEmail,
          hashedPassword: testPassword,
        );

        // assert
        expect(result, false);
        verify(mockLogger.w('Biometric setup cancelled by user'));
        verifyNever(mockStorageService.storeUserPreference(any, any));
      });

      test('should throw BiometricException when biometric is not available', () async {
        // arrange
        when(mockLocalAuth.canCheckBiometrics).thenAnswer((_) async => false);
        when(mockLocalAuth.isDeviceSupported()).thenAnswer((_) async => true);

        // act & assert
        expect(
          () async => await biometricService.setupBiometricAuthentication(
            email: testEmail,
            hashedPassword: testPassword,
          ),
          throwsA(isA<BiometricException>()),
        );
      });
    });

    group('getBiometricCapabilityDescription', () {
      test('should return "Face ID" when face biometric is available', () async {
        // arrange
        when(mockLocalAuth.getAvailableBiometrics())
            .thenAnswer((_) async => [BiometricType.face]);

        // act
        final result = await biometricService.getBiometricCapabilityDescription();

        // assert
        expect(result, 'Face ID');
      });

      test('should return "Fingerprint" when fingerprint biometric is available', () async {
        // arrange
        when(mockLocalAuth.getAvailableBiometrics())
            .thenAnswer((_) async => [BiometricType.fingerprint]);

        // act
        final result = await biometricService.getBiometricCapabilityDescription();

        // assert
        expect(result, 'Fingerprint');
      });

      test('should return "Iris Scan" when iris biometric is available', () async {
        // arrange
        when(mockLocalAuth.getAvailableBiometrics())
            .thenAnswer((_) async => [BiometricType.iris]);

        // act
        final result = await biometricService.getBiometricCapabilityDescription();

        // assert
        expect(result, 'Iris Scan');
      });

      test('should return "Biometric authentication not available" when no biometrics', () async {
        // arrange
        when(mockLocalAuth.getAvailableBiometrics())
            .thenAnswer((_) async => []);

        // act
        final result = await biometricService.getBiometricCapabilityDescription();

        // assert
        expect(result, 'Biometric authentication not available');
      });
    });
  });
}