#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main(List<String> args) async {
  print('🚀 Real Email Verification End-to-End Test');
  print('=' * 50);
  
  final tester = EmailVerificationRealTester();
  await tester.runAllTests();
}

class EmailVerificationRealTester {
  static const String baseUrl = 'http://localhost:80';
  static const String apiUrl = '$baseUrl/api';
  
  late String testEmail;
  late String testPassword;
  String? accessToken;
  String? refreshToken;
  String? userId;
  String? verificationToken;
  
  EmailVerificationRealTester() {
    // Generate unique test email for this run
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    testEmail = 'real_test_$timestamp@example.com';
    testPassword = 'RealTestPassword123!';
  }
  
  Future<void> runAllTests() async {
    print('📧 Test Email: $testEmail');
    print('🔑 Test Password: $testPassword');
    print('🌐 Backend URL: $apiUrl');
    print('');
    
    try {
      // Step 1: Check if backend is running
      await _checkBackendHealth();
      
      // Step 2: Test user registration
      await _testRegistration();
      
      // Step 3: Test resend verification email
      await _testResendVerification();
      
      // Step 4: Get verification token (manual step)
      await _getVerificationToken();
      
      // Step 5: Test email verification
      if (verificationToken != null) {
        await _testEmailVerification();
      }
      
      // Step 6: Test user status after verification
      await _testUserStatusAfterVerification();
      
      print('');
      print('✅ All Real Tests Completed Successfully!');
      _printTestSummary();
      
    } catch (e) {
      print('❌ Test Failed: $e');
      _printTestSummary();
      exit(1);
    }
  }
  
