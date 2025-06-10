import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';

import 'package:auth_flutter_app/core/network/certificate_pinning.dart';

import 'certificate_pinning_test.mocks.dart';

@GenerateMocks([
  Logger,
])
void main() {
  late MockLogger mockLogger;

  setUp(() {
    mockLogger = MockLogger();
  });

  group('CertificatePinning', () {
    group('initialization', () {
      test('should create CertificatePinning with default parameters', () {
        // arrange
        final pins = <String, List<String>>{
          'api.example.com': ['sha256:test_fingerprint'],
        };

        // act
        final certificatePinning = CertificatePinning(
          pinnedCertificates: pins,
          logger: mockLogger,
        );

        // assert
        expect(certificatePinning, isNotNull);
      });

      test('should create interceptor successfully', () {
        // arrange
        final pins = <String, List<String>>{
          'api.example.com': ['sha256:test_fingerprint'],
        };
        final certificatePinning = CertificatePinning(
          pinnedCertificates: pins,
          logger: mockLogger,
        );

        // act
        final interceptor = certificatePinning.createInterceptor();

        // assert
        expect(interceptor, isNotNull);
        expect(interceptor, isA<Interceptor>());
      });
    });

    group('addPin', () {
      test('should add pin for new host', () {
        // arrange
        final certificatePinning = CertificatePinning(
          pinnedCertificates: {},
          logger: mockLogger,
        );

        // act
        certificatePinning.addPin('api.example.com', 'sha256:test_fingerprint');

        // assert
        verify(mockLogger.d('Added certificate pin for api.example.com: sha256:test_fingerprint'));
      });

      test('should add additional pin for existing host', () {
        // arrange
        final pins = <String, List<String>>{
          'api.example.com': ['sha256:existing_fingerprint'],
        };
        final certificatePinning = CertificatePinning(
          pinnedCertificates: pins,
          logger: mockLogger,
        );

        // act
        certificatePinning.addPin('api.example.com', 'sha256:new_fingerprint');

        // assert
        verify(mockLogger.d('Added certificate pin for api.example.com: sha256:new_fingerprint'));
      });
    });

    group('removeHostPins', () {
      test('should remove all pins for a host', () {
        // arrange
        final pins = <String, List<String>>{
          'api.example.com': ['sha256:test_fingerprint'],
          'auth.example.com': ['sha256:another_fingerprint'],
        };
        final certificatePinning = CertificatePinning(
          pinnedCertificates: pins,
          logger: mockLogger,
        );

        // act
        certificatePinning.removeHostPins('api.example.com');

        // assert
        verify(mockLogger.d('Removed all certificate pins for api.example.com'));
      });
    });

    group('static configuration methods', () {
      test('getProductionPins should return production configuration', () {
        // act
        final pins = CertificatePinning.getProductionPins();

        // assert
        expect(pins, isNotNull);
        expect(pins, isA<Map<String, List<String>>>());
        expect(pins.containsKey('api.yourdomain.com'), true);
        expect(pins.containsKey('auth.yourdomain.com'), true);
      });

      test('getStagingPins should return staging configuration', () {
        // act
        final pins = CertificatePinning.getStagingPins();

        // assert
        expect(pins, isNotNull);
        expect(pins, isA<Map<String, List<String>>>());
        expect(pins.containsKey('staging-api.yourdomain.com'), true);
      });

      test('getDevelopmentPins should return development configuration', () {
        // act
        final pins = CertificatePinning.getDevelopmentPins();

        // assert
        expect(pins, isNotNull);
        expect(pins, isA<Map<String, List<String>>>());
        expect(pins.containsKey('dev-api.yourdomain.com'), true);
      });
    });
  });

  group('CertificatePinningService', () {
    setUp(() {
      // Reset the service state before each test
      CertificatePinningService.resetInstance();
    });

    group('initialize', () {
      test('should initialize service with production environment', () {
        // act
        final service = CertificatePinningService.initialize(
          environment: 'production',
          enablePinning: true,
        );

        // assert
        expect(service, isNotNull);
        expect(CertificatePinningService.isInitialized, true);
        expect(CertificatePinningService.instance, isNotNull);
      });

      test('should initialize service with staging environment', () {
        // act
        final service = CertificatePinningService.initialize(
          environment: 'staging',
          enablePinning: true,
        );

        // assert
        expect(service, isNotNull);
        expect(CertificatePinningService.isInitialized, true);
      });

      test('should initialize service with development environment', () {
        // act
        final service = CertificatePinningService.initialize(
          environment: 'development',
          enablePinning: false,
        );

        // assert
        expect(service, isNotNull);
        expect(CertificatePinningService.isInitialized, true);
      });

      test('should initialize service with custom pins', () {
        // arrange
        final customPins = <String, List<String>>{
          'custom.example.com': ['sha256:custom_fingerprint'],
        };

        // act
        final service = CertificatePinningService.initialize(
          environment: 'custom',
          customPins: customPins,
          enablePinning: true,
        );

        // assert
        expect(service, isNotNull);
        expect(CertificatePinningService.isInitialized, true);
      });
    });

    test('should return null when not initialized', () {
      // assert
      expect(CertificatePinningService.instance, null);
      expect(CertificatePinningService.isInitialized, false);
    });
  });

  group('CertPinConfig', () {
    test('should create config with required parameters', () {
      // arrange
      const host = 'api.example.com';
      const pins = ['sha256:test_fingerprint'];

      // act
      const config = CertPinConfig(host: host, pins: pins);

      // assert
      expect(config.host, host);
      expect(config.pins, pins);
      expect(config.enabled, true); // default value
    });

    test('should create config with enabled parameter', () {
      // arrange
      const host = 'api.example.com';
      const pins = ['sha256:test_fingerprint'];
      const enabled = false;

      // act
      const config = CertPinConfig(host: host, pins: pins, enabled: enabled);

      // assert
      expect(config.host, host);
      expect(config.pins, pins);
      expect(config.enabled, enabled);
    });

    test('should serialize to JSON correctly', () {
      // arrange
      const config = CertPinConfig(
        host: 'api.example.com',
        pins: ['sha256:test_fingerprint'],
        enabled: false,
      );

      // act
      final json = config.toJson();

      // assert
      expect(json['host'], 'api.example.com');
      expect(json['pins'], ['sha256:test_fingerprint']);
      expect(json['enabled'], false);
    });

    test('should deserialize from JSON correctly', () {
      // arrange
      final json = {
        'host': 'api.example.com',
        'pins': ['sha256:test_fingerprint'],
        'enabled': false,
      };

      // act
      final config = CertPinConfig.fromJson(json);

      // assert
      expect(config.host, 'api.example.com');
      expect(config.pins, ['sha256:test_fingerprint']);
      expect(config.enabled, false);
    });

    test('should use default enabled value when not provided in JSON', () {
      // arrange
      final json = {
        'host': 'api.example.com',
        'pins': ['sha256:test_fingerprint'],
      };

      // act
      final config = CertPinConfig.fromJson(json);

      // assert
      expect(config.enabled, true);
    });
  });

  group('CertificateUtils', () {
    group('formatFingerprint', () {
      test('should format 64-character fingerprint correctly', () {
        // arrange
        const fingerprint = '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';

        // act
        final formatted = CertificateUtils.formatFingerprint(fingerprint);

        // assert
        expect(formatted, '12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF:12:34:56:78:90:AB:CD:EF');
      });

      test('should return original fingerprint if not 64 characters', () {
        // arrange
        const fingerprint = 'short';

        // act
        final formatted = CertificateUtils.formatFingerprint(fingerprint);

        // assert
        expect(formatted, 'short');
      });
    });

    group('isValidFingerprint', () {
      test('should return true for valid SHA-256 fingerprint', () {
        // arrange
        const fingerprint = '1234567890abcdef1234567890abcdef1234567890abcdef1234567890abcdef';

        // act
        final isValid = CertificateUtils.isValidFingerprint(fingerprint);

        // assert
        expect(isValid, true);
      });

      test('should return true for valid uppercase fingerprint', () {
        // arrange
        const fingerprint = '1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF1234567890ABCDEF';

        // act
        final isValid = CertificateUtils.isValidFingerprint(fingerprint);

        // assert
        expect(isValid, true);
      });

      test('should return false for fingerprint with invalid characters', () {
        // arrange
        const fingerprint = '1234567890ghijkl1234567890abcdef1234567890abcdef1234567890abcdef';

        // act
        final isValid = CertificateUtils.isValidFingerprint(fingerprint);

        // assert
        expect(isValid, false);
      });

      test('should return false for fingerprint with wrong length', () {
        // arrange
        const fingerprint = '1234567890abcdef';

        // act
        final isValid = CertificateUtils.isValidFingerprint(fingerprint);

        // assert
        expect(isValid, false);
      });

      test('should return false for empty fingerprint', () {
        // arrange
        const fingerprint = '';

        // act
        final isValid = CertificateUtils.isValidFingerprint(fingerprint);

        // assert
        expect(isValid, false);
      });
    });
  });
}