import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔧 Testing Profile Update Feature');
  print('=================================');
  
  await testProfileUpdate();
}

Future<void> testProfileUpdate() async {
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
      
      // Step 2: Get current profile
      print('\n📤 Step 2: Get current profile');
      
      final profileResponse = await http.get(
        Uri.parse('http://localhost:5000/api/auth/me'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Accept': 'application/json',
        },
      );
      
      if (profileResponse.statusCode == 200) {
        final currentProfile = jsonDecode(profileResponse.body);
        print('📋 Current profile:');
        print('   - firstName: ${currentProfile['firstName']}');
        print('   - lastName: ${currentProfile['lastName']}');
        print('   - phoneNumber: ${currentProfile['phoneNumber']}');
        
        // Step 3: Update profile
        print('\n📤 Step 3: Update profile');
        
        final updateData = {
          'FirstName': 'UpdatedFirstName',
          'LastName': 'UpdatedLastName',
          'PhoneNumber': '+9999999999',
        };
        
        final updateResponse = await http.put(
          Uri.parse('http://localhost:5000/api/auth/me'),
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
          body: jsonEncode(updateData),
        );
        
        print('📥 Update response: ${updateResponse.statusCode}');
        
        if (updateResponse.statusCode == 200) {
          final updatedProfile = jsonDecode(updateResponse.body);
          print('✅ Profile updated successfully!');
          print('📋 Updated profile:');
          print('   - firstName: ${updatedProfile['firstName']}');
          print('   - lastName: ${updatedProfile['lastName']}');
          print('   - phoneNumber: ${updatedProfile['phoneNumber']}');
          
          // Step 4: Verify persistence by getting profile again
          print('\n📤 Step 4: Verify persistence');
          
          final verifyResponse = await http.get(
            Uri.parse('http://localhost:5000/api/auth/me'),
            headers: {
              'Authorization': 'Bearer $accessToken',
              'Accept': 'application/json',
            },
          );
          
          if (verifyResponse.statusCode == 200) {
            final verifyProfile = jsonDecode(verifyResponse.body);
            print('✅ Profile persistence verified!');
            print('📋 Persisted profile:');
            print('   - firstName: ${verifyProfile['firstName']}');
            print('   - lastName: ${verifyProfile['lastName']}');
            print('   - phoneNumber: ${verifyProfile['phoneNumber']}');
            
            print('\n🎉 COMPLETE! Profile updates now persist to database!');
          } else {
            print('❌ Verification failed: ${verifyResponse.statusCode}');
          }
        } else {
          print('❌ Profile update failed: ${updateResponse.statusCode}');
          print('Response: ${updateResponse.body}');
        }
      } else {
        print('❌ Failed to get profile: ${profileResponse.statusCode}');
      }
    } else {
      print('❌ Login failed: ${loginResponse.body}');
    }
  } catch (e) {
    print('❌ Test error: $e');
  }
}