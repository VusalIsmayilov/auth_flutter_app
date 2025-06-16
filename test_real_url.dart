import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔗 Testing Real Password Reset URL');
  print('==================================');
  
  await testRealResetUrl();
}

Future<void> testRealResetUrl() async {
  try {
    // Step 1: Generate a real password reset token
    print('📤 Step 1: Generate password reset token');
    
    final resetEmail = 'v_ismayilov@yahoo.com';
    
    final forgotResponse = await http.post(
      Uri.parse('http://localhost:5000/api/auth/forgot-password'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'Email': resetEmail}),
    );
    
    if (forgotResponse.statusCode == 200) {
      print('✅ Password reset token generated');
      print('📧 Check the backend console for the simulated email content');
      print('');
      print('💡 Look for a message like:');
      print('   "EMAIL SIMULATION: To: v_ismayilov@yahoo.com, Subject: Reset Your Password"');
      print('   "EMAIL CONTENT: [HTML content with reset URL]"');
      print('');
      print('🔍 Find the URL in the email content that looks like:');
      print('   http://127.0.0.1:8080/reset-password?token=SOME_LONG_TOKEN');
      print('');
      print('📝 Copy that exact URL and paste it in your browser');
      print('');
      print('🚀 Alternative test URLs to try:');
      print('   • http://localhost:8080/reset-password?token=test');
      print('   • http://127.0.0.1:8080/reset-password?token=test');
      print('   • http://localhost:8080/#/reset-password?token=test');
      print('   • http://127.0.0.1:8080/#/reset-password?token=test');
      print('');
      print('📋 If none work, the issue might be:');
      print('   1. Flutter web routing configuration');
      print('   2. Web server configuration');
      print('   3. Hash routing vs path routing');
      
      // Step 2: Test basic Flutter routes that should work
      print('\n📤 Step 2: Testing basic Flutter app access');
      
      // Test if we can access the main page
      try {
        final mainResponse = await http.get(
          Uri.parse('http://localhost:8080'),
          headers: {'Accept': 'text/html'},
        );
        
        if (mainResponse.statusCode == 200) {
          print('✅ Flutter app main page accessible');
          
          // Check if it's using hash routing
          if (mainResponse.body.contains('#/') || mainResponse.body.contains('hash')) {
            print('💡 App might be using hash routing (#/)');
            print('   Try: http://localhost:8080/#/reset-password?token=TOKEN');
          } else {
            print('💡 App using path routing');
            print('   Try: http://localhost:8080/reset-password?token=TOKEN');
          }
        }
      } catch (e) {
        print('⚠️  Could not analyze Flutter app routing: $e');
      }
      
    } else {
      print('❌ Failed to generate reset token: ${forgotResponse.body}');
    }
    
  } catch (e) {
    print('❌ Test error: $e');
  }
}

void printDebuggingSteps() {
  print('\n🔧 Debugging Steps:');
  print('1. Open browser dev tools (F12)');
  print('2. Go to Network tab');
  print('3. Try the reset URL');
  print('4. Check what request is made and response received');
  print('5. Look for 404, routing errors, or redirect issues');
  print('');
  print('🎯 Expected behavior:');
  print('• URL should load Flutter reset password page');
  print('• Page should show password reset form');
  print('• Token should be passed to the page');
}