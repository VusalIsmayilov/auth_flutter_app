import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../constants/api_endpoints.dart';

class HttpClientService {
  static final Logger _logger = Logger();
  
  static void dispose() {
    _logger.d('HttpClient instance disposed');
  }
  
  static Future<HttpResponse> post(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    String? baseUrl,
  }) async {
    final url = '${baseUrl ?? ApiEndpoints.baseUrl}$path';
    final uri = Uri.parse(url);
    
    try {
      // Set default headers
      final defaultHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
      };
      
      // Add custom headers
      if (headers != null) {
        defaultHeaders.addAll(headers);
      }
      
      // Prepare body
      String? body;
      if (data != null) {
        body = jsonEncode(data);
        _logger.d('POST $url - Body: $body');
      }
      
      _logger.d('POST $url - Headers: $defaultHeaders');
      
      final response = await http.post(
        uri,
        headers: defaultHeaders,
        body: body,
      ).timeout(const Duration(seconds: 30));
      
      _logger.d('POST $url - Status: ${response.statusCode}');
      _logger.d('POST $url - Response: ${response.body}');
      
      dynamic responseData;
      if (response.body.isNotEmpty) {
        try {
          responseData = jsonDecode(response.body);
        } catch (e) {
          _logger.e('JSON decode error: $e, responseBody: ${response.body}');
          responseData = null;
        }
      }
      
      return HttpResponse(
        statusCode: response.statusCode,
        data: responseData,
        headers: response.headers,
      );
      
    } catch (e) {
      _logger.e('POST $url - Error: $e');
      rethrow;
    }
  }
  
  static Future<HttpResponse> put(
    String path, {
    Map<String, dynamic>? data,
    Map<String, String>? headers,
    String? baseUrl,
  }) async {
    final url = '${baseUrl ?? ApiEndpoints.baseUrl}$path';
    final uri = Uri.parse(url);
    
    try {
      // Set default headers
      final defaultHeaders = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
      };
      
      // Add custom headers
      if (headers != null) {
        defaultHeaders.addAll(headers);
      }
      
      // Prepare body
      String? body;
      if (data != null) {
        body = jsonEncode(data);
        _logger.d('PUT $url - Body: $body');
      }
      
      _logger.d('PUT $url - Headers: $defaultHeaders');
      
      final response = await http.put(
        uri,
        headers: defaultHeaders,
        body: body,
      ).timeout(const Duration(seconds: 30));
      
      _logger.d('PUT $url - Status: ${response.statusCode}');
      _logger.d('PUT $url - Response: ${response.body}');
      
      dynamic responseData;
      if (response.body.isNotEmpty) {
        try {
          responseData = jsonDecode(response.body);
        } catch (e) {
          _logger.e('JSON decode error: $e, responseBody: ${response.body}');
          responseData = null;
        }
      }
      
      return HttpResponse(
        statusCode: response.statusCode,
        data: responseData,
        headers: response.headers,
      );
      
    } catch (e) {
      _logger.e('PUT $url - Error: $e');
      rethrow;
    }
  }
  
  static Future<HttpResponse> get(
    String path, {
    Map<String, String>? queryParameters,
    Map<String, String>? headers,
    String? baseUrl,
  }) async {
    final url = '${baseUrl ?? ApiEndpoints.baseUrl}$path';
    var uri = Uri.parse(url);
    
    if (queryParameters != null) {
      uri = uri.replace(queryParameters: queryParameters);
    }
    
    try {
      // Set default headers
      final defaultHeaders = {
        'Accept': 'application/json',
        'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
      };
      
      // Add custom headers
      if (headers != null) {
        defaultHeaders.addAll(headers);
      }
      
      _logger.d('GET $uri - Headers: $defaultHeaders');
      
      final response = await http.get(
        uri,
        headers: defaultHeaders,
      ).timeout(const Duration(seconds: 30));
      
      _logger.d('GET $uri - Status: ${response.statusCode}');
      _logger.d('GET $uri - Response: ${response.body}');
      
      dynamic responseData;
      if (response.body.isNotEmpty) {
        try {
          responseData = jsonDecode(response.body);
        } catch (e) {
          _logger.e('JSON decode error: $e, responseBody: ${response.body}');
          responseData = null;
        }
      }
      
      return HttpResponse(
        statusCode: response.statusCode,
        data: responseData,
        headers: response.headers,
      );
      
    } catch (e) {
      _logger.e('GET $uri - Error: $e');
      rethrow;
    }
  }
}

class HttpResponse {
  final int statusCode;
  final dynamic data;
  final Map<String, String> headers;
  
  const HttpResponse({
    required this.statusCode,
    required this.data,
    required this.headers,
  });
  
  bool get isSuccess => statusCode >= 200 && statusCode < 300;
}

class HttpException implements Exception {
  final String message;
  final int statusCode;
  final dynamic data;
  
  const HttpException({
    required this.message,
    required this.statusCode,
    this.data,
  });
  
  @override
  String toString() => 'HttpException: $message (Status: $statusCode)';
}