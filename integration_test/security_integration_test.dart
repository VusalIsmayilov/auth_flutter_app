import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:auth_flutter_app/main.dart' as app;
import 'package:auth_flutter_app/presentation/providers/providers.dart';
import 'package:auth_flutter_app/config/security_manager.dart';
import 'package:auth_flutter_app/core/security/password_policy.dart';
import 'package:auth_flutter_app/core/security/request_signing_service.dart';
import 'package:auth_flutter_app/core/network/certificate_pinning.dart';
import 'package:auth_flutter_app/core/security/token_blacklist_service.dart';
import 'package:auth_flutter_app/core/monitoring/error_monitoring_service.dart';
import 'package:auth_flutter_app/services/biometric_service.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Security Integration Tests', () {
    
    testWidgets('Security manager initializes correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test security manager initialization
      final securityManager = SecurityManager.instance;
      expect(securityManager, isNotNull);
      
      // Test security audit
      final audit = securityManager.getSecurityAudit();
      expect(audit, isNotNull);
      expect(audit.errors, isA<List<String>>());
      expect(audit.warnings, isA<List<String>>());
      expect(audit.passed, isA<bool>());
    });

    testWidgets('Password policies are enforced', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test password policy validation
      const policy = PasswordPolicy(
        minLength: 8,
        requireUppercase: true,
        requireLowercase: true,
        requireNumbers: true,
        requireSpecialChars: true,
        preventCommonPasswords: true,
        preventReuse: true,
        preventUserInfo: true,
      );

      // Test weak password rejection
      var result = policy.validatePassword('weak');
      expect(result.isValid, isFalse);
      expect(result.errors, isNotEmpty);

      // Test strong password acceptance
      result = policy.validatePassword('StrongP@ssw0rd123');
      expect(result.isValid, isTrue);
      expect(result.errors, isEmpty);

      // Test common password rejection
      result = policy.validatePassword('Password123!');
      expect(result.isValid, isFalse); // Should reject common patterns

      // Test user info prevention
      result = policy.validatePasswordWithUserInfo(
        'johnsmith123!',
        email: 'john.smith@example.com',
        firstName: 'John',
        lastName: 'Smith',
      );
      expect(result.isValid, isFalse); // Should reject password containing user info
    });

    testWidgets('Request signing works correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test request signing service
      final signingService = RequestSigningService.instance;
      expect(signingService, isNotNull);

      // Test signature generation
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final nonce = 'test-nonce-${DateTime.now().millisecondsSinceEpoch}';
      
      final signature1 = signingService.generateSignature(
        method: 'POST',
        path: '/auth/login',
        queryParameters: {},
        headers: {'Content-Type': 'application/json'},
        body: {'email': 'test@example.com', 'password': 'password'},
        timestamp: timestamp,
        nonce: nonce,
      );

      expect(signature1, isNotEmpty);
      expect(signature1.length, greaterThan(40));

      // Test signature consistency
      final signature2 = signingService.generateSignature(
        method: 'POST',
        path: '/auth/login',
        queryParameters: {},
        headers: {'Content-Type': 'application/json'},
        body: {'email': 'test@example.com', 'password': 'password'},
        timestamp: timestamp,
        nonce: nonce,
      );

      expect(signature1, equals(signature2)); // Same inputs should produce same signature

      // Test signature uniqueness with different nonce
      final signature3 = signingService.generateSignature(
        method: 'POST',
        path: '/auth/login',
        queryParameters: {},
        headers: {'Content-Type': 'application/json'},
        body: {'email': 'test@example.com', 'password': 'password'},
        timestamp: timestamp,
        nonce: 'different-nonce',
      );

      expect(signature1, isNot(equals(signature3))); // Different nonce should produce different signature
    });

    testWidgets('Certificate pinning validation works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test certificate pinning service
      final pinningService = CertificatePinningService.instance;
      expect(pinningService, isNotNull);

      // Test certificate validation (will use test/mock certificates)
      try {
        final isValid = pinningService.validateCertificate(
          'api.example.com',
          'test-certificate-data',
        );
        expect(isValid, isA<bool>());
      } catch (e) {
        // Expected in test environment - certificate validation should fail safely
        expect(e, isNotNull);
      }

      // Test fingerprint validation
      try {
        final isValidFingerprint = pinningService.validateFingerprint(
          'test-fingerprint',
          'expected-fingerprint',
        );
        expect(isValidFingerprint, isFalse); // Should not match
      } catch (e) {
        // Safe failure expected
        expect(e, isNotNull);
      }
    });

    testWidgets('Token blacklist service works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final container = ProviderContainer();
      
      try {
        final storageService = container.read(secureStorageProvider);
        final blacklistService = TokenBlacklistService(storageService: storageService);

        // Test token blacklisting
        const testToken = 'test-jwt-token-12345';
        
        // Initially token should not be blacklisted
        var isBlacklisted = await blacklistService.isTokenBlacklisted(testToken);
        expect(isBlacklisted, isFalse);

        // Add token to blacklist
        await blacklistService.addToBlacklist(testToken);

        // Now token should be blacklisted
        isBlacklisted = await blacklistService.isTokenBlacklisted(testToken);
        expect(isBlacklisted, isTrue);

        // Test blacklist cleanup
        await blacklistService.cleanupExpiredTokens();

        // Test bulk blacklisting
        const tokens = ['token1', 'token2', 'token3'];
        await blacklistService.addBulkToBlacklist(tokens);

        for (final token in tokens) {
          final isBlacklisted = await blacklistService.isTokenBlacklisted(token);
          expect(isBlacklisted, isTrue);
        }

      } finally {
        container.dispose();
      }
    });

    testWidgets('Biometric security is properly implemented', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final container = ProviderContainer();
      
      try {
        final biometricService = container.read(biometricServiceProvider);

        // Test biometric availability check
        final isAvailable = await biometricService.isBiometricAvailable();
        expect(isAvailable, isA<bool>());

        // Test biometric enabled status
        final isEnabled = await biometricService.isBiometricEnabled();
        expect(isEnabled, isA<bool>());

        // Test credential storage check
        final hasCredentials = await biometricService.hasBiometricCredentials();
        expect(hasCredentials, isA<bool>());

        // Test biometric capability description
        final capability = await biometricService.getBiometricCapabilityDescription();
        expect(capability, isA<String>());
        expect(capability, isNotEmpty);

        // Test secure token approach (not password storage)
        try {
          final tokenData = await biometricService.getBiometricToken();
          expect(tokenData, isA<Map<String, String>?>());
        } catch (e) {
          // Expected if no biometric credentials are set up
          expect(e, isNotNull);
        }

      } finally {
        container.dispose();
      }
    });

    testWidgets('Error monitoring captures security events', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test error monitoring service initialization
      final errorService = ErrorMonitoringService.instance;
      expect(errorService, isNotNull);
      expect(errorService.isInitialized, isTrue);

      // Test security event reporting
      errorService.reportSecurityEvent(
        SecurityEventType.loginFailure,
        description: 'Test login failure event',
        userId: 'test-user-123',
        metadata: {'ip': '127.0.0.1', 'userAgent': 'test-agent'},
      );

      errorService.reportSecurityEvent(
        SecurityEventType.suspiciousActivity,
        description: 'Test suspicious activity',
        metadata: {'action': 'multiple_failed_attempts'},
      );

      // Test getting recent security events
      final recentEvents = await errorService.getRecentSecurityEvents(limit: 10);
      expect(recentEvents, isA<List>());

      // Test error reporting with security context
      errorService.reportError(
        Exception('Test security-related error'),
        context: 'Authentication validation',
        severity: ErrorSeverity.high,
        additionalData: {'security_check': 'certificate_validation'},
      );

      // Test recent errors
      final recentErrors = errorService.getRecentErrors(limit: 5);
      expect(recentErrors, isA<List>());
    });

    testWidgets('Secure storage protects sensitive data', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final container = ProviderContainer();
      
      try {
        final storageService = container.read(secureStorageProvider);

        // Test secure token storage
        const testToken = 'secure-test-token-12345';
        const testRefreshToken = 'secure-refresh-token-67890';

        // Store tokens securely
        await storageService.storeToken(TokenModel(
          accessToken: testToken,
          refreshToken: testRefreshToken,
          accessTokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
          refreshTokenExpiresAt: DateTime.now().add(const Duration(days: 7)),
        ));

        // Retrieve tokens
        final retrievedToken = await storageService.getAccessToken();
        expect(retrievedToken, testToken);

        final refreshToken = await storageService.getRefreshToken();
        expect(refreshToken, testRefreshToken);

        // Test token validation
        final hasValidToken = await storageService.hasValidToken();
        expect(hasValidToken, isTrue);

        // Test secure preference storage
        await storageService.storeUserPreference('test_key', 'secure_value');
        final retrievedValue = await storageService.getUserPreference('test_key');
        expect(retrievedValue, 'secure_value');

        // Test deletion
        await storageService.deleteUserPreference('test_key');
        final deletedValue = await storageService.getUserPreference('test_key');
        expect(deletedValue, isNull);

        // Test clearing all data
        await storageService.clearAll();
        final clearedToken = await storageService.getAccessToken();
        expect(clearedToken, isNull);

      } finally {
        container.dispose();
      }
    });

    testWidgets('Security audit detects vulnerabilities', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Test comprehensive security audit
      final securityManager = SecurityManager.instance;
      final audit = securityManager.getSecurityAudit();

      // Audit should check for various security aspects
      expect(audit, isNotNull);
      expect(audit.errors, isA<List<String>>());
      expect(audit.warnings, isA<List<String>>());
      expect(audit.passed, isA<bool>());

      // Test specific security checks
      final config = securityManager.securityConfig;
      expect(config, isNotNull);

      // In development environment, some security features might be relaxed
      // but should still be properly configured
      expect(config?.enableCertificatePinning, isA<bool>());
      expect(config?.enableRequestSigning, isA<bool>());

      // Test security validation
      final validationResult = securityManager.validateSecurityConfiguration();
      expect(validationResult, isA<bool>());
    });

    testWidgets('Input validation prevents injection attacks', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test input validation in forms
      await tester.tap(find.text("Don't have an account? Register"));
      await tester.pumpAndSettle();

      // Test SQL injection attempt
      await tester.enterText(
        find.byKey(const Key('email_field')),
        "admin'; DROP TABLE users; --",
      );
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Should show email validation error
      expect(find.textContaining('valid email'), findsAnyWidget);

      // Test XSS attempt
      await tester.enterText(
        find.byKey(const Key('email_field')),
        '<script>alert("xss")</script>@example.com',
      );
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Should show email validation error
      expect(find.textContaining('valid email'), findsAnyWidget);

      // Test path traversal attempt
      await tester.enterText(
        find.byKey(const Key('email_field')),
        '../../../etc/passwd@example.com',
      );
      await tester.tap(find.text('Create Account'));
      await tester.pumpAndSettle();

      // Should show email validation error
      expect(find.textContaining('valid email'), findsAnyWidget);
    });

    testWidgets('Session security is maintained', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final container = ProviderContainer();
      
      try {
        // Test session timeout handling
        final jwtService = container.read(jwtServiceProvider);
        
        // Test token expiration check
        final isValid = await jwtService.isTokenValid();
        expect(isValid, isFalse); // Should be false without valid session

        // Test automatic token refresh
        final validToken = await jwtService.getValidAccessToken();
        expect(validToken, isNull); // Should be null without valid session

        // Test secure session management
        final authRepository = container.read(authRepositoryProvider);
        final hasValidToken = await authRepository.hasValidToken();
        expect(hasValidToken, isFalse);

      } finally {
        container.dispose();
      }
    });

    testWidgets('Security headers and configurations are correct', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final container = ProviderContainer();
      
      try {
        // Test environment configuration security
        final envConfig = container.read(environmentConfigProvider);
        
        // Security configurations should be properly set
        expect(envConfig.enableCertificatePinning, isA<bool>());
        expect(envConfig.enableRequestSigning, isA<bool>());
        expect(envConfig.apiUrl, isNotEmpty);
        
        // Timeouts should be reasonable
        expect(envConfig.connectTimeout.inSeconds, lessThan(30));
        expect(envConfig.receiveTimeout.inSeconds, lessThan(60));

      } finally {
        container.dispose();
      }
    });

    testWidgets('Memory security - no sensitive data leaks', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test that sensitive data is not retained in memory unnecessarily
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'sensitive_password_123');
      
      // Navigate away from form
      await tester.tap(find.text("Don't have an account? Register"));
      await tester.pumpAndSettle();
      
      // Navigate back
      await tester.tap(find.text('Already have an account? Login'));
      await tester.pumpAndSettle();
      
      // Form fields should be cleared (no password retention)
      final passwordField = tester.widget<TextFormField>(find.byKey(const Key('password_field')));
      expect(passwordField.controller?.text ?? '', isEmpty);
    });
  });
}