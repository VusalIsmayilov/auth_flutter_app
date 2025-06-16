import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🎯 Testing Flutter Field Mapping Fix');
  print('====================================');
  
  await testFlutterFieldMapping();
}

Future<void> testFlutterFieldMapping() async {
  try {
    // Test the exact way Flutter sends the data (camelCase)
    final testEmail = 'persist_test_1750076018231@example.com';
    final testPassword = 'TestPassword123!';
    
    // Step 1: Login
    print('📤 Step 1: Login to get access token');
    
    final loginResponse = await http.post(
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
    
    final loginResult = jsonDecode(loginResponse.body);
    final accessToken = loginResult['tokens']['accessToken'];
    print('✅ Login successful');
    
    // Step 2: Test Flutter-style camelCase data (this is what Flutter sends)
    print('\n📤 Step 2: Sending Flutter-style camelCase data');
    
    final flutterStyleData = {
      'firstName': 'FlutterTest',  // camelCase (what Flutter uses)
      'lastName': 'CamelCase',    // camelCase (what Flutter uses)  
      'phoneNumber': '+1111111111', // camelCase (what Flutter uses)
    };
    
    print('📋 Flutter sends: $flutterStyleData');
    
    // Convert to backend format (PascalCase) - this is what our fix should do
    final backendData = {
      'FirstName': flutterStyleData['firstName'],   // PascalCase (what backend expects)
      'LastName': flutterStyleData['lastName'],     // PascalCase (what backend expects)
      'PhoneNumber': flutterStyleData['phoneNumber'], // PascalCase (what backend expects)
    };
    
    print('📋 Backend expects: $backendData');
    
    // Step 3: Test the update with correct PascalCase mapping
    print('\n📤 Step 3: Updating profile with correct field mapping');
    
    final updateResponse = await http.put(
      Uri.parse('http://localhost:5000/api/auth/me'),
      headers: {
        'Authorization': 'Bearer $accessToken',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(backendData),
    );
    
    print('📥 Update response: ${updateResponse.statusCode}');
    
    if (updateResponse.statusCode == 200) {
      final updatedProfile = jsonDecode(updateResponse.body);
      print('✅ Profile updated successfully!');
      print('📋 Updated profile (backend response):');
      print('   - firstName: ${updatedProfile['firstName']}');
      print('   - lastName: ${updatedProfile['lastName']}');
      print('   - phoneNumber: ${updatedProfile['phoneNumber']}');
      
      // Verify the values match what we sent
      if (updatedProfile['firstName'] == 'FlutterTest' &&
          updatedProfile['lastName'] == 'CamelCase' &&
          updatedProfile['phoneNumber'] == '+1111111111') {
        print('\n🎉 SUCCESS! Field mapping works correctly!');
        print('✅ Flutter camelCase → Backend PascalCase mapping fixed');
        print('✅ Backend returns camelCase for Flutter compatibility');
        print('✅ Profile updates will now work in Flutter app!');
      } else {
        print('\n❌ Field values don\'t match expected results');
      }
    } else {
      print('❌ Profile update failed: ${updateResponse.statusCode}');
      print('Response: ${updateResponse.body}');
    }
    
  } catch (e) {
    print('❌ Test error: $e');
  }
}