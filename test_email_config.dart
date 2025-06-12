#!/usr/bin/env dart

import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🧪 Testing Email Configuration');
  print('=' * 40);
  
  // Test with a new user registration
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  final testEmail = 'email_test_$timestamp@gmail.com'; // Use a real email you can access
  
  print('📧 Test Email: $testEmail');
  print('🔑 Test Password: EmailTest123!');
  print('');
  
  try {
    print('📝 Testing user registration...');
    final result = await registerAndTestEmail(testEmail);
    
    if (result['success']) {
      print('✅ Registration successful!');
      print('📧 Email should be sent to: $testEmail');
      print('');
      print('🎯 Next Steps:');
      print('1. Check your email inbox');
      print('2. Look for email from AuthService');
      print('3. Copy the verification token');
      print('4. Test in Flutter app');
    } else {
      print('❌ Registration failed: ${result['error']}');
    }
    
  } catch (e) {
    print('❌ Test failed: $e');
    print('');
    print('🔧 Possible issues:');
    print('- Backend not running');
    print('- Email configuration not updated');
    print('- Invalid email credentials');
  }
}

Future<Map<String, dynamic>> registerAndTestEmail(String email) async {
  const baseUrl = 'http://localhost:5001/api';
  
  final registrationData = {
    'email': email,
    'password': 'EmailTest123!',
    'firstName': 'Email',
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
        return {
          'success': true,
          'userId': responseData['user']['id']?.toString(),
        };
      } else {
        return {
          'success': false,
          'error': responseData['message'],
        };
      }
    } else {
      final errorData = json.decode(response.body);
      return {
        'success': false,
        'error': 'HTTP ${response.statusCode}: ${errorData['message']}',
      };
    }
  } catch (e) {
    return {
      'success': false,
      'error': e.toString(),
    };
  }
}