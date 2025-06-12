import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() async {
  print('=== Email Verification End-to-End Manual Test ===\n');

  // Test configuration
  const baseUrl = 'http://localhost:80';
  final testEmail = 'test_${DateTime.now().millisecondsSinceEpoch}@example.com';
  const testPassword = 'TestPassword123!';
  
  print('Test Configuration:');
  print('- Base URL: $baseUrl');
  print('- Test Email: $testEmail');
  print('- Test Password: $testPassword');
  print('');

  try {
    // Step 1: Test Registration
    print('Step 1: Testing Registration...');
    final registrationResponse = await testRegistration(baseUrl, testEmail, testPassword);
    
    if (registrationResponse['success'] == true) {
      print('✅ Registration successful');
      print('   - User ID: ${registrationResponse['user']?['id']}');
      print('   - Email: ${registrationResponse['user']?['email']}');
      print('   - Email Verified: ${registrationResponse['user']?['isEmailVerified']}');
      print('');
      
      // Step 2: Test Resend Verification Email
      print('Step 2: Testing Resend Verification Email...');
      final resendResponse = await testResendVerification(baseUrl, testEmail);
      
      if (resendResponse['success'] == true) {
        print('✅ Resend verification email successful');
        print('   - Message: ${resendResponse['message']}');
        print('');
        
        // Step 3: Simulate Email Verification (we need a real token from email)
        print('Step 3: Testing Email Verification with Mock Token...');
        print('⚠️  Note: This will fail as we need a real token from the email');
        
        // Generate a mock token for testing purposes
        const mockToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9';
        final verificationResponse = await testEmailVerification(baseUrl, mockToken);
        
        if (verificationResponse['success'] == true) {
          print('✅ Email verification successful');
          print('   - Message: ${verificationResponse['message']}');
        } else {
          print('❌ Email verification failed (expected with mock token)');
          print('   - Error: ${verificationResponse['message']}');
        }
      } else {
        print('❌ Resend verification email failed');
        print('   - Error: ${resendResponse['message']}');
      }
    } else {
      print('❌ Registration failed');
      print('   - Error: ${registrationResponse['message']}');
    }
    
  } catch (e) {
    print('❌ Test failed with exception: $e');
  }
  
  print('\n=== Test Summary ===');
  print('1. Registration: Tests creating a new user account');
  print('2. Resend Verification: Tests sending verification email');
  print('3. Email Verification: Tests token-based verification');
  print('');
  print('Next Steps:');
  print('- Check email inbox for verification token');
  print('- Use real token to test verification endpoint');
  print('- Test frontend UI with real backend integration');
}

Future<Map<String, dynamic>> testRegistration(String baseUrl, String email, String password) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register/email'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
        'password': password,
        'firstName': 'Test',
        'lastName': 'User',
      }),
    );
    
    print('   - Registration request sent');
    print('   - Status Code: ${response.statusCode}');
    
    final responseData = json.decode(response.body);
    return responseData;
  } catch (e) {
    return {'success': false, 'message': 'Network error: $e'};
  }
}

Future<Map<String, dynamic>> testResendVerification(String baseUrl, String email) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/resend-verification'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'email': email,
      }),
    );
    
    print('   - Resend verification request sent');
    print('   - Status Code: ${response.statusCode}');
    
    final responseData = json.decode(response.body);
    return responseData;
  } catch (e) {
    return {'success': false, 'message': 'Network error: $e'};
  }
}

Future<Map<String, dynamic>> testEmailVerification(String baseUrl, String token) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/verify-email'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'token': token,
      }),
    );
    
    print('   - Email verification request sent');
    print('   - Status Code: ${response.statusCode}');
    
    final responseData = json.decode(response.body);
    return responseData;
  } catch (e) {
    return {'success': false, 'message': 'Network error: $e'};
  }
}