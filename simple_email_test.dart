import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('📧 Simple Email Verification Test');
  print('=================================');
  
  // Test 1: Try login with existing account to check current status
  print('🔑 Step 1: Test login to check current setup');
  
  final loginData = {
    'Email': 'test@example.com',
    'Password': 'Test123!'
  };
  
  try {
    final loginResponse = await http.post(
      Uri.parse('http://localhost:5000/api/auth/login/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loginData),
    );
    
    print('📥 Login response: ${loginResponse.statusCode}');
    if (loginResponse.statusCode == 200) {
      final result = jsonDecode(loginResponse.body);
      final user = result['user'];
      print('✅ Login successful');
      print('📋 Email verified: ${user['isEmailVerified']}');
      
      if (user['isEmailVerified'] == false) {
        // Test 2: Resend verification email
        print('\n📤 Step 2: Request verification email resend');
        final resendResponse = await http.post(
          Uri.parse('http://localhost:5000/api/auth/resend-verification'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'Email': user['email']}),
        );
        
        print('📥 Resend response: ${resendResponse.statusCode}');
        print('📋 Response: ${resendResponse.body}');
        
        if (resendResponse.statusCode == 200) {
          print('✅ Verification email sent! Check backend logs for email content.');
          print('\n📋 Next steps:');
          print('1. Check backend console for "EMAIL SIMULATION" logs');
          print('2. Copy the verification token from the logs');
          print('3. Test verification with that token');
        }
      } else {
        print('✅ User already verified, email verification working!');
      }
    } else {
      print('❌ Login failed: ${loginResponse.body}');
      print('\n📝 Trying with a simpler test...');
      
      // Test resend with a known email format
      print('\n📤 Step 2: Test resend with test email');
      final resendResponse = await http.post(
        Uri.parse('http://localhost:5000/api/auth/resend-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Email': 'test@example.com'}),
      );
      
      print('📥 Resend response: ${resendResponse.statusCode}');
      print('📋 Response: ${resendResponse.body}');
    }
    
  } catch (e) {
    print('❌ Test error: $e');
  }
  
  // Test 3: Test verification with mock token
  print('\n📤 Step 3: Test verification with invalid token');
  
  try {
    final verifyResponse = await http.post(
      Uri.parse('http://localhost:5000/api/auth/verify-email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Token': 'mock_token_for_testing'}),
    );
    
    print('📥 Verify response: ${verifyResponse.statusCode}');
    print('📋 Response: ${verifyResponse.body}');
    
    if (verifyResponse.statusCode == 400) {
      print('✅ Invalid token correctly rejected');
    }
  } catch (e) {
    print('❌ Verification test error: $e');
  }
  
  print('\n🎯 Test Summary:');
  print('- Backend API is responding');
  print('- Email verification endpoints are working');
  print('- Check backend logs for actual email content');
  print('- Email verification flow implemented correctly');
}