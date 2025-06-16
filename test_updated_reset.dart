import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔄 Testing Updated Password Reset Configuration');
  print('================================================');
  
  await testUpdatedPasswordReset();
}

Future<void> testUpdatedPasswordReset() async {
  try {
    // Step 1: Request password reset with updated backend
    print('📤 Step 1: Request password reset');
    
    final resetEmail = 'v_ismayilov@yahoo.com'; // Using the email that worked before
    
    final forgotResponse = await http.post(
      Uri.parse('http://localhost:5000/api/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Email': resetEmail}),
    );
    
    print('📥 Forgot password response: ${forgotResponse.statusCode}');
    print('📋 Response: ${forgotResponse.body}');
    
    if (forgotResponse.statusCode == 200) {
      print('✅ Password reset request successful!');
      print('📧 Reset email would be sent to: $resetEmail');
      print('');
      print('🔗 With updated config, the reset URL should now be:');
      print('   http://127.0.0.1:3000/reset-password?token=<TOKEN>');
      print('');
      print('💡 Benefits of 127.0.0.1 over localhost:');
      print('   • 127.0.0.1 is more likely to work in email clients');
      print('   • Some browsers handle 127.0.0.1 differently than localhost');
      print('   • Better compatibility with email link clicking');
      print('');
      print('🧪 To test the complete flow:');
      print('1. Check backend logs for simulated email content');
      print('2. Copy the token from the reset URL in logs');
      print('3. Navigate to: http://127.0.0.1:3000/reset-password?token=<TOKEN>');
      print('4. Or try clicking the link from a real email (if SMTP is configured)');
      
    } else {
      print('❌ Password reset request failed');
    }
    
  } catch (e) {
    print('❌ Test error: $e');
  }
}

void printConfiguration() {
  print('\n📋 Current Backend Configuration:');
  print('Frontend BaseUrl: http://127.0.0.1:3000');
  print('Password reset URLs will use: 127.0.0.1 instead of localhost');
  print('This should improve email link compatibility.');
}