import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔄 Testing Complete Profile Persistence Across Sessions');
  print('========================================================');
  
  await testCompletePersistence();
}

Future<void> testCompletePersistence() async {
  try {
    final testEmail = 'persist_test_1750076018231@example.com';
    final testPassword = 'TestPassword123!';
    
    // Step 1: Login and update profile
    print('📤 Step 1: Login and update profile');
    
    var loginResponse = await http.post(
      Uri.parse('http://localhost:5000/api/auth/login/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Email': testEmail,
        'Password': testPassword,
      }),
    );
    
    if (loginResponse.statusCode != 200) {
      print('❌ Login failed: ${loginResponse.body}');
      return;
    }
    
    var loginResult = jsonDecode(loginResponse.body);
    var accessToken = loginResult['tokens']['accessToken'];
    
    // Update profile with new data
    final newData = {
      'FirstName': 'SessionTest',
      'LastName': 'PersistenceCheck',
      'PhoneNumber': '+8888888888',
    };
    
    final updateResponse = await http.put(
      Uri.parse('http://localhost:5000/api/auth/me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(newData),
    );
    
    if (updateResponse.statusCode == 200) {
      final updatedProfile = jsonDecode(updateResponse.body);
      print('✅ Profile updated to:');
      print('   - firstName: ${updatedProfile['firstName']}');
      print('   - lastName: ${updatedProfile['lastName']}');
      print('   - phoneNumber: ${updatedProfile['phoneNumber']}');
    } else {
      print('❌ Profile update failed');
      return;
    }
    
    // Step 2: Simulate logout (token expires/is cleared)
    print('\n🔓 Step 2: Simulating logout (clearing session)');
    accessToken = null; // Clear token to simulate logout
    
    // Step 3: Login again (new session)
    print('\n📤 Step 3: Login again with new session');
    
    loginResponse = await http.post(
      Uri.parse('http://localhost:5000/api/auth/login/email'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'Email': testEmail,
        'Password': testPassword,
      }),
    );
    
    if (loginResponse.statusCode != 200) {
      print('❌ Re-login failed: ${loginResponse.body}');
      return;
    }
    
    loginResult = jsonDecode(loginResponse.body);
    final newAccessToken = loginResult['tokens']['accessToken'];
    final loginUserData = loginResult['user'];
    
    print('✅ Re-login successful');
    print('📋 User data from login response:');
    print('   - firstName: ${loginUserData['firstName']}');
    print('   - lastName: ${loginUserData['lastName']}');
    print('   - phoneNumber: ${loginUserData['phoneNumber']}');
    
    // Step 4: Get profile from new session
    print('\n📤 Step 4: Get profile with new session token');
    
    final profileResponse = await http.get(
      Uri.parse('http://localhost:5000/api/auth/me'),
      headers: {
        'Authorization': 'Bearer $newAccessToken',
        'Accept': 'application/json',
      },
    );
    
    if (profileResponse.statusCode == 200) {
      final profileData = jsonDecode(profileResponse.body);
      print('✅ Profile retrieved from database:');
      print('   - firstName: ${profileData['firstName']}');
      print('   - lastName: ${profileData['lastName']}');
      print('   - phoneNumber: ${profileData['phoneNumber']}');
      
      // Verify data matches what we set
      if (profileData['firstName'] == 'SessionTest' && 
          profileData['lastName'] == 'PersistenceCheck' && 
          profileData['phoneNumber'] == '+8888888888') {
        print('\n🎉 SUCCESS! Profile updates persist across login sessions!');
        print('✅ Database storage is working correctly');
        print('✅ No more local-only workarounds needed');
      } else {
        print('\n❌ FAILURE! Data did not persist correctly');
      }
    } else {
      print('❌ Failed to get profile in new session: ${profileResponse.statusCode}');
    }
    
  } catch (e) {
    print('❌ Test error: $e');
  }
}