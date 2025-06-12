import 'dart:convert';
import 'dart:io';

void main() async {
  print('=== Minimal HTTP Client Test in Flutter Environment ===');
  
  const baseUrl = 'http://192.168.1.156:5001';
  const email = 'v_ismayilov@yahoo.com';
  const password = 'Vusal135';
  
  try {
    // Create the most basic HTTP client possible
    final client = HttpClient();
    
    // Create request
    final request = await client.postUrl(Uri.parse('$baseUrl/api/auth/login/email'));
    
    // Set headers exactly as in successful tests
    request.headers.set('Content-Type', 'application/json');
    request.headers.set('Accept', 'application/json');
    request.headers.set('User-Agent', 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1');
    
    // Set body
    final body = jsonEncode({
      'email': email,
      'password': password,
    });
    request.write(body);
    
    print('Making request to: $baseUrl/api/auth/login/email');
    print('Headers: ${request.headers}');
    print('Body: $body');
    
    // Send request
    final response = await request.close();
    
    print('Status Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    
    // Read response
    final responseBody = await response.transform(utf8.decoder).join();
    print('Response Body: $responseBody');
    
    client.close();
    
  } catch (e) {
    print('Error: $e');
  }
}