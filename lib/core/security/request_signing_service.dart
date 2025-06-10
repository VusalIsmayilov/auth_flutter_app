import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';

/// Request signing service for API gateway protection
/// Implements HMAC-SHA256 request signing for enhanced security
class RequestSigningService {
  final String _apiKey;
  final String _secretKey;
  final Logger _logger;
  final bool _enableSigning;

  RequestSigningService({
    required String apiKey,
    required String secretKey,
    Logger? logger,
    bool enableSigning = true,
  }) : _apiKey = apiKey,
       _secretKey = secretKey,
       _logger = logger ?? Logger(),
       _enableSigning = enableSigning;

  /// Create a Dio interceptor for request signing
  Interceptor createInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        if (_enableSigning) {
          await _signRequest(options);
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.response?.statusCode == 401 || error.response?.statusCode == 403) {
          _logger.w('Request signing may have failed: ${error.response?.statusCode}');
        }
        handler.next(error);
      },
    );
  }

  /// Sign an HTTP request with HMAC-SHA256
  Future<void> _signRequest(RequestOptions options) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final nonce = _generateNonce();
      
      // Create the string to sign
      final stringToSign = _createStringToSign(
        method: options.method,
        path: options.path,
        queryParameters: options.queryParameters,
        headers: options.headers,
        body: options.data,
        timestamp: timestamp,
        nonce: nonce,
      );

      // Generate HMAC signature
      final signature = _generateSignature(stringToSign);

      // Add signing headers
      options.headers.addAll({
        'X-API-Key': _apiKey,
        'X-Timestamp': timestamp,
        'X-Nonce': nonce,
        'X-Signature': signature,
        'X-Signature-Version': '1.0',
      });

      _logger.d('Request signed successfully for ${options.method} ${options.path}');
    } catch (e) {
      _logger.e('Failed to sign request: $e');
      rethrow;
    }
  }

  /// Create the canonical string to sign
  String _createStringToSign({
    required String method,
    required String path,
    required Map<String, dynamic> queryParameters,
    required Map<String, dynamic> headers,
    required dynamic body,
    required String timestamp,
    required String nonce,
  }) {
    final buffer = StringBuffer();

    // HTTP Method
    buffer.write(method.toUpperCase());
    buffer.write('\n');

    // Canonical URI
    buffer.write(_canonicalizeUri(path));
    buffer.write('\n');

    // Canonical Query String
    buffer.write(_canonicalizeQueryString(queryParameters));
    buffer.write('\n');

    // Canonical Headers (only specific headers)
    buffer.write(_canonicalizeHeaders(headers));
    buffer.write('\n');

    // Request Body Hash
    buffer.write(_hashBody(body));
    buffer.write('\n');

    // Timestamp
    buffer.write(timestamp);
    buffer.write('\n');

    // Nonce
    buffer.write(nonce);

    return buffer.toString();
  }

  /// Canonicalize URI path
  String _canonicalizeUri(String path) {
    // Remove query parameters and ensure proper encoding
    final uri = Uri.parse(path);
    return uri.path.isEmpty ? '/' : uri.path;
  }

  /// Canonicalize query string
  String _canonicalizeQueryString(Map<String, dynamic> queryParameters) {
    if (queryParameters.isEmpty) return '';

    final sortedParams = <String>[];
    final sortedKeys = queryParameters.keys.toList()..sort();

    for (final key in sortedKeys) {
      final value = queryParameters[key];
      if (value != null) {
        final encodedKey = Uri.encodeComponent(key);
        final encodedValue = Uri.encodeComponent(value.toString());
        sortedParams.add('$encodedKey=$encodedValue');
      }
    }

    return sortedParams.join('&');
  }

  /// Canonicalize headers for signing
  String _canonicalizeHeaders(Map<String, dynamic> headers) {
    final canonicalHeaders = <String, String>{};
    
    // Only include specific headers in signing
    const headersToSign = [
      'content-type',
      'content-length',
      'host',
      'authorization',
    ];

    for (final entry in headers.entries) {
      final key = entry.key.toLowerCase();
      if (headersToSign.contains(key)) {
        canonicalHeaders[key] = entry.value.toString().trim();
      }
    }

    final sortedKeys = canonicalHeaders.keys.toList()..sort();
    final headerPairs = <String>[];

    for (final key in sortedKeys) {
      headerPairs.add('$key:${canonicalHeaders[key]}');
    }

    return headerPairs.join('\n');
  }

  /// Hash request body
  String _hashBody(dynamic body) {
    if (body == null) return _hashString('');

    String bodyString;
    if (body is String) {
      bodyString = body;
    } else if (body is Map || body is List) {
      bodyString = jsonEncode(body);
    } else {
      bodyString = body.toString();
    }

    return _hashString(bodyString);
  }

  /// Generate HMAC-SHA256 signature
  String _generateSignature(String stringToSign) {
    final keyBytes = utf8.encode(_secretKey);
    final messageBytes = utf8.encode(stringToSign);
    final hmac = Hmac(sha256, keyBytes);
    final digest = hmac.convert(messageBytes);
    return base64.encode(digest.bytes);
  }

  /// Generate SHA-256 hash of string
  String _hashString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Generate a cryptographically secure nonce
  String _generateNonce({int length = 16}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final random = Random.secure();
    final buffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }

    return buffer.toString();
  }

  /// Verify a request signature (for testing purposes)
  @visibleForTesting
  bool verifySignature({
    required String method,
    required String path,
    required Map<String, dynamic> queryParameters,
    required Map<String, dynamic> headers,
    required dynamic body,
    required String timestamp,
    required String nonce,
    required String signature,
  }) {
    try {
      final stringToSign = _createStringToSign(
        method: method,
        path: path,
        queryParameters: queryParameters,
        headers: headers,
        body: body,
        timestamp: timestamp,
        nonce: nonce,
      );

      final expectedSignature = _generateSignature(stringToSign);
      return signature == expectedSignature;
    } catch (e) {
      _logger.e('Failed to verify signature: $e');
      return false;
    }
  }
}

