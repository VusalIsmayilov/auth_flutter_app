import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔧 Testing Specific Issues with Phone & Email Verification');
  print('=========================================================');
  
  await testRegistrationWithExtraFields();
  await testGetUserProfile();
  await testEmailVerificationFlow();
}

Future<void> testRegistrationWithExtraFields() async {
  print('\n📍 Test 1: Registration with FirstName, LastName, PhoneNumber');
  
  try {
    final registrationData = {
      'Email': 'test_fields_${DateTime.now().millisecondsSinceEpoch}@example.com',
      'Password': 'TestPassword123!',
      'FirstName': 'Test',
      'LastName': 'User',
      'PhoneNumber': '+1234567890',
    };
    
    print('📤 Sending registration data: ${jsonEncode(registrationData)}');
    
    final response = await http.post(
      Uri.parse('http://localhost:5000/api/auth/register/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(registrationData),
    );
    
    print('📥 Registration response: ${response.statusCode}');
    print('📥 Response body: ${response.body}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      print('✅ Registration successful');
      print('📋 User data returned: ${jsonEncode(data['user'] ?? {})}');
      
      // Check if firstName/lastName are included in response
      final user = data['user'];
      if (user != null) {
        print('🔍 firstName in response: ${user['firstName'] ?? user['FirstName'] ?? 'NOT FOUND'}');
        print('🔍 lastName in response: ${user['lastName'] ?? user['LastName'] ?? 'NOT FOUND'}');
        print('🔍 phoneNumber in response: ${user['phoneNumber'] ?? user['PhoneNumber'] ?? 'NOT FOUND'}');
      }
    } else {
      print('❌ Registration failed');
    }
    
  } catch (e) {
    print('❌ Registration test error: $e');
  }
}

Future<void> testGetUserProfile() async {
  print('\n📍 Test 2: Get User Profile Endpoint');
  
  try {
    // First try to login to get a token
    final loginData = {
      'Email': 'test@example.com',
      'Password': 'TestPassword123',
    };
    
    final loginResponse = await http.post(
      Uri.parse('http://localhost:5000/api/auth/login/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loginData),
    );
    
    if (loginResponse.statusCode == 200) {
      final loginResult = jsonDecode(loginResponse.body);
      final accessToken = loginResult['tokens']?['accessToken'];
      
      if (accessToken != null) {
        print('🔑 Got access token: ${accessToken.toString().substring(0, 20)}...');
        
        // Now test the profile endpoint
        final profileResponse = await http.get(
          Uri.parse('http://localhost:5000/api/auth/me'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json',
          },
        );
        
        print('📥 Profile endpoint: ${profileResponse.statusCode}');
        print('📥 Profile data: ${profileResponse.body}');
        
        if (profileResponse.statusCode == 200) {
          final profile = jsonDecode(profileResponse.body);
          print('✅ Profile endpoint working');
          print('📋 Available fields: ${profile.keys.toList()}');
        }
      }
    } else {
      print('❌ Login failed for profile test: ${loginResponse.statusCode}');
    }
    
  } catch (e) {
    print('❌ Profile test error: $e');
  }
}

Future<void> testEmailVerificationFlow() async {
  print('\n📍 Test 3: Email Verification Flow');
  
  try {
    // Test resend verification first
    final resendData = {
      'email': 'test@example.com',
    };
    
    final resendResponse = await http.post(
      Uri.parse('http://localhost:5000/api/auth/resend-verification'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(resendData),
    );
    
    print('📥 Resend verification: ${resendResponse.statusCode}');
    print('📥 Resend response: ${resendResponse.body}');
    
    // Test verify email with a mock token
    final verifyData = {
      'token': 'test-verification-token',
    };
    
    final verifyResponse = await http.post(
      Uri.parse('http://localhost:5000/api/auth/verify-email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(verifyData),
    );
    
    print('📥 Verify email: ${verifyResponse.statusCode}');
    print('📥 Verify response: ${verifyResponse.body}');
    
    // Also test GET method for email verification (some apps use GET with query params)
    final verifyGetResponse = await http.get(
      Uri.parse('http://localhost:5000/api/auth/verify-email?token=test-token'),
    );
    
    print('📥 Verify email (GET): ${verifyGetResponse.statusCode}');
    print('📥 Verify GET response: ${verifyGetResponse.body}');
    
  } catch (e) {
    print('❌ Email verification test error: $e');
  }
}