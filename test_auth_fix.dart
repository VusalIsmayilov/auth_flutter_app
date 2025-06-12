import 'dart:convert';
import 'dart:io';

void main() async {
  print('🧪 Testing Authentication Fix');
  print('================================');
  
  // Test 1: Verify HttpClient works (our new implementation)
  await testHttpClient();
  
  // Test 2: Test login with HttpClient
  await testLoginWithHttpClient();
  
  print('\n✅ Authentication fix validation complete!');
}

Future<void> testHttpClient() async {
  print('\n📍 Test 1: Basic HttpClient functionality');
  
  try {
    final client = HttpClient();
    final request = await client.getUrl(Uri.parse('http://192.168.1.156:5001/api/health'));
    request.headers.set('Accept', 'application/json');
    
    final response = await request.close();
    final body = await response.transform(utf8.decoder).join();
    
    print('   Status: ${response.statusCode}');
    print('   Response: ${body.length > 100 ? '${body.substring(0, 100)}...' : body}');
    
    client.close();
    
    if (response.statusCode == 200) {
      print('   ✅ HttpClient works correctly');
    } else {
      print('   ❌ HttpClient failed with status ${response.statusCode}');
    }
  } catch (e) {
    print('   ❌ HttpClient error: $e');
  }
}

Future<void> testLoginWithHttpClient() async {
  print('\n📍 Test 2: Login authentication with HttpClient');
  
  try {
    final client = HttpClient();
    final request = await client.postUrl(Uri.parse('http://192.168.1.156:5001/api/auth/login/email'));
    
    // Set headers exactly as in our implementation
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    request.headers.set('User-Agent', 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1');
    
    // Test credentials
    final body = jsonEncode({
      'email': 'v_ismayilov@yahoo.com',
      'password': 'Vusal135',
    });
    request.write(body);
    
    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();
    
    print('   Status: ${response.statusCode}');
    
    if (response.statusCode == 200) {
      final data = jsonDecode(responseBody);
      print('   ✅ Login successful!');
      print('   📧 User: ${data['user']?['email'] ?? 'Unknown'}');
      print('   🔑 Token received: ${data['tokens']?['accessToken']?.toString().substring(0, 20) ?? 'None'}...');
    } else {
      print('   ❌ Login failed with status ${response.statusCode}');
      print('   📝 Response: ${responseBody.length > 200 ? '${responseBody.substring(0, 200)}...' : responseBody}');
    }
    
    client.close();
  } catch (e) {
    print('   ❌ Login test error: $e');
  }
}