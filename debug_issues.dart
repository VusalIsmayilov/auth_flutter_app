import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🐛 Debugging Phone Number & Email Verification Issues');
  print('====================================================');
  
  await testBackendEndpoints();
  await testUserProfilePersistence();
}

Future<void> testBackendEndpoints() async {
  print('\n📍 Testing Backend Endpoints');
  
  try {
    // Test email verification endpoint
    final emailVerifyResponse = await http.post(
      Uri.parse('http://localhost:5000/api/auth/verify-email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': 'test-token'}),
    );
    
    print('✅ Email verification endpoint: ${emailVerifyResponse.statusCode}');
    print('   Response: ${emailVerifyResponse.body}');
    
    // Test get user profile endpoint (should be 401 without auth)
    final profileResponse = await http.get(
      Uri.parse('http://localhost:5000/api/auth/me'),
      headers: {'Accept': 'application/json'},
    );
    
    print('✅ Profile endpoint: ${profileResponse.statusCode}');
    print('   Response: ${profileResponse.body}');
    
    // Test swagger to see all available endpoints
    final swaggerResponse = await http.get(
      Uri.parse('http://localhost:5000/swagger/v1/swagger.json'),
    );
    
    if (swaggerResponse.statusCode == 200) {
      final swagger = jsonDecode(swaggerResponse.body);
      final paths = swagger['paths'] as Map<String, dynamic>;
      
      print('\n📋 Available Backend Endpoints:');
      for (final path in paths.keys) {
        final methods = (paths[path] as Map<String, dynamic>).keys;
        print('   $path: ${methods.join(', ').toUpperCase()}');
      }
    }
    
  } catch (e) {
    print('❌ Backend test error: $e');
  }
}

Future<void> testUserProfilePersistence() async {
  print('\n📍 Testing User Profile Data Structure');
  
  // Test what happens when we simulate a login response
  final mockUserData = {
    'id': 1,
    'email': 'v_ismayilov@yahoo.com',
    'phoneNumber': '+994501234567',
    'FirstName': 'Vusal',
    'LastName': 'Ismayilov',
    'isEmailVerified': false,
    'isPhoneVerified': false,
    'isActive': true,
  };
  
  print('📋 Mock user data structure:');
  print(jsonEncode(mockUserData));
  
  // Check what Flutter app expects vs what backend provides
  print('\n📋 Expected Flutter fields:');
  print('- id (int)');
  print('- email (String?)');
  print('- phoneNumber (String?)');
  print('- firstName (String?) - mapped from "FirstName"');
  print('- lastName (String?) - mapped from "LastName"');
  print('- isEmailVerified (bool)');
  print('- isPhoneVerified (bool)');
}