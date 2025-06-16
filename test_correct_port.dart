import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🎯 Testing Password Reset with Correct Port');
  print('===========================================');
  
  await testCorrectPort();
}

Future<void> testCorrectPort() async {
  try {
    // Step 1: Verify Flutter app is running on port 3000
    print('📤 Step 1: Verify Flutter app on port 3000');
    
    try {
      final flutterCheck = await http.get(Uri.parse('http://localhost:3000'));
      if (flutterCheck.statusCode == 200) {
        print('✅ Flutter app running on port 3000');
      } else {
        print('⚠️  Flutter app returned: ${flutterCheck.statusCode}');
      }
    } catch (e) {
      print('❌ Flutter app not accessible: $e');
      return;
    }
    
    // Step 2: Request password reset
    print('\n📤 Step 2: Request password reset');
    
    final resetEmail = 'v_ismayilov@yahoo.com';
    
    final forgotResponse = await http.post(
      Uri.parse('http://localhost:5000/api/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Email': resetEmail}),
    );
    
    print('📥 Forgot password response: ${forgotResponse.statusCode}');
    
    if (forgotResponse.statusCode == 200) {
      print('✅ Password reset request successful!');
      print('📧 Reset email sent to: $resetEmail');
      print('');
      print('🔗 Generated reset URL should be:');
      print('   http://localhost:3000/#/reset-password?token=<TOKEN>');
      print('');
      print('📋 Next steps:');
      print('1. Check the backend console output above');
      print('2. Look for "EMAIL SIMULATION" or "EMAIL CONTENT" logs');
      print('3. Copy the token from the reset URL in the logs');
      print('4. Open browser and navigate to:');
      print('   http://localhost:3000/#/reset-password?token=<ACTUAL_TOKEN>');
      print('');
      print('🧪 Test URLs to try:');
      print('• http://localhost:3000/#/reset-password?token=test');
      print('• http://localhost:3000/reset-password?token=test');
      print('');
      print('💡 If you see the Flutter reset password page, it works!');
      
    } else {
      print('❌ Password reset request failed: ${forgotResponse.body}');
    }
    
  } catch (e) {
    print('❌ Test error: $e');
  }
}