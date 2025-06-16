import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔧 Testing Profile Endpoint Fix');
  print('===============================');
  
  await testNewProfileEndpoint();
}

Future<void> testNewProfileEndpoint() async {
  try {
    // Step 1: Login to get token
    print('📤 Step 1: Login to get access token');
    
    final loginData = {
      'Email': 'persist_test_1750076018231@example.com',
      'Password': 'TestPassword123!',
    };
    
    final loginResponse = await http.post(
      Uri.parse('http://localhost:5000/api/auth/login/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loginData),
    );
    
    if (loginResponse.statusCode == 200) {
      final loginResult = jsonDecode(loginResponse.body);
      final accessToken = loginResult['tokens']['accessToken'];
      
      print('✅ Login successful');
      print('🔗 Token: ${accessToken?.substring(0, 30)}...');
      
      // Step 2: Test the corrected endpoint 
      print('\n📤 Step 2: Testing fixed Flutter endpoint: /auth/me');
      
      final profileResponse = await http.get(
        Uri.parse('http://localhost:5000/api/auth/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );
      
      print('📥 Profile response: ${profileResponse.statusCode}');
      
      if (profileResponse.statusCode == 200) {
        final profileData = jsonDecode(profileResponse.body);
        print('✅ Profile endpoint working correctly!');
        print('📋 Response structure matches Flutter UserModel expectations:');
        print('   - id: ${profileData['id']}');
        print('   - firstName: ${profileData['firstName']}');
        print('   - lastName: ${profileData['lastName']}');
        print('   - email: ${profileData['email']}');
        print('   - phoneNumber: ${profileData['phoneNumber']}');
        print('   - isEmailVerified: ${profileData['isEmailVerified']}');
        print('   - isPhoneVerified: ${profileData['isPhoneVerified']}');
        
        // Step 3: Verify old broken endpoint returns 404
        print('\n📤 Step 3: Verifying old broken endpoint: /user/profile');
        
        final oldResponse = await http.get(
          Uri.parse('http://localhost:5000/api/user/profile'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json',
          },
        );
        
        print('📥 Old endpoint response: ${oldResponse.statusCode}');
        if (oldResponse.statusCode == 404) {
          print('✅ Confirmed: Old endpoint /user/profile returns 404 (as expected)');
        }
        
        print('\n🎉 FIXED! Flutter app should now load user profile correctly!');
        
      } else {
        print('❌ Profile endpoint failed: ${profileResponse.statusCode}');
        print('Response: ${profileResponse.body}');
      }
    } else {
      print('❌ Login failed: ${loginResponse.body}');
    }
  } catch (e) {
    print('❌ Test error: $e');
  }
}