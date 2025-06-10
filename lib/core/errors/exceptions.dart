class AppException implements Exception {
  final String message;
  final String? code;
  final int? statusCode;

  AppException({
    required this.message,
    this.code,
    this.statusCode,
  });

  @override
  String toString() {
    return 'AppException: $message ${code != null ? '(Code: $code)' : ''} ${statusCode != null ? '(Status: $statusCode)' : ''}';
  }
}

class ServerException extends AppException {
  ServerException({
    required String message,
    String? code,
    int? statusCode,
  }) : super(message: message, code: code, statusCode: statusCode);
}

class NetworkException extends AppException {
  NetworkException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class CacheException extends AppException {
  CacheException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class AuthenticationException extends AppException {
  AuthenticationException({
    required String message,
    String? code,
    int? statusCode,
  }) : super(message: message, code: code, statusCode: statusCode);
}

class ValidationException extends AppException {
  final Map<String, List<String>>? fieldErrors;

  ValidationException({
    required String message,
    this.fieldErrors,
    String? code,
  }) : super(message: message, code: code);
}

class PermissionException extends AppException {
  PermissionException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}

class TokenExpiredException extends AuthenticationException {
  TokenExpiredException({
    String message = 'Token has expired',
    String? code,
  }) : super(message: message, code: code, statusCode: 401);
}

class BiometricException extends AppException {
  BiometricException({
    required String message,
    String? code,
  }) : super(message: message, code: code);
}