/// Request signing configuration
class RequestSigningConfig {
  final String apiKey;
  final String secretKey;
  final bool enableSigning;
  final Duration timestampTolerance;
  final List<String> excludedPaths;

  const RequestSigningConfig({
    required this.apiKey,
    required this.secretKey,
    this.enableSigning = true,
    this.timestampTolerance = const Duration(minutes: 5),
    this.excludedPaths = const [],
  });

  factory RequestSigningConfig.fromEnvironment({
    required String environment,
    String? customApiKey,
    String? customSecretKey,
  }) {
    switch (environment.toLowerCase()) {
      case 'production':
        return RequestSigningConfig(
          apiKey: customApiKey ?? 'prod-api-key-placeholder',
          secretKey: customSecretKey ?? 'prod-secret-key-placeholder',
          enableSigning: true,
          timestampTolerance: const Duration(minutes: 2),
        );
      case 'staging':
        return RequestSigningConfig(
          apiKey: customApiKey ?? 'staging-api-key-placeholder',
          secretKey: customSecretKey ?? 'staging-secret-key-placeholder',
          enableSigning: true,
          timestampTolerance: const Duration(minutes: 5),
        );
      case 'development':
      case 'debug':
        return RequestSigningConfig(
          apiKey: customApiKey ?? 'dev-api-key',
          secretKey: customSecretKey ?? 'dev-secret-key',
          enableSigning: false, // Typically disabled in development
          timestampTolerance: const Duration(minutes: 10),
          excludedPaths: ['/health', '/debug'],
        );
      default:
        return RequestSigningConfig(
          apiKey: customApiKey ?? 'default-api-key',
          secretKey: customSecretKey ?? 'default-secret-key',
          enableSigning: false,
        );
    }
  }

  RequestSigningConfig copyWith({
    String? apiKey,
    String? secretKey,
    bool? enableSigning,
    Duration? timestampTolerance,
    List<String>? excludedPaths,
  }) {
    return RequestSigningConfig(
      apiKey: apiKey ?? this.apiKey,
      secretKey: secretKey ?? this.secretKey,
      enableSigning: enableSigning ?? this.enableSigning,
      timestampTolerance: timestampTolerance ?? this.timestampTolerance,
      excludedPaths: excludedPaths ?? this.excludedPaths,
    );
  }
}

/// Exception thrown when request signing fails
class RequestSigningException implements Exception {
  final String message;
  final String? details;

  const RequestSigningException({
    required this.message,
    this.details,
  });

  @override
  String toString() {
    var result = 'RequestSigningException: $message';
    if (details != null) {
      result += '\nDetails: $details';
    }
    return result;
  }
}

/// Utility functions for request signing
class RequestSigningUtils {
  /// Validate API key format
  static bool isValidApiKey(String apiKey) {
    // API key should be at least 16 characters and contain only alphanumeric characters and hyphens
    final regex = RegExp(r'^[a-zA-Z0-9\-]{16,}$');
    return regex.hasMatch(apiKey);
  }

  /// Validate secret key format
  static bool isValidSecretKey(String secretKey) {
    // Secret key should be at least 32 characters
    return secretKey.length >= 32;
  }

  /// Check if timestamp is within tolerance
  static bool isTimestampValid(String timestamp, Duration tolerance) {
    try {
      final requestTime = DateTime.fromMillisecondsSinceEpoch(int.parse(timestamp));
      final now = DateTime.now();
      final difference = now.difference(requestTime).abs();
      return difference <= tolerance;
    } catch (e) {
      return false;
    }
  }

  /// Generate a secure API key
  static String generateApiKey({int length = 32}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-';
    final random = Random.secure();
    final buffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }

    return buffer.toString();
  }

  /// Generate a secure secret key
  static String generateSecretKey({int length = 64}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789+/=';
    final random = Random.secure();
    final buffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      buffer.write(chars[random.nextInt(chars.length)]);
    }

    return buffer.toString();
  }
}