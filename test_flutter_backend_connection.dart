#!/usr/bin/env dart

import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  print('🔧 Testing Flutter Backend Connection');
  print('=' * 50);
  
  const baseUrl = 'http://localhost:5001/api';
  
  try {
    // Test 1: Basic connectivity
    print('1. Testing basic connectivity...');
    final healthResponse = await http.get(
      Uri.parse('$baseUrl/health'),
    ).timeout(const Duration(seconds: 10));
    
    print('   Status: ${healthResponse.statusCode}');
    if (healthResponse.statusCode == 404) {
      print('   ✅ Backend is reachable (404 expected for /health)');
    }
    
    // Test 2: CORS preflight
    print('\n2. Testing CORS headers...');
    final corsResponse = await http.get(
      Uri.parse('$baseUrl/auth/login/email'),
      headers: {
        'Origin': 'http://localhost:3000',
        'Content-Type': 'application/json',
      },
    ).timeout(const Duration(seconds: 10));
    
    print('   Status: ${corsResponse.statusCode}');
    print('   CORS Headers: ${corsResponse.headers['access-control-allow-origin']}');
    
    // Test 3: Registration endpoint
    print('\n3. Testing registration endpoint...');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final testData = {
      'email': 'flutter_test_$timestamp@example.com',
      'password': 'TestPassword123',
      'firstName': 'Flutter',
      'lastName': 'Test',
    };
    
    final regResponse = await http.post(
      Uri.parse('$baseUrl/auth/register/email'),
      headers: {
        'Content-Type': 'application/json',
        'Origin': 'http://localhost:3000',
      },
      body: json.encode(testData),
    ).timeout(const Duration(seconds: 30));
    
    print('   Status: ${regResponse.statusCode}');
    print('   Response: ${regResponse.body}');
    
    if (regResponse.statusCode == 200 || regResponse.statusCode == 201) {
      final responseData = json.decode(regResponse.body);
      if (responseData['success'] == true) {
        print('   ✅ Registration test successful!');
        
        // Test 4: Login with the created user
        print('\n4. Testing login with created user...');
        final loginData = {
          'email': testData['email'],
          'password': testData['password'],
        };
        
        final loginResponse = await http.post(
          Uri.parse('$baseUrl/auth/login/email'),
          headers: {
            'Content-Type': 'application/json',
            'Origin': 'http://localhost:3000',
          },
          body: json.encode(loginData),
        ).timeout(const Duration(seconds: 30));
        
        print('   Status: ${loginResponse.statusCode}');
        print('   Response: ${loginResponse.body}');
        
        if (loginResponse.statusCode == 200) {
          final loginResponseData = json.decode(loginResponse.body);
          if (loginResponseData['success'] == true) {
            print('   ✅ Login test successful!');
          } else {
            print('   ❌ Login failed: ${loginResponseData['message']}');
          }
        }
      } else {
        print('   ❌ Registration failed: ${responseData['message']}');
      }
    }
    
  } catch (e) {
    print('❌ Connection test failed: $e');
    print('\n🔧 Possible issues:');
    print('- Backend not running on port 5001');
    print('- CORS configuration issue');
    print('- Network connectivity problem');
    print('- Flutter web security restrictions');
  }
}