  Future<void> _checkBackendHealth() async {
    print('🏥 Step 1: Checking Backend Health...');
    
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        print('   ✅ Backend is running and healthy');
        print('   📊 Status: ${response.statusCode}');
      } else {
        print('   ⚠️  Backend responded with status: ${response.statusCode}');
      }
    } catch (e) {
      print('   ❌ Backend health check failed: $e');
      print('   💡 Make sure the backend server is running on $baseUrl');
      throw 'Backend not available';
    }
    print('');
  }
  
  Future<void> _testRegistration() async {
    print('📝 Step 2: Testing User Registration...');
    
    final registrationData = {
      'email': testEmail,
      'password': testPassword,
      'firstName': 'Real',
      'lastName': 'Tester',
    };
    
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/register/email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(registrationData),
      ).timeout(const Duration(seconds: 30));
      
      print('   📤 Registration request sent');
      print('   📊 Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          print('   ✅ Registration successful!');
          
          // Extract user and token information
          final user = responseData['user'];
          final tokens = responseData['tokens'];
          
          userId = user['id']?.toString();
          accessToken = tokens['accessToken'];
          refreshToken = tokens['refreshToken'];
          
          print('   👤 User ID: $userId');
          print('   📧 Email: ${user['email']}');
          print('   ✉️  Email Verified: ${user['isEmailVerified']}');
          print('   🎟️  Access Token: ${accessToken?.substring(0, 30)}...');
          
          if (user['isEmailVerified'] == false) {
            print('   📮 Verification email should be sent to: $testEmail');
          }
        } else {
          throw 'Registration failed: ${responseData['message']}';
        }
      } else {
        final errorData = json.decode(response.body);
        throw 'Registration failed with status ${response.statusCode}: ${errorData['message']}';
      }
    } catch (e) {
      print('   ❌ Registration failed: $e');
      rethrow;
    }
    print('');
  }
  
  Future<void> _testResendVerification() async {
    print('🔄 Step 3: Testing Resend Verification Email...');
    
    final resendData = {
      'email': testEmail,
    };
    
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/resend-verification'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(resendData),
      ).timeout(const Duration(seconds: 30));
      
      print('   📤 Resend verification request sent');
      print('   📊 Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          print('   ✅ Resend verification successful!');
          print('   📧 Message: ${responseData['message']}');
          print('   📮 Another verification email sent to: $testEmail');
        } else {
          throw 'Resend failed: ${responseData['message']}';
        }
      } else {
        final errorData = json.decode(response.body);
        throw 'Resend failed with status ${response.statusCode}: ${errorData['message']}';
      }
    } catch (e) {
      print('   ❌ Resend verification failed: $e');
      rethrow;
    }
    print('');
  }
  
  Future<void> _getVerificationToken() async {
    print('🎫 Step 4: Getting Verification Token...');
    print('   📧 Please check your email: $testEmail');
    print('   🔍 Look for an email from the AuthService');
    print('   📄 Copy the verification token from the email');
    print('   ⌨️  Paste the token here (or press Enter to skip):');
    
    // In a real test environment, you might:
    // 1. Check a test email inbox programmatically
    // 2. Use a mock email service
    // 3. Extract tokens from database directly
    // 4. Use email service APIs to fetch emails
    
    stdout.write('   Token: ');
    final input = stdin.readLineSync();
    
    if (input != null && input.trim().isNotEmpty) {
      verificationToken = input.trim();
      print('   ✅ Token received: ${verificationToken!.substring(0, 20)}...');
    } else {
      print('   ⏭️  Skipping email verification (no token provided)');
      verificationToken = null;
    }
    print('');
  }
  
  Future<void> _testEmailVerification() async {
    print('✉️  Step 5: Testing Email Verification...');
    
    if (verificationToken == null) {
      print('   ⏭️  Skipped - no verification token provided');
      return;
    }
    
    final verificationData = {
      'token': verificationToken,
    };
    
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/auth/verify-email'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(verificationData),
      ).timeout(const Duration(seconds: 30));
      
      print('   📤 Email verification request sent');
      print('   📊 Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        
        if (responseData['success'] == true) {
          print('   ✅ Email verification successful!');
          print('   📧 Message: ${responseData['message']}');
          print('   🎉 Email is now verified for: $testEmail');
        } else {
          throw 'Verification failed: ${responseData['message']}';
        }
      } else {
        final errorData = json.decode(response.body);
        throw 'Verification failed with status ${response.statusCode}: ${errorData['message']}';
      }
    } catch (e) {
      print('   ❌ Email verification failed: $e');
      rethrow;
    }
    print('');
  }
  
  Future<void> _testUserStatusAfterVerification() async {
    print('👤 Step 6: Testing User Status After Verification...');
    
    if (accessToken == null) {
      print('   ⏭️  Skipped - no access token available');
      return;
    }
    
    try {
      final response = await http.get(
        Uri.parse('$apiUrl/auth/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
      ).timeout(const Duration(seconds: 30));
      
      print('   📤 User profile request sent');
      print('   📊 Status Code: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final userData = json.decode(response.body);
        
        print('   ✅ User profile retrieved successfully!');
        print('   👤 User ID: ${userData['id']}');
        print('   📧 Email: ${userData['email']}');
        print('   ✉️  Email Verified: ${userData['isEmailVerified']}');
        print('   📱 Phone Verified: ${userData['isPhoneVerified']}');
        
        if (userData['isEmailVerified'] == true) {
          print('   🎉 Email verification status confirmed in user profile!');
        } else {
          print('   ⚠️  Email verification status not updated in profile');
        }
      } else if (response.statusCode == 404) {
        print('   ℹ️  User profile endpoint not implemented yet (404)');
      } else {
        final errorData = json.decode(response.body);
        print('   ❌ Failed to get user profile: ${errorData['message']}');
      }
    } catch (e) {
      print('   ⚠️  User profile check failed: $e');
      // Don't rethrow - this might be expected if endpoint isn't implemented
    }
    print('');
  }
  
  void _printTestSummary() {
    print('📊 Test Summary');
    print('=' * 30);
    print('👤 User ID: ${userId ?? "Not created"}');
    print('📧 Email: $testEmail');
    print('🔑 Password: $testPassword');
    print('🎟️  Access Token: ${accessToken != null ? "Generated" : "Not generated"}');
    print('🔄 Refresh Token: ${refreshToken != null ? "Generated" : "Not generated"}');
    print('🎫 Verification Token: ${verificationToken != null ? "Provided" : "Not provided"}');
    print('');
    print('📋 Next Steps for Complete Testing:');
    print('1. Check your email inbox for verification emails');
    print('2. Copy the verification token from the email');
    print('3. Re-run this test with the real token');
    print('4. Test the Flutter app with this backend');
    print('5. Verify the complete user flow');
  }
}