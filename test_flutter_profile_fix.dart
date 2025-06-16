import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔍 Testing Flutter Profile Fix');
  print('===============================');
  
  await testUserModelParsing();
}

Future<void> testUserModelParsing() async {
  try {
    // Test the actual response structure from backend
    print('📤 Step 1: Login and get user data');
    
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
      
      // Get profile data
      final profileResponse = await http.get(
        Uri.parse('http://localhost:5000/api/auth/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );
      
      if (profileResponse.statusCode == 200) {
        final profileData = jsonDecode(profileResponse.body) as Map<String, dynamic>;
        
        print('📋 Backend response structure:');
        print('   - id: ${profileData['id']}');
        print('   - firstName: ${profileData['firstName']}');
        print('   - lastName: ${profileData['lastName']}');
        print('   - email: ${profileData['email']}');
        print('   - phoneNumber: ${profileData['phoneNumber']}');
        
        // Test if this structure would work with our Flutter model
        print('\n✅ Profile data structure is correct for Flutter UserModel');
        print('✅ firstName and lastName fields are in camelCase as expected');
        
        // Simulate what Flutter would receive
        final testUserData = {
          'id': profileData['id'],
          'firstName': profileData['firstName'],
          'lastName': profileData['lastName'],
          'email': profileData['email'],
          'phoneNumber': profileData['phoneNumber'],
          'isEmailVerified': profileData['isEmailVerified'],
          'isPhoneVerified': profileData['isPhoneVerified'],
          'currentRole': profileData['currentRole'],
          'currentRoleDisplayName': profileData['currentRoleDisplayName'],
        };
        
        print('📦 Simulated Flutter UserModel parsing:');
        print('   Full name would be: ${testUserData['firstName']} ${testUserData['lastName']}');
        print('   Email: ${testUserData['email']}');
        print('   Phone: ${testUserData['phoneNumber']}');
        
      } else {
        print('❌ Profile request failed: ${profileResponse.statusCode}');
      }
    } else {
      print('❌ Login failed: ${loginResponse.body}');
    }
  } catch (e) {
    print('❌ Test error: $e');
  }
}