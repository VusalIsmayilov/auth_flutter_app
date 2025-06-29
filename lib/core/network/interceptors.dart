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
        _logger.d('Skipping auth for endpoint: ${options.path}');
        handler.next(options);
        return;
      }

      _logger.d('Adding auth token for protected endpoint: ${options.path}');
      
      // Get valid access token (auto-refreshes if needed)
      final accessToken = await _jwtService.getValidAccessToken();
      
      if (accessToken != null && accessToken.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $accessToken';
        _logger.d('Successfully added Bearer token to request: ${options.path}');
        _logger.d('Token preview: ${accessToken.substring(0, 20)}...');
      } else {
        _logger.w('No valid access token available for: ${options.path}');
        _logger.w('This will likely result in a 401 error');
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
    // Remove any problematic headers that might cause 403 errors
    options.headers.remove('X-Requested-With');
    options.headers.remove('XMLHttpRequest');
    
    // Set headers that match working curl requests exactly
    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    
    // Add User-Agent to match mobile browser (like successful curl test)
    options.headers['User-Agent'] = 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1';

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
              message: responseData?['title'] ?? responseData?['message'] ?? 'Invalid request data',
              fieldErrors: responseData?['errors'] != null 
                ? Map<String, List<String>>.from(
                    (responseData!['errors'] as Map<String, dynamic>).map(
                      (key, value) => MapEntry(
                        key.toLowerCase(), // Convert to lowercase for consistency
                        List<String>.from(value as List)
                      )
                    )
                  )
                : null,
              code: 'VALIDATION_ERROR',
            );
            break;
          case 401:
            String errorMessage = 'Authentication failed';
            if (responseData != null && responseData is Map<String, dynamic>) {
              errorMessage = responseData['message'] ?? errorMessage;
            }
            appException = AuthenticationException(
              message: errorMessage,
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