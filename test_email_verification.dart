import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('📧 Testing Email Verification Service');
  print('====================================');
  
  await testEmailVerification();
}

Future<void> testEmailVerification() async {
  try {
    // Step 1: Register a new user (should trigger verification email)
    print('📤 Step 1: Register new user (should send verification email)');
    
    final email = 'verify_test_${DateTime.now().millisecondsSinceEpoch}@example.com';
    final registrationData = {
      'Email': email,
      'Password': 'TestPassword123',
      'FirstName': 'Test',
      'LastName': 'User',
      'PhoneNumber': '+1234567890',
    };
    
    print('📤 Registering: $email');
    
    final registerResponse = await http.post(
      Uri.parse('http://localhost:5000/api/auth/register/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(registrationData),
    );
    
    print('📥 Registration response: ${registerResponse.statusCode}');
    
    if (registerResponse.statusCode == 200) {
      final registrationResult = jsonDecode(registerResponse.body);
      final user = registrationResult['user'];
      
      print('✅ Registration successful');
      print('📋 User: ${user['email']}');
      print('📋 Email verified: ${user['isEmailVerified']}');
      
      if (user['isEmailVerified'] == false) {
        print('✅ User correctly marked as unverified');
        print('📧 Check backend logs for verification email');
      } else {
        print('⚠️  User marked as verified immediately (unexpected)');
      }
      
      // Step 2: Test resend verification email
      print('\n📤 Step 2: Test resend verification email');
      
      final resendResponse = await http.post(
        Uri.parse('http://localhost:5000/api/auth/resend-verification'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Email': email}),
      );
      
      print('📥 Resend verification response: ${resendResponse.statusCode}');
      print('📋 Response: ${resendResponse.body}');
      
      if (resendResponse.statusCode == 200) {
        print('✅ Resend verification request successful');
      } else {
        print('❌ Resend verification failed');
      }
      
      // Step 3: Test verification with invalid token
      print('\n📤 Step 3: Test verification with invalid token');
      
      final invalidVerifyResponse = await http.post(
        Uri.parse('http://localhost:5000/api/auth/verify-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'Token': 'invalid_token_123'}),
      );
      
      print('📥 Invalid token verification: ${invalidVerifyResponse.statusCode}');
      print('📋 Response: ${invalidVerifyResponse.body}');
      
      if (invalidVerifyResponse.statusCode == 400) {
        print('✅ Invalid token correctly rejected');
      }
      
      print('\n📋 Next steps to complete testing:');
      print('1. Check backend logs for verification email content');
      print('2. Look for: "EMAIL SIMULATION" or "Verification email sent"');
      print('3. Copy the verification token from logs');
      print('4. Test with real token using:');
      print('   POST /api/auth/verify-email with {"Token": "<REAL_TOKEN>"}');
      print('5. Or navigate to verification URL in Flutter app');
      
    } else {
      print('❌ Registration failed: ${registerResponse.body}');
    }
    
  } catch (e) {
    print('❌ Test error: $e');
  }
}

void printEmailConfig() {
  print('\n📋 Current Email Configuration:');
  print('Provider: SMTP (Gmail)');
  print('From: vusal.b.ismayilov@gmail.com');
  print('Mode: Simulation (emails logged to console)');
  print('');
  print('🔧 To enable real emails:');
  print('1. Ensure SMTP credentials are correct');
  print('2. Check Gmail app password is valid');
  print('3. Verify network connectivity');
}