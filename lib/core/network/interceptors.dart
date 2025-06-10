import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../errors/exceptions.dart';
import '../../services/jwt_service.dart';

class AuthInterceptor extends Interceptor {
  final JwtService _jwtService;
  final Logger _logger;

  AuthInterceptor({
    required JwtService jwtService,
    Logger? logger,
  })  : _jwtService = jwtService,
        _logger = logger ?? Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Skip authentication for auth endpoints
      if (_isAuthEndpoint(options.path)) {
        handler.next(options);
        return;
      }

      // Get valid access token (auto-refreshes if needed)
      final accessToken = await _jwtService.getValidAccessToken();
      
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
        _logger.d('Added Bearer token to request: ${options.path}');
      } else {
        _logger.w('No valid access token available for: ${options.path}');
      }

      handler.next(options);
    } catch (e) {
      _logger.e('Error in auth interceptor: $e');
      handler.reject(
        DioException(
          requestOptions: options,
          type: DioExceptionType.unknown,
          error: e,
        ),
      );
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      _logger.w('Received 401 response, token may be invalid');
      
      // For non-auth endpoints, try to refresh token and retry
      if (!_isAuthEndpoint(err.requestOptions.path)) {
        try {
          final newToken = await _jwtService.getValidAccessToken();
          
          if (newToken != null) {
            // Update the failed request with new token and retry
            final retryOptions = err.requestOptions.copyWith();
            retryOptions.headers['Authorization'] = 'Bearer $newToken';
            
            _logger.d('Retrying request with refreshed token');
            
            final dio = Dio();
            final response = await dio.fetch(retryOptions);
            return handler.resolve(response);
          }
        } catch (e) {
          _logger.e('Token refresh failed during retry: $e');
        }
      }
    }

    handler.next(err);
  }

  bool _isAuthEndpoint(String path) {
    const authPaths = [
      '/auth/login',
      '/auth/register',
      '/auth/refresh',
      '/auth/forgot-password',
      '/auth/reset-password',
      '/auth/verify-email',
      '/auth/resend-verification',
    ];
    
    return authPaths.any((authPath) => path.contains(authPath));
  }
}

class LoggingInterceptor extends Interceptor {
  final Logger _logger;

  LoggingInterceptor({Logger? logger}) : _logger = logger ?? Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    _logger.d('REQUEST[${options.method}] => PATH: ${options.path}');
    _logger.d('Headers: ${options.headers}');
    if (options.data != null) {
      _logger.d('Data: ${options.data}');
    }
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    _logger.d('RESPONSE[${response.statusCode}] => PATH: ${response.requestOptions.path}');
    _logger.d('Data: ${response.data}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    _logger.e('ERROR[${err.response?.statusCode}] => PATH: ${err.requestOptions.path}');
    _logger.e('Message: ${err.message}');
    if (err.response?.data != null) {
      _logger.e('Error Data: ${err.response?.data}');
    }
    handler.next(err);
  }
}

class SecurityHeadersInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Add security headers
    options.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'X-Requested-With': 'XMLHttpRequest',
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      'Pragma': 'no-cache',
      'Expires': '0',
    });

    handler.next(options);
  }
}

class ErrorHandlingInterceptor extends Interceptor {
  final Logger _logger;

  ErrorHandlingInterceptor({Logger? logger}) : _logger = logger ?? Logger();

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    AppException appException;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        appException = NetworkException(
          message: 'Connection timeout. Please check your internet connection.',
          code: 'TIMEOUT',
        );
        break;
      
      case DioExceptionType.connectionError:
        appException = NetworkException(
          message: 'No internet connection. Please check your network.',
          code: 'NO_CONNECTION',
        );
        break;
      
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        final responseData = err.response?.data;
        
        switch (statusCode) {
          case 400:
            appException = ValidationException(
              message: responseData?['message'] ?? 'Invalid request data',
              code: 'VALIDATION_ERROR',
            );
            break;
          case 401:
            appException = AuthenticationException(
              message: responseData?['message'] ?? 'Authentication failed',
              code: 'UNAUTHORIZED',
              statusCode: 401,
            );
            break;
          case 403:
            appException = PermissionException(
              message: responseData?['message'] ?? 'Access denied',
              code: 'FORBIDDEN',
            );
            break;
          case 404:
            appException = ServerException(
              message: responseData?['message'] ?? 'Resource not found',
              code: 'NOT_FOUND',
              statusCode: 404,
            );
            break;
          case 422:
            appException = ValidationException(
              message: responseData?['message'] ?? 'Validation failed',
              fieldErrors: responseData?['errors'] as Map<String, List<String>>?,
              code: 'VALIDATION_ERROR',
            );
            break;
          case 500:
          default:
            appException = ServerException(
              message: responseData?['message'] ?? 'Internal server error',
              code: 'SERVER_ERROR',
              statusCode: statusCode,
            );
            break;
        }
        break;
      
      case DioExceptionType.cancel:
        appException = NetworkException(
          message: 'Request was cancelled',
          code: 'CANCELLED',
        );
        break;
      
      case DioExceptionType.unknown:
      default:
        appException = ServerException(
          message: 'An unexpected error occurred',
          code: 'UNKNOWN',
        );
        break;
    }

    _logger.e('API Error: ${appException.message}');
    
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: appException,
      ),
    );
  }
}