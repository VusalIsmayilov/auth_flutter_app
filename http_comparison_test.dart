import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;

void main() async {
  const baseUrl = 'http://192.168.1.156:5001/api';
  const email = 'v_ismayilov@yahoo.com';
  const password = 'Vusal135';
  
  print('=== Testing HTTP Package ===');
  await testWithHttpPackage(baseUrl, email, password);
  
  print('\n=== Testing Dio Package ===');
  await testWithDio(baseUrl, email, password);
}

Future<void> testWithHttpPackage(String baseUrl, String email, String password) async {
  try {
    final uri = Uri.parse('$baseUrl/auth/login/email');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
    };
    final body = jsonEncode({
      'email': email,
      'password': password,
    });
    
    print('HTTP Package - Making request to: $uri');
    print('HTTP Package - Headers: $headers');
    print('HTTP Package - Body: $body');
    
    final response = await http.post(
      uri,
      headers: headers,
      body: body,
    );
    
    print('HTTP Package - Status Code: ${response.statusCode}');
    print('HTTP Package - Response Body: ${response.body}');
  } catch (e) {
    print('HTTP Package - Error: $e');
  }
}

Future<void> testWithDio(String baseUrl, String email, String password) async {
  try {
    final dio = Dio();
    dio.options.baseUrl = baseUrl;
    
    // Add headers
    dio.options.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
    });
    
    final data = {
      'email': email,
      'password': password,
    };
    
    print('Dio - Making request to: ${dio.options.baseUrl}/auth/login/email');
    print('Dio - Headers: ${dio.options.headers}');
    print('Dio - Data: $data');
    
    final response = await dio.post('/auth/login/email', data: data);
    
    print('Dio - Status Code: ${response.statusCode}');
    print('Dio - Response Data: ${response.data}');
  } catch (e) {
    print('Dio - Error: $e');
    if (e is DioException) {
      print('Dio - Status Code: ${e.response?.statusCode}');
      print('Dio - Response Data: ${e.response?.data}');
    }
  }
}