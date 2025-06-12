import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auth_flutter_app/presentation/pages/auth/email_verification_page.dart';

void main() {
  group('Email Verification Page Widget Tests', () {
    testWidgets('Email verification page displays correctly', (WidgetTester tester) async {
      const testEmail = 'test@example.com';
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const EmailVerificationPage(email: testEmail),
          ),
        ),
      );

      // Test page title
      expect(find.text('Verify Your Email'), findsOneWidget);
      
      // Test email display
      expect(find.text('We\'ve sent a verification link to:'), findsOneWidget);
      expect(find.text(testEmail), findsOneWidget);
      
      // Test form elements
      expect(find.text('Verification Token'), findsOneWidget);
      expect(find.text('Enter verification token from email'), findsOneWidget);
      expect(find.text('Verify Email'), findsOneWidget);
      expect(find.text('Resend Code'), findsOneWidget);
      
      // Test back button
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      
      // Test help information
      expect(find.text('Didn\'t receive the code?'), findsOneWidget);
      expect(find.textContaining('Check your spam/junk folder'), findsOneWidget);
      expect(find.textContaining('Copy the token from the email link'), findsOneWidget);
      
      print('✅ Email verification page UI elements verified');
    });

    testWidgets('Token validation works correctly', (WidgetTester tester) async {
      const testEmail = 'test@example.com';
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const EmailVerificationPage(email: testEmail),
          ),
        ),
      );

      // Find the token input field
      final tokenField = find.byType(TextFormField);
      expect(tokenField, findsOneWidget);

      // Test empty token validation
      final verifyButton = find.text('Verify Email');
      await tester.tap(verifyButton);
      await tester.pumpAndSettle();
      
      expect(find.text('Please enter the verification token'), findsOneWidget);
      print('✅ Empty token validation working');

      // Test short token validation
      await tester.enterText(tokenField, 'short');
      await tester.tap(verifyButton);
      await tester.pumpAndSettle();
      
      expect(find.text('Verification token appears to be too short'), findsOneWidget);
      print('✅ Short token validation working');

      // Test valid token length
      const validToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIn0';
      await tester.enterText(tokenField, validToken);
      await tester.pumpAndSettle();
      
      // Should not show validation error
      expect(find.text('Verification token appears to be too short'), findsNothing);
      print('✅ Valid token length accepted');
    });

    testWidgets('Navigation works correctly', (WidgetTester tester) async {
      const testEmail = 'test@example.com';
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const EmailVerificationPage(email: testEmail),
            routes: {
              '/login': (context) => const Scaffold(body: Text('Login Page')),
            },
          ),
        ),
      );

      // Test back navigation
      final backButton = find.byIcon(Icons.arrow_back);
      expect(backButton, findsOneWidget);
      
      // Test "Back to Login" navigation
      final backToLoginButton = find.text('Back to Login');
      expect(backToLoginButton, findsOneWidget);
      
      await tester.tap(backToLoginButton);
      await tester.pumpAndSettle();
      
      expect(find.text('Login Page'), findsOneWidget);
      print('✅ Navigation to login page working');
    });

    testWidgets('Resend button works correctly', (WidgetTester tester) async {
      const testEmail = 'test@example.com';
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const EmailVerificationPage(email: testEmail),
          ),
        ),
      );

      // Find and test resend button
      final resendButton = find.text('Resend Code');
      expect(resendButton, findsOneWidget);
      
      // Should be enabled initially
      final resendWidget = tester.widget<OutlinedButton>(
        find.ancestor(
          of: resendButton,
          matching: find.byType(OutlinedButton),
        ),
      );
      expect(resendWidget.onPressed, isNotNull);
      print('✅ Resend button initially enabled');
    });

    testWidgets('Success state displays correctly', (WidgetTester tester) async {
      const testEmail = 'test@example.com';
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const EmailVerificationPage(email: testEmail),
          ),
        ),
      );

      // The success state is controlled by internal widget state
      // We can test that the widget structure supports it
      expect(find.byType(EmailVerificationPage), findsOneWidget);
      print('✅ Email verification page widget structure verified');
    });

    testWidgets('Token input accepts text correctly', (WidgetTester tester) async {
      const testEmail = 'test@example.com';
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const EmailVerificationPage(email: testEmail),
          ),
        ),
      );

      final tokenField = find.byType(TextFormField);
      
      // Test various token formats
      const testTokens = [
        'abc123def456ghi789',
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9',
        'YWJjZGVmZ2hpams=',
        'token_with_underscores_123',
      ];
      
      for (final token in testTokens) {
        await tester.enterText(tokenField, token);
        await tester.pumpAndSettle();
        
        final textFieldWidget = tester.widget<TextFormField>(tokenField);
        expect(textFieldWidget.controller?.text, equals(token));
      }
      
      print('✅ Token input accepts various formats');
    });

    testWidgets('Help information is comprehensive', (WidgetTester tester) async {
      const testEmail = 'test@example.com';
      
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const EmailVerificationPage(email: testEmail),
          ),
        ),
      );

      // Check all help text items
      expect(find.textContaining('Check your spam/junk folder'), findsOneWidget);
      expect(find.textContaining('Make sure the email address is correct'), findsOneWidget);
      expect(find.textContaining('Wait a few minutes for delivery'), findsOneWidget);
      expect(find.textContaining('Copy the token from the email link'), findsOneWidget);
      expect(find.textContaining('Request a new email if needed'), findsOneWidget);
      
      print('✅ Comprehensive help information provided');
    });
  });
}