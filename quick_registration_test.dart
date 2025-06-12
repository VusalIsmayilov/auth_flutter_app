#!/usr/bin/env dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

void main() async {
  print('🚀 Quick Registration Test for Email Verification');
  print('=' * 60);
  
  // Generate unique test user
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final testEmail = 'quick_test_$timestamp@example.com';
  
  print('📧 Test Email: $testEmail');
  print('🔑 Test Password: QuickTest123!');
  print('');
  
  try {
    // Test registration
    print('📝 Registering new test user...');
    final registrationResult = await registerUser(testEmail);
    
    if (registrationResult['success']) {
      print('✅ Registration successful!');
      print('   User ID: ${registrationResult['userId']}');
      print('   Email Verified: ${registrationResult['emailVerified']}');
      print('');
      
      print('📱 Next Steps:');
      print('1. Use the Flutter app in Chrome');
      print('2. Navigate to: /email-verification?email=$testEmail');
      print('3. Check your email for verification token');
      print('4. Test the verification flow');
      print('');
      
      print('🔗 Or test verification API directly:');
      print('   dart run quick_registration_test.dart verify <token>');
    }
    
  } catch (e) {
    print('❌ Test failed: $e');
  }
}

Future<Map<String, dynamic>> registerUser(String email) async {
  const baseUrl = 'http://localhost:80/api';
  
  final registrationData = {
    'email': email,
    'password': 'QuickTest123!',
    'firstName': 'Quick',
    'lastName': 'Test',
  };
  
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/email'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(registrationData),
    ).timeout(const Duration(seconds: 30));
    
    print('   📊 Status: ${response.statusCode}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final responseData = json.decode(response.body);
      
      if (responseData['success'] == true) {
        final user = responseData['user'];
        return {
          'success': true,
          'userId': user['id']?.toString(),
          'email': user['email'],
          'emailVerified': user['isEmailVerified'],
        };
      } else {
        throw 'Registration failed: ${responseData['message']}';
      }
    } else {
      final errorData = json.decode(response.body);
      throw 'HTTP ${response.statusCode}: ${errorData['message']}';
    }
  } catch (e) {
    return {
      'success': false,
      'error': e.toString(),
    };
  }
}

Future<void> testVerification(String token) async {
  const baseUrl = 'http://localhost:80/api';
  
  print('🎫 Testing email verification with token...');
  print('   Token: ${token.substring(0, 20)}...');
  
  final verificationData = {
    'token': token,
  };
  
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-email'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(verificationData),
    ).timeout(const Duration(seconds: 30));
    
    print('   📊 Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      
      if (responseData['success'] == true) {
        print('✅ Email verification successful!');
        print('   Message: ${responseData['message']}');
      } else {
        print('❌ Verification failed: ${responseData['message']}');
      }
    } else {
      final errorData = json.decode(response.body);
      print('❌ HTTP ${response.statusCode}: ${errorData['message']}');
    }
  } catch (e) {
    print('❌ Verification test failed: $e');
  }
}