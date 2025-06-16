import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔑 Testing Actual Password Reset Token');
  print('======================================');
  
  await testActualToken();
}

Future<void> testActualToken() async {
  try {
    // Use the actual token from Safari error
    const actualToken = 'sEnUdSQfpaBW24bHN6fxdm_O5XUmUfPVQAsCAezKFtA';
    
    print('🔗 Testing token: $actualToken');
    
    // Step 1: Validate the token
    print('\n📤 Step 1: Validate reset token');
    
    final validateResponse = await http.post(
      Uri.parse('http://localhost:5000/api/auth/validate-reset-token'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Token': actualToken}),
    );
    
    print('📥 Validate token response: ${validateResponse.statusCode}');
    print('📋 Response: ${validateResponse.body}');
    
    if (validateResponse.statusCode == 200) {
      print('✅ Token is valid!');
      
      // Step 2: Reset password
      print('\n📤 Step 2: Reset password with valid token');
      
      final resetResponse = await http.post(
        Uri.parse('http://localhost:5000/api/auth/reset-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'Token': actualToken,
          'NewPassword': 'ResetPassword123!'
        }),
      );
      
      print('📥 Reset password response: ${resetResponse.statusCode}');
      print('📋 Response: ${resetResponse.body}');
      
      if (resetResponse.statusCode == 200) {
        print('✅ Password reset successful!');
        print('🔐 New password set to: ResetPassword123!');
        
        // Step 3: Test login with new password
        print('\n📤 Step 3: Test login with new password');
        
        // We need to find out which email this token belongs to
        // Let's try the test email we've been using
        final testEmail = 'persist_test_1750076018231@example.com';
        
        final loginResponse = await http.post(
          Uri.parse('http://localhost:5000/api/auth/login/email'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'Email': testEmail,
            'Password': 'ResetPassword123!'
          }),
        );
        
        print('📥 Login response: ${loginResponse.statusCode}');
        
        if (loginResponse.statusCode == 200) {
          final loginResult = jsonDecode(loginResponse.body);
          print('✅ Login successful with new password!');
          print('👤 User: ${loginResult['user']['email']}');
          print('🎉 Password reset flow working correctly!');
        } else {
          print('❌ Login failed with new password');
          print('📋 Response: ${loginResponse.body}');
          
          // Maybe the token was for a different email, let's try another common one
          print('\n📤 Trying alternative email addresses...');
          
          final alternativeEmails = [
            'v_ismayilov@yahoo.com',
            'test@example.com',
            'user@example.com'
          ];
          
          for (final email in alternativeEmails) {
            print('📤 Trying: $email');
            
            final altLoginResponse = await http.post(
              Uri.parse('http://localhost:5000/api/auth/login/email'),
              headers: {'Content-Type': 'application/json'},
              body: jsonEncode({
                'Email': email,
                'Password': 'ResetPassword123!'
              }),
            );
            
            if (altLoginResponse.statusCode == 200) {
              print('✅ SUCCESS! Token was for email: $email');
              break;
            } else {
              print('❌ Not for: $email');
            }
          }
        }
      } else {
        print('❌ Password reset failed');
        if (resetResponse.statusCode == 400) {
          print('💡 Token might be expired or already used');
        }
      }
    } else {
      print('❌ Token validation failed');
      if (validateResponse.statusCode == 400) {
        print('💡 Token is invalid or expired');
      }
    }
    
  } catch (e) {
    print('❌ Test error: $e');
  }
}