import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import '../constants/api_endpoints.dart';

class HttpClientService {
  static HttpClient? _client;
  static final Logger _logger = Logger();
  
  static HttpClient get instance {
    if (_client == null) {
      _client = HttpClient();
      _client!.connectionTimeout = const Duration(milliseconds: 30000);
      _logger.d('HttpClient instance created');
    }
    return _client!;
  }
  
  static void dispose() {
    _client?.close();
    _client = null;
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
      final request = await instance.postUrl(uri);
      
      // Set default headers
      request.headers.set('Content-Type', 'application/json');
      request.headers.set('Accept', 'application/json');
      request.headers.set('User-Agent', 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1');
      
      // Add custom headers
      if (headers != null) {
        for (final entry in headers.entries) {
          request.headers.set(entry.key, entry.value);
        }
      }
      
      // Add body if provided
      if (data != null) {
        final body = jsonEncode(data);
        request.write(body);
        _logger.d('POST $url - Body: $body');
      }
      
      _logger.d('POST $url - Headers: ${request.headers}');
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      _logger.d('POST $url - Status: ${response.statusCode}');
      _logger.d('POST $url - Response: $responseBody');
      
      dynamic responseData;
      if (responseBody.isNotEmpty) {
        try {
          responseData = jsonDecode(responseBody);
        } catch (e) {
          _logger.e('JSON decode error: $e, responseBody: $responseBody');
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
      final request = await instance.getUrl(uri);
      
      // Set default headers
      request.headers.set('Accept', 'application/json');
      request.headers.set('User-Agent', 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1');
      
      // Add custom headers
      if (headers != null) {
        for (final entry in headers.entries) {
          request.headers.set(entry.key, entry.value);
        }
      }
      
      _logger.d('GET $uri - Headers: ${request.headers}');
      
      final response = await request.close();
      final responseBody = await response.transform(utf8.decoder).join();
      
      _logger.d('GET $uri - Status: ${response.statusCode}');
      _logger.d('GET $uri - Response: $responseBody');
      
      dynamic responseData;
      if (responseBody.isNotEmpty) {
        try {
          responseData = jsonDecode(responseBody);
        } catch (e) {
          _logger.e('JSON decode error: $e, responseBody: $responseBody');
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
  final HttpHeaders headers;
  
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