import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('📧 Testing Email Verification Fix');
  print('==================================');
  
  await testCompleteEmailVerificationFlow();
}

Future<void> testCompleteEmailVerificationFlow() async {
  print('\n📍 Complete Email Verification Test');
  
  try {
    // Step 1: Register a new user
    final email = 'emailtest_${DateTime.now().millisecondsSinceEpoch}@example.com';
    
    final registrationData = {
      'Email': email,
      'Password': 'TestPassword123!',
      'FirstName': 'Email',
      'LastName': 'Test',
    };
    
    print('📤 Step 1: Registering user with email: $email');
    
    final registerResponse = await http.post(
      Uri.parse('http://localhost:5000/api/auth/register/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(registrationData),
    );
    
    print('📥 Registration: ${registerResponse.statusCode}');
    
    if (registerResponse.statusCode == 200 || registerResponse.statusCode == 201) {
      final regData = jsonDecode(registerResponse.body);
      print('✅ Registration successful');
      
      // Step 2: Try to resend verification email
      print('\n📤 Step 2: Requesting verification email resend');
      
      final resendData = {'email': email};
      
      final resendResponse = await http.post(
        Uri.parse('http://localhost:5000/api/auth/resend-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(resendData),
      );
      
      print('📥 Resend verification: ${resendResponse.statusCode}');
      print('📥 Resend response: ${resendResponse.body}');
      
      if (resendResponse.statusCode == 200) {
        print('✅ Verification email sent successfully');
        print('📧 Check your email for verification link');
        print('💡 Copy the token from the email and use it in the app');
      } else {
        print('❌ Failed to send verification email');
        
        // Check if it's a configuration issue
        if (resendResponse.body.contains('email')) {
          print('💡 This might be an email service configuration issue in the backend');
          print('💡 Backend may need SMTP/SendGrid configuration');
        }
      }
      
      // Step 3: Test verification with a mock token (will fail but shows format)
      print('\n📤 Step 3: Testing verification endpoint format');
      
      final verifyData = {'token': 'mock-verification-token-for-testing'};
      
      final verifyResponse = await http.post(
        Uri.parse('http://localhost:5000/api/auth/verify-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(verifyData),
      );
      
      print('📥 Verify endpoint: ${verifyResponse.statusCode}');
      print('📥 Verify response: ${verifyResponse.body}');
      print('💡 Expected response: "Invalid or expired verification token" (normal for mock token)');
      
    } else {
      print('❌ Registration failed: ${registerResponse.body}');
    }
    
  } catch (e) {
    print('❌ Test error: $e');
  }
}