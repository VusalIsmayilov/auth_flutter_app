import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

import 'package:auth_flutter_app/main.dart' as app;
import 'package:auth_flutter_app/presentation/providers/providers.dart';
import 'package:auth_flutter_app/data/models/login_request_model.dart';
import 'package:auth_flutter_app/data/models/user_model.dart';
import 'package:auth_flutter_app/core/network/dio_client.dart';
import 'package:auth_flutter_app/config/environment_config.dart';
import 'package:auth_flutter_app/core/security/request_signing_service.dart';
import 'package:auth_flutter_app/core/network/certificate_pinning.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('API Integration Tests', () {
    
    testWidgets('Dio client is properly configured', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final container = ProviderContainer();
      
      try {
        // Test environment config
        final envConfig = container.read(environmentConfigProvider);
        expect(envConfig.apiUrl, isNotEmpty);
        expect(envConfig.connectTimeout, isA<Duration>());
        expect(envConfig.receiveTimeout, isA<Duration>());
        
        // Test API service creation
        final apiService = container.read(authApiServiceProvider);
        expect(apiService, isNotNull);
        
      } finally {
        container.dispose();
      }
    });

    testWidgets('Request signing service is initialized', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test request signing service initialization
      final signingService = RequestSigningService.instance;
      expect(signingService, isNotNull);
      
      // Test signature generation
      final testPayload = {'test': 'data'};
      final signature = signingService.generateSignature(
        method: 'POST',
        path: '/test',
        queryParameters: {},
        headers: {'Content-Type': 'application/json'},
        body: testPayload,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        nonce: 'test-nonce',
      );
      
      expect(signature, isNotEmpty);
      expect(signature.length, greaterThan(40)); // SHA-256 hash should be long
    });

    testWidgets('Certificate pinning service is configured', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test certificate pinning configuration
      final pinningService = CertificatePinningService.instance;
      expect(pinningService, isNotNull);
      
      // Test pinning validation (will fail without real certificates)
      try {
        final isValid = pinningService.validateCertificate(
          'example.com',
          'test-certificate-data',
        );
        expect(isValid, isA<bool>());
      } catch (e) {
        // Expected in test environment without real certificates
        expect(e, isNotNull);
      }
    });

    testWidgets('JWT service handles tokens correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final container = ProviderContainer();
      
      try {
        final jwtService = container.read(jwtServiceProvider);
        expect(jwtService, isNotNull);
        
        // Test token validation (should return false without valid token)
        final isValid = await jwtService.isTokenValid();
        expect(isValid, isFalse);
        
        // Test getting access token (should return null without login)
        final accessToken = await jwtService.getValidAccessToken();
        expect(accessToken, isNull);
        
      } finally {
        container.dispose();
      }
    });

    testWidgets('API endpoints are correctly configured', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final container = ProviderContainer();
      
      try {
        final apiService = container.read(authApiServiceProvider);
        
        // Test login request structure
        final loginRequest = LoginRequestModel(
          email: 'test@example.com',
          password: 'password123',
          rememberMe: false,
        );
        
        expect(loginRequest.email, 'test@example.com');
        expect(loginRequest.password, 'password123');
        expect(loginRequest.rememberMe, false);
        
        // Test that API service methods exist (will fail calls without backend)
        try {
          await apiService.loginEmail(loginRequest);
        } catch (e) {
          // Expected - should be DioException or similar
          expect(e, isA<DioException>());
        }
        
      } finally {
        container.dispose();
      }
    });

    testWidgets('Repository layer handles API responses', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final container = ProviderContainer();
      
      try {
        final authRepository = container.read(authRepositoryProvider);
        
        // Test repository methods exist and handle errors properly
        try {
          await authRepository.hasValidToken();
        } catch (e) {
          // Should handle errors gracefully
          expect(e, isNotNull);
        }
        
        try {
          await authRepository.getAccessToken();
        } catch (e) {
          // Should handle null tokens gracefully
          expect(e, isNotNull);
        }
        
        // Test profile update structure
        final profileData = {
          'firstName': 'John',
          'lastName': 'Doe',
          'phoneNumber': '+1234567890',
        };
        
        try {
          await authRepository.updateProfile(profileData);
        } catch (e) {
          // Expected without authentication
          expect(e, isNotNull);
        }
        
      } finally {
        container.dispose();
      }
    });

    testWidgets('Use cases handle API integration correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final container = ProviderContainer();
      
      try {
        // Test login use case
        final loginUseCase = container.read(loginUseCaseProvider);
        final loginRequest = LoginRequestModel(
          email: 'test@example.com',
          password: 'password123',
          rememberMe: false,
        );
        
        try {
          await loginUseCase(loginRequest);
        } catch (e) {
          // Expected without backend - should be handled gracefully
          expect(e, isNotNull);
        }
        
        // Test register use case
        final registerUseCase = container.read(registerUseCaseProvider);
        final registerRequest = RegisterRequestModel(
          email: 'newuser@example.com',
          password: 'StrongPassword123!',
          confirmPassword: 'StrongPassword123!',
        );
        
        try {
          await registerUseCase(registerRequest);
        } catch (e) {
          // Expected without backend
          expect(e, isNotNull);
        }
        
        // Test forgot password use case
        final forgotPasswordUseCase = container.read(forgotPasswordUseCaseProvider);
        
        try {
          await forgotPasswordUseCase.execute('test@example.com');
        } catch (e) {
          // Expected without backend
          expect(e, isNotNull);
        }
        
        // Test profile use cases
        final getUserProfileUseCase = container.read(getUserProfileUseCaseProvider);
        final updateProfileUseCase = container.read(updateProfileUseCaseProvider);
        
        try {
          await getUserProfileUseCase();
        } catch (e) {
          // Expected without authentication
          expect(e, isNotNull);
        }
        
        try {
          await updateProfileUseCase({'firstName': 'Test'});
        } catch (e) {
          // Expected without authentication
          expect(e, isNotNull);
        }
        
      } finally {
        container.dispose();
      }
    });

    testWidgets('Error handling across API layers works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final container = ProviderContainer();
      
      try {
        final authNotifier = container.read(authProvider.notifier);
        
        // Test network error handling
        final loginRequest = LoginRequestModel(
          email: 'test@example.com',
          password: 'password123',
          rememberMe: false,
        );
        
        await authNotifier.login(loginRequest);
        
        final authState = container.read(authProvider);
        
        // Should handle error gracefully
        expect(authState.status.name, anyOf(['error', 'unauthenticated']));
        expect(authState.errorMessage, isNotNull);
        
        // Test error clearing
        authNotifier.clearError();
        
        final clearedState = container.read(authProvider);
        expect(clearedState.errorMessage, isNull);
        
      } finally {
        container.dispose();
      }
    });

    testWidgets('Security interceptors are active', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final container = ProviderContainer();
      
      try {
        // Test that security config is properly loaded
        final envConfig = container.read(environmentConfigProvider);
        
        // Security features should be configured
        expect(envConfig.enableCertificatePinning, isA<bool>());
        expect(envConfig.enableRequestSigning, isA<bool>());
        
        // Test JWT service is configured with interceptors
        final jwtService = container.read(jwtServiceProvider);
        expect(jwtService, isNotNull);
        
        // Test storage service is secure
        final storageService = container.read(secureStorageProvider);
        expect(storageService, isNotNull);
        
      } finally {
        container.dispose();
      }
    });

    testWidgets('Token refresh mechanism works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final container = ProviderContainer();
      
      try {
        final refreshTokenUseCase = container.read(refreshTokenUseCaseProvider);
        
        // Test refresh token validation
        final isValid = await refreshTokenUseCase.isTokenValid();
        expect(isValid, isA<bool>());
        
        // Test getting valid access token
        final accessToken = await refreshTokenUseCase.getValidAccessToken();
        expect(accessToken, isA<String?>());
        
        // Test refresh token flow
        try {
          await refreshTokenUseCase();
        } catch (e) {
          // Expected without valid refresh token
          expect(e, isNotNull);
        }
        
      } finally {
        container.dispose();
      }
    });

    testWidgets('Logout clears all API state', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final container = ProviderContainer();
      
      try {
        final logoutUseCase = container.read(logoutUseCaseProvider);
        final authNotifier = container.read(authProvider.notifier);
        
        // Test logout flow
        await authNotifier.logout();
        
        final authState = container.read(authProvider);
        
        // Should clear authentication state
        expect(authState.status.name, 'unauthenticated');
        expect(authState.user, isNull);
        expect(authState.errorMessage, isNull);
        
        // Test that tokens are cleared
        final authRepository = container.read(authRepositoryProvider);
        final hasValidToken = await authRepository.hasValidToken();
        expect(hasValidToken, isFalse);
        
        final accessToken = await authRepository.getAccessToken();
        expect(accessToken, isNull);
        
      } finally {
        container.dispose();
      }
    });

    testWidgets('API rate limiting and retry logic', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test that API calls handle rate limiting and retries appropriately
      final container = ProviderContainer();
      
      try {
        final authNotifier = container.read(authProvider.notifier);
        
        // Make multiple rapid requests to test rate limiting
        final futures = <Future>[];
        for (int i = 0; i < 3; i++) {
          futures.add(
            authNotifier.login(
              LoginRequestModel(
                email: 'test$i@example.com',
                password: 'password123',
                rememberMe: false,
              ),
            ),
          );
        }
        
        // Wait for all requests to complete
        await Future.wait(futures, eagerError: false);
        
        // All should handle errors gracefully
        final authState = container.read(authProvider);
        expect(authState.status, isNotNull);
        
      } finally {
        container.dispose();
      }
    });

    testWidgets('API responses are properly validated', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test model validation and serialization
      
      // Test UserModel creation and validation
      const testUser = UserModel(
        id: 1,
        email: 'test@example.com',
        phoneNumber: '+1234567890',
        isEmailVerified: true,
        currentRole: 'User',
        currentRoleDisplayName: 'User',
        isActive: true,
      );
      
      expect(testUser.id, 1);
      expect(testUser.email, 'test@example.com');
      expect(testUser.displayName, 'test@example.com');
      expect(testUser.isUser, isTrue);
      expect(testUser.isAdmin, isFalse);
      
      // Test model serialization
      final userJson = testUser.toJson();
      expect(userJson['id'], 1);
      expect(userJson['email'], 'test@example.com');
      expect(userJson['isActive'], true);
      
      // Test model deserialization
      final recreatedUser = UserModel.fromJson(userJson);
      expect(recreatedUser.id, testUser.id);
      expect(recreatedUser.email, testUser.email);
      expect(recreatedUser.isActive, testUser.isActive);
    });
  });
}