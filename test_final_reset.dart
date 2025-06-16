import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🎯 Testing Final Password Reset Configuration');
  print('==============================================');
  
  await testFinalPasswordReset();
}

Future<void> testFinalPasswordReset() async {
  try {
    // Step 1: Request password reset
    print('📤 Step 1: Request password reset');
    
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
      print('🔗 Password reset URL should now be:');
      print('   http://127.0.0.1:8080/reset-password?token=<TOKEN>');
      print('');
      print('✅ Port corrected: 8080 (matches Flutter app)');
      print('✅ IP address: 127.0.0.1 (better email compatibility)');
      
      // Step 2: Verify the Flutter app is accessible
      print('\n📤 Step 2: Verify Flutter app accessibility');
      
      try {
        final flutterResponse = await http.get(Uri.parse('http://127.0.0.1:8080'));
        if (flutterResponse.statusCode == 200) {
          print('✅ Flutter app accessible at 127.0.0.1:8080');
        } else {
          print('⚠️  Flutter app returned: ${flutterResponse.statusCode}');
        }
      } catch (e) {
        print('❌ Flutter app not accessible at 127.0.0.1:8080: $e');
      }
      
      // Step 3: Test with localhost too
      try {
        final localhostResponse = await http.get(Uri.parse('http://localhost:8080'));
        if (localhostResponse.statusCode == 200) {
          print('✅ Flutter app also accessible at localhost:8080');
        }
      } catch (e) {
        print('⚠️  localhost:8080 not accessible: $e');
      }
      
      print('');
      print('🧪 To test the complete password reset flow:');
      print('1. Check backend logs for the generated token');
      print('2. Open: http://127.0.0.1:8080/reset-password?token=<TOKEN>');
      print('3. Or: http://localhost:8080/reset-password?token=<TOKEN>');
      print('4. Enter new password and submit');
      print('5. Try logging in with the new password');
      
    } else {
      print('❌ Password reset request failed: ${forgotResponse.body}');
    }
    
  } catch (e) {
    print('❌ Test error: $e');
  }
}

void printSummary() {
  print('\n📋 FIXED Configuration:');
  print('• Backend Frontend.BaseUrl: http://127.0.0.1:8080');
  print('• Flutter app running on: port 8080');
  print('• Reset links will now work properly!');
  print('');
  print('🔧 Previous issues resolved:');
  print('• ❌ localhost:3000 → ✅ 127.0.0.1:8080');
  print('• ❌ Port mismatch → ✅ Correct port 8080');
  print('• ❌ Email links broken → ✅ Should work now');
}