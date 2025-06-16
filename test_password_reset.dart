import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔑 Testing Password Reset Flow');
  print('==============================');
  
  await testPasswordReset();
}

Future<void> testPasswordReset() async {
  try {
    // Step 1: Request password reset
    print('📤 Step 1: Request password reset');
    
    final resetEmail = 'persist_test_1750076018231@example.com';
    
    final forgotResponse = await http.post(
      Uri.parse('http://localhost:5000/api/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Email': resetEmail}),
    );
    
    print('📥 Forgot password response: ${forgotResponse.statusCode}');
    
    if (forgotResponse.statusCode == 200) {
      print('✅ Password reset email would be sent to: $resetEmail');
      print('📧 Check the backend logs for the simulated email content');
      print('🔗 Copy the token from the reset URL in the logs');
      
      // Step 2: Simulate token validation (you can paste the actual token here)
      print('\n📤 Step 2: Test token validation');
      print('💡 Paste the token from Safari URL or backend logs below:');
      
      // Example token for testing - replace with actual token from logs
      const exampleToken = 'PASTE_TOKEN_FROM_LOGS_HERE';
      
      if (exampleToken != 'PASTE_TOKEN_FROM_LOGS_HERE') {
        final validateResponse = await http.post(
          Uri.parse('http://localhost:5000/api/auth/validate-reset-token'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'Token': exampleToken}),
        );
        
        print('📥 Validate token response: ${validateResponse.statusCode}');
        
        if (validateResponse.statusCode == 200) {
          print('✅ Token is valid');
          
          // Step 3: Reset password
          print('\n📤 Step 3: Reset password with valid token');
          
          final resetResponse = await http.post(
            Uri.parse('http://localhost:5000/api/auth/reset-password'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'Token': exampleToken,
              'NewPassword': 'NewPassword123!'
            }),
          );
          
          print('📥 Reset password response: ${resetResponse.statusCode}');
          
          if (resetResponse.statusCode == 200) {
            print('✅ Password reset successful!');
            print('🔐 New password: NewPassword123!');
            
            // Step 4: Test login with new password
            print('\n📤 Step 4: Test login with new password');
            
            final loginResponse = await http.post(
              Uri.parse('http://localhost:5000/api/auth/login/email'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'Email': resetEmail,
                'Password': 'NewPassword123!'
              }),
            );
            
            print('📥 Login response: ${loginResponse.statusCode}');
            
            if (loginResponse.statusCode == 200) {
              print('✅ Login successful with new password!');
              print('🎉 Password reset flow working correctly!');
            } else {
              print('❌ Login failed with new password');
            }
          } else {
            print('❌ Password reset failed: ${resetResponse.body}');
          }
        } else {
          print('❌ Token validation failed: ${validateResponse.body}');
        }
      } else {
        print('⚠️  Please replace exampleToken with actual token from logs');
      }
    } else {
      print('❌ Forgot password failed: ${forgotResponse.body}');
    }
    
  } catch (e) {
    print('❌ Test error: $e');
  }
}

void printInstructions() {
  print('\n📋 How to test password reset:');
  print('1. Run this script to trigger password reset email');
  print('2. Check backend logs for simulated email content');
  print('3. Copy the token from the reset URL in logs');
  print('4. Paste the token in this script and run again');
  print('5. Or copy token from Safari error URL and paste here');
}