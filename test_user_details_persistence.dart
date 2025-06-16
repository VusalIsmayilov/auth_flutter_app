import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Testing User Details Persistence');
  print('===================================');
  
  await runAllTests();
}

Future<Map<String, dynamic>?> testRegistrationAndPersistence() async {
  print('\n📍 Test 1: Registration with User Details');
  
  try {
    final email = 'persist_test_${DateTime.now().millisecondsSinceEpoch}@example.com';
    final registrationData = {
      'Email': email,
      'Password': 'TestPassword123!',
      'FirstName': 'John',
      'LastName': 'Doe',
      'PhoneNumber': '+1234567890',
    };
    
    print('📤 Registering with details: ${jsonEncode(registrationData)}');
    
    final response = await http.post(
      Uri.parse('http://localhost:5000/api/auth/register/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(registrationData),
    );
    
    print('📥 Registration response: ${response.statusCode}');
    
    if (response.statusCode == 200 || response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final user = data['user'];
      final tokens = data['tokens'];
      
      print('✅ Registration successful');
      print('📋 User data from backend: ${jsonEncode(user)}');
      print('🔍 firstName: ${user['firstName'] ?? user['FirstName'] ?? 'NOT FOUND'}');
      print('🔍 lastName: ${user['lastName'] ?? user['LastName'] ?? 'NOT FOUND'}');
      print('🔍 phoneNumber: ${user['phoneNumber'] ?? user['PhoneNumber'] ?? 'NOT FOUND'}');
      
      return {
        'email': email,
        'password': 'TestPassword123!',
        'tokens': tokens,
        'user': user,
      };
    } else {
      print('❌ Registration failed: ${response.body}');
    }
  } catch (e) {
    print('❌ Registration test error: $e');
  }
  
  return null;
}

Future<void> testLoginAndRetrieveDetails(Map<String, dynamic>? registrationData) async {
  print('\n📍 Test 2: Login and Retrieve User Details');
  
  if (registrationData == null) {
    print('❌ No registration data available for login test');
    return;
  }
  
  try {
    final loginData = {
      'Email': registrationData['email'],
      'Password': registrationData['password'],
    };
    
    print('📤 Logging in with: ${registrationData['email']}');
    
    final loginResponse = await http.post(
      Uri.parse('http://localhost:5000/api/auth/login/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loginData),
    );
    
    print('📥 Login response: ${loginResponse.statusCode}');
    
    if (loginResponse.statusCode == 200) {
      final loginResult = jsonDecode(loginResponse.body);
      final user = loginResult['user'];
      final tokens = loginResult['tokens'];
      
      print('✅ Login successful');
      print('📋 User data from login: ${jsonEncode(user)}');
      print('🔍 firstName: ${user['firstName'] ?? user['FirstName'] ?? 'NOT FOUND'}');
      print('🔍 lastName: ${user['lastName'] ?? user['LastName'] ?? 'NOT FOUND'}');
      print('🔍 phoneNumber: ${user['phoneNumber'] ?? user['PhoneNumber'] ?? 'NOT FOUND'}');
      
      // Test profile endpoint
      final accessToken = tokens['accessToken'];
      if (accessToken != null) {
        print('\n📤 Testing profile endpoint with token');
        
        final profileResponse = await http.get(
          Uri.parse('http://localhost:5000/api/auth/me'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Accept': 'application/json',
          },
        );
        
        print('📥 Profile endpoint: ${profileResponse.statusCode}');
        
        if (profileResponse.statusCode == 200) {
          final profileData = jsonDecode(profileResponse.body);
          print('📋 Profile data: ${jsonEncode(profileData)}');
          print('🔍 firstName: ${profileData['firstName'] ?? profileData['FirstName'] ?? 'NOT FOUND'}');
          print('🔍 lastName: ${profileData['lastName'] ?? profileData['LastName'] ?? 'NOT FOUND'}');
          print('🔍 phoneNumber: ${profileData['phoneNumber'] ?? profileData['PhoneNumber'] ?? 'NOT FOUND'}');
        } else {
          print('❌ Profile endpoint failed: ${profileResponse.body}');
        }
      }
    } else {
      print('❌ Login failed: ${loginResponse.body}');
    }
  } catch (e) {
    print('❌ Login test error: $e');
  }
}

Future<void> testProfileUpdatePersistence() async {
  print('\n📍 Test 3: Profile Update Persistence');
  
  try {
    // First login with existing user
    final loginData = {
      'Email': 'v_ismayilov@yahoo.com',
      'Password': 'Vusal135!',
    };
    
    print('📤 Logging in to test profile update');
    
    final loginResponse = await http.post(
      Uri.parse('http://localhost:5000/api/auth/login/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(loginData),
    );
    
    if (loginResponse.statusCode == 200) {
      final loginResult = jsonDecode(loginResponse.body);
      final accessToken = loginResult['tokens']['accessToken'];
      
      print('✅ Login successful for profile update test');
      
      // Try to update profile (will likely fail with 404)
      final updateData = {
        'firstName': 'UpdatedFirst',
        'lastName': 'UpdatedLast',
        'phoneNumber': '+9999999999',
      };
      
      print('📤 Attempting profile update');
      
      final updateResponse = await http.put(
        Uri.parse('http://localhost:5000/api/auth/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(updateData),
      );
      
      print('📥 Profile update: ${updateResponse.statusCode}');
      print('📥 Update response: ${updateResponse.body}');
      
      if (updateResponse.statusCode == 404) {
        print('💡 Profile update endpoint not implemented in backend (expected)');
        print('💡 Flutter app should handle this with local storage');
      }
    }
  } catch (e) {
    print('❌ Profile update test error: $e');
  }
}

Future<void> runAllTests() async {
  final registrationData = await testRegistrationAndPersistence();
  await testLoginAndRetrieveDetails(registrationData);
  await testProfileUpdatePersistence();
}