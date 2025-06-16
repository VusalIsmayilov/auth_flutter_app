import 'dart:convert';
import 'dart:io';

void main() async {
  print('🔐 Comprehensive Authentication Testing');
  print('=========================================');
  
  // Test 1: Registration
  await testRegistration();
  
  // Test 2: Login
  await testLogin();
  
  // Test 3: Token refresh
  await testTokenRefresh();
  
  // Test 4: Protected endpoint access
  await testProtectedEndpoint();
  
  // Test 5: Logout
  await testLogout();
  
  // Test 6: Email verification
  await testEmailVerification();
  
  // Test 7: Password reset
  await testPasswordReset();
  
  print('\n✅ Comprehensive authentication testing complete!');
}

Future<void> testRegistration() async {
  print('\n📍 Test 1: User Registration');
  
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('http://localhost:5001/api/auth/register/email'));
    
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    
    final body = jsonEncode({
      'email': 'test_${DateTime.now().millisecondsSinceEpoch}@example.com',
      'password': 'TestPassword123',
      'firstName': 'Test',
      'lastName': 'User',
    });
    request.write(body);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('   Status: ${response.statusCode}');
    
    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      print('   ✅ Registration successful!');
      print('   📧 User: ${data['user']?['email'] ?? 'Unknown'}');
      print('   🔑 Token received: ${data['tokens']?['accessToken']?.toString().substring(0, 20) ?? 'None'}...');
    } else {
      print('   ❌ Registration failed with status ${response.statusCode}');
      print('   📝 Response: ${responseBody.length > 200 ? '${responseBody.substring(0, 200)}...' : responseBody}');
    }
    
    client.close();
  } catch (e) {
    print('   ❌ Registration test error: $e');
  }
}

Future<Map<String, dynamic>?> testLogin() async {
  print('\n📍 Test 2: User Login');
  
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('http://localhost:5001/api/auth/login/email'));
    
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    
    // Use existing test user
    final body = jsonEncode({
      'email': 'test@example.com',
      'password': 'TestPassword123',
    });
    request.write(body);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('   Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      print('   ✅ Login successful!');
      print('   📧 User: ${data['user']?['email'] ?? 'Unknown'}');
      print('   🔑 Access token: ${data['tokens']?['accessToken']?.toString().substring(0, 20) ?? 'None'}...');
      print('   🔄 Refresh token: ${data['tokens']?['refreshToken']?.toString().substring(0, 20) ?? 'None'}...');
      
      client.close();
      return data;
    } else {
      print('   ❌ Login failed with status ${response.statusCode}');
      print('   📝 Response: ${responseBody.length > 200 ? '${responseBody.substring(0, 200)}...' : responseBody}');
      
      client.close();
      return null;
    }
  } catch (e) {
    print('   ❌ Login test error: $e');
    return null;
  }
}

Future<void> testTokenRefresh() async {
  print('\n📍 Test 3: Token Refresh');
  
  // First login to get tokens
  final loginData = await testLogin();
  if (loginData == null || loginData['tokens'] == null) {
    print('   ❌ Cannot test token refresh - login failed');
    return;
  }
  
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('http://localhost:5001/api/auth/refresh'));
    
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    
    final body = jsonEncode({
      'refreshToken': loginData['tokens']['refreshToken'],
    });
    request.write(body);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('   Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      print('   ✅ Token refresh successful!');
      print('   🔑 New access token: ${data['accessToken']?.toString().substring(0, 20) ?? 'None'}...');
      print('   🔄 New refresh token: ${data['refreshToken']?.toString().substring(0, 20) ?? 'None'}...');
    } else {
      print('   ❌ Token refresh failed with status ${response.statusCode}');
      print('   📝 Response: ${responseBody.length > 200 ? '${responseBody.substring(0, 200)}...' : responseBody}');
    }
    
    client.close();
  } catch (e) {
    print('   ❌ Token refresh test error: $e');
  }
}

Future<void> testProtectedEndpoint() async {
  print('\n📍 Test 4: Protected Endpoint Access');
  
  // First login to get access token
  final loginData = await testLogin();
  if (loginData == null || loginData['tokens'] == null) {
    print('   ❌ Cannot test protected endpoint - login failed');
    return;
  }
  
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('http://localhost:5001/api/auth/me'));
    
    request.headers.set('Accept', 'application/json');
    request.headers.set('Authorization', 'Bearer ${loginData['tokens']['accessToken']}');
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('   Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      print('   ✅ Protected endpoint access successful!');
      print('   📧 User: ${data['email'] ?? 'Unknown'}');
      print('   👤 Name: ${data['firstName'] ?? ''} ${data['lastName'] ?? ''}');
    } else {
      print('   ❌ Protected endpoint access failed with status ${response.statusCode}');
      print('   📝 Response: ${responseBody.length > 200 ? '${responseBody.substring(0, 200)}...' : responseBody}');
    }
    
    client.close();
  } catch (e) {
    print('   ❌ Protected endpoint test error: $e');
  }
}

Future<void> testLogout() async {
  print('\n📍 Test 5: User Logout');
  
  // First login to get tokens
  final loginData = await testLogin();
  if (loginData == null || loginData['tokens'] == null) {
    print('   ❌ Cannot test logout - login failed');
    return;
  }
  
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('http://localhost:5001/api/auth/revoke'));
    
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    request.headers.set('Authorization', 'Bearer ${loginData['tokens']['accessToken']}');
    
    final body = jsonEncode({
      'refreshToken': loginData['tokens']['refreshToken'],
    });
    request.write(body);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('   Status: ${response.statusCode}');
    
    if (response.statusCode == 200 || response.statusCode == 204) {
      print('   ✅ Logout successful!');
    } else {
      print('   ❌ Logout failed with status ${response.statusCode}');
      print('   📝 Response: ${responseBody.length > 200 ? '${responseBody.substring(0, 200)}...' : responseBody}');
    }
    
    client.close();
  } catch (e) {
    print('   ❌ Logout test error: $e');
  }
}

Future<void> testEmailVerification() async {
  print('\n📍 Test 6: Email Verification');
  
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('http://localhost:5001/api/auth/verify-email'));
    
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    
    final body = jsonEncode({
      'token': 'test_verification_token',
    });
    request.write(body);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('   Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      print('   ✅ Email verification endpoint accessible!');
      print('   📝 Response: ${data['message'] ?? 'No message'}');
    } else {
      print('   ❌ Email verification failed with status ${response.statusCode}');
      print('   📝 Response: ${responseBody.length > 200 ? '${responseBody.substring(0, 200)}...' : responseBody}');
    }
    
    client.close();
  } catch (e) {
    print('   ❌ Email verification test error: $e');
  }
}

Future<void> testPasswordReset() async {
  print('\n📍 Test 7: Password Reset');
  
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('http://localhost:5001/api/auth/forgot-password'));
    
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    
    final body = jsonEncode({
      'email': 'test@example.com',
    });
    request.write(body);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('   Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      print('   ✅ Password reset endpoint accessible!');
      print('   📝 Response: ${data['message'] ?? 'No message'}');
    } else {
      print('   ❌ Password reset failed with status ${response.statusCode}');
      print('   📝 Response: ${responseBody.length > 200 ? '${responseBody.substring(0, 200)}...' : responseBody}');
    }
    
    client.close();
  } catch (e) {
    print('   ❌ Password reset test error: $e');
  }
}