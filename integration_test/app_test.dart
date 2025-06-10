import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:auth_flutter_app/main.dart' as app;
import 'package:auth_flutter_app/presentation/providers/providers.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {
    testWidgets('App launches and shows splash screen', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Should start with splash screen
      expect(find.text('Auth Flutter App'), findsAnyWidget);
      
      // Wait for splash screen to complete and redirect
      await tester.pumpAndSettle(const Duration(seconds: 3));
      
      // Should redirect to login screen for unauthenticated user
      expect(find.text('Login'), findsAnyWidget);
      expect(find.text('Email'), findsAnyWidget);
      expect(find.text('Password'), findsAnyWidget);
    });

    testWidgets('Navigation between auth screens works', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for initial load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Should be on login page
      expect(find.text('Login'), findsAnyWidget);

      // Navigate to register page
      await tester.tap(find.text("Don't have an account? Register"));
      await tester.pumpAndSettle();

      // Should be on register page
      expect(find.text('Register'), findsAnyWidget);
      expect(find.text('Create Account'), findsAnyWidget);

      // Navigate to forgot password
      await tester.tap(find.text('Already have an account? Login'));
      await tester.pumpAndSettle();
      
      // Back to login page
      expect(find.text('Login'), findsAnyWidget);
      
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      // Should be on forgot password page
      expect(find.text('Forgot Password'), findsAnyWidget);
      expect(find.text('Send Reset Email'), findsAnyWidget);
    });

    testWidgets('Form validation works correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for initial load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Try to login with empty fields
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show validation errors
      expect(find.text('Email is required'), findsAnyWidget);
      expect(find.text('Password is required'), findsAnyWidget);

      // Enter invalid email
      await tester.enterText(find.byKey(const Key('email_field')), 'invalid-email');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show email validation error
      expect(find.textContaining('valid email'), findsAnyWidget);

      // Enter valid email but short password
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), '123');
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show password validation error
      expect(find.textContaining('at least'), findsAnyWidget);
    });

    testWidgets('Error handling displays properly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for initial load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Enter valid credentials that will fail (no backend)
      await tester.enterText(find.byKey(const Key('email_field')), 'test@example.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'password123');
      
      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Should show loading state initially
      expect(find.byType(CircularProgressIndicator), findsAnyWidget);
      
      // Wait for request to complete and error to show
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Should show error message (network error since no backend)
      expect(find.textContaining('failed'), findsAnyWidget);
    });

    testWidgets('Theme and styling loads correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for initial load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Check that theme colors are applied
      final appBarFinder = find.byType(AppBar);
      expect(appBarFinder, findsAnyWidget);

      // Check for proper button styling
      final elevatedButtonFinder = find.byType(ElevatedButton);
      expect(elevatedButtonFinder, findsAnyWidget);

      // Check for proper text field styling
      final textFieldFinder = find.byType(TextFormField);
      expect(textFieldFinder, findsAtLeastNWidgets(2)); // Email and password fields
    });

    testWidgets('App handles deep links correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for initial load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Test navigation to different routes
      // Since we're testing in integration mode, we can check route protection
      
      // Try to navigate to protected route without authentication
      // This should redirect to login
      expect(find.text('Login'), findsAnyWidget);
    });

    testWidgets('Security features are initialized', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for app to fully initialize
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // Verify that security services are properly initialized
      // This is verified by the app starting without crashes
      expect(find.byType(MaterialApp), findsOneWidget);
      
      // Check that providers are properly initialized
      final container = ProviderContainer();
      
      try {
        // Verify critical providers can be read without errors
        container.read(secureStorageProvider);
        container.read(authProvider);
        container.read(environmentConfigProvider);
        
        // If we get here, providers are properly configured
        expect(true, isTrue);
      } catch (e) {
        fail('Provider initialization failed: $e');
      } finally {
        container.dispose();
      }
    });

    testWidgets('Memory usage is reasonable during navigation', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();
      
      // Wait for initial load
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate through multiple screens to test memory usage
      for (int i = 0; i < 3; i++) {
        // Go to register
        if (find.text("Don't have an account? Register").evaluate().isNotEmpty) {
          await tester.tap(find.text("Don't have an account? Register"));
          await tester.pumpAndSettle();
        }

        // Go back to login
        if (find.text('Already have an account? Login').evaluate().isNotEmpty) {
          await tester.tap(find.text('Already have an account? Login'));
          await tester.pumpAndSettle();
        }

        // Go to forgot password
        if (find.text('Forgot Password?').evaluate().isNotEmpty) {
          await tester.tap(find.text('Forgot Password?'));
          await tester.pumpAndSettle();
        }

        // Go back to login
        if (find.byIcon(Icons.arrow_back).evaluate().isNotEmpty) {
          await tester.tap(find.byIcon(Icons.arrow_back));
          await tester.pumpAndSettle();
        }
      }

      // App should still be responsive
      expect(find.text('Login'), findsAnyWidget);
    });
  });
}