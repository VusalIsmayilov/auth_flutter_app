import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Testing Profile Endpoint Issue');
  print('==================================');
  
  await testProfileEndpoint();
}

Future<void> testProfileEndpoint() async {
  try {
    // First, login to get a token
    print('📤 Step 1: Logging in to get access token');
    
    final loginData = {
      'Email': 'persist_test_1750076018231@example.com',
      'Password': 'TestPassword123!',
    };
    
    final loginResponse = await http.post(
      Uri.parse('http://localhost:5000/api/auth/login/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loginData),
    );
    
    print('📥 Login response: ${loginResponse.statusCode}');
    
    if (loginResponse.statusCode == 200) {
      final loginResult = jsonDecode(loginResponse.body);
      final accessToken = loginResult['tokens']['accessToken'];
      
      print('✅ Login successful, got access token');
      print('🔗 Token: ${accessToken?.substring(0, 50)}...');
      
      // Now test the profile endpoint
      print('\n📤 Step 2: Testing profile endpoint');
      
      final profileResponse = await http.get(
        Uri.parse('http://localhost:5000/api/auth/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );
      
      print('📥 Profile response: ${profileResponse.statusCode}');
      print('📋 Profile response body: ${profileResponse.body}');
      
      if (profileResponse.statusCode == 200) {
        final profileData = jsonDecode(profileResponse.body);
        print('✅ Profile endpoint working correctly!');
        print('👤 User data: ${jsonEncode(profileData)}');
      } else {
        print('❌ Profile endpoint failed');
        print('❗ Headers sent: Authorization: Bearer $accessToken');
        print('❗ Response headers: ${profileResponse.headers}');
      }
      
      // Test different variations
      print('\n📤 Step 3: Testing direct user endpoint variations');
      
      // Test without /api prefix
      final directResponse = await http.get(
        Uri.parse('http://localhost:5000/auth/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );
      print('📥 Direct /auth/me: ${directResponse.statusCode}');
      
      // Test with different headers
      final altResponse = await http.get(
        Uri.parse('http://localhost:5000/api/auth/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
      );
      print('📥 With Content-Type: ${altResponse.statusCode}');
      
    } else {
      print('❌ Login failed: ${loginResponse.body}');
    }
  } catch (e) {
    print('❌ Test error: $e');
  }
}