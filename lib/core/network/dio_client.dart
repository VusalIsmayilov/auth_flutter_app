import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/api_endpoints.dart';
import '../../services/jwt_service.dart';
import 'interceptors.dart';
import 'certificate_pinning.dart';
import '../security/request_signing_service.dart';

class DioClient {
  static Dio? _dio;
  static final Logger _logger = Logger();
  static RequestSigningService? _requestSigningService;

  static Dio createDio({
    JwtService? jwtService,
    String? baseUrl,
    int connectTimeout = 30000,
    int receiveTimeout = 30000,
    int sendTimeout = 30000,
    bool enableCertificatePinning = true,
    RequestSigningService? requestSigningService,
  }) {
    final dio = Dio();

    // Base configuration
    dio.options = BaseOptions(
      baseUrl: baseUrl ?? ApiEndpoints.baseUrl,
      connectTimeout: Duration(milliseconds: connectTimeout),
      receiveTimeout: Duration(milliseconds: receiveTimeout),
      sendTimeout: Duration(milliseconds: sendTimeout),
      responseType: ResponseType.json,
      contentType: Headers.jsonContentType,
    );

    // Configure certificate pinning if available and enabled
    if (enableCertificatePinning && CertificatePinningService.isInitialized) {
      final certificatePinning = CertificatePinningService.instance!;
      dio.httpClientAdapter = certificatePinning.createHttpClientAdapter();
      _logger.d('Certificate pinning enabled for Dio client');
    }

    // Store request signing service for later updates
    if (requestSigningService != null) {
      _requestSigningService = requestSigningService;
      _logger.d('Request signing service configured');
    }

    // TEMPORARY: Remove all interceptors to test if they're causing 403 errors
    // Add only minimal headers directly to options
    dio.options.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1',
    });
    
    // Add logging for debugging only
    if (_isDebugMode()) {
      dio.interceptors.add(LoggingInterceptor(logger: _logger));
    }

    _logger.d('Dio client created with base URL: ${dio.options.baseUrl}');
    return dio;
  }

  static Dio getInstance({
    JwtService? jwtService,
    String? baseUrl,
    bool forceRecreate = false,
    RequestSigningService? requestSigningService,
  }) {
    if (_dio == null || forceRecreate) {
      _dio = createDio(
        jwtService: jwtService,
        baseUrl: baseUrl,
        requestSigningService: requestSigningService,
      );
    }
    return _dio!;
  }

  static void updateJwtService(JwtService jwtService) {
    if (_dio != null) {
      // Remove existing auth interceptor
      _dio!.interceptors.removeWhere((interceptor) => interceptor is AuthInterceptor);
      
      // Add new auth interceptor
      final securityIndex = _dio!.interceptors.indexWhere((i) => i is SecurityHeadersInterceptor);
      final insertIndex = securityIndex >= 0 ? securityIndex + 1 : 0;
      
      _dio!.interceptors.insert(
        insertIndex,
        AuthInterceptor(jwtService: jwtService, logger: _logger),
      );
      
      _logger.d('JWT service updated in Dio client');
    }
  }

  static void updateRequestSigningService(RequestSigningService requestSigningService) {
    if (_dio != null) {
      // Remove existing request signing interceptor
      _dio!.interceptors.removeWhere((interceptor) => 
        interceptor is InterceptorsWrapper && interceptor.toString().contains('RequestSigning'));
      
      // Add new request signing interceptor after certificate pinning
      final certPinningIndex = _dio!.interceptors.indexWhere((i) => 
        i is InterceptorsWrapper && i.toString().contains('CertificatePinning'));
      final insertIndex = certPinningIndex >= 0 ? certPinningIndex + 1 : 0;
      
      _dio!.interceptors.insert(
        insertIndex,
        requestSigningService.createInterceptor(),
      );
      
      _requestSigningService = requestSigningService;
      _logger.d('Request signing service updated in Dio client');
    }
  }

  static void clearInstance() {
    _dio?.close();
    _dio = null;
    _logger.d('Dio client instance cleared');
  }

  static bool _isDebugMode() {
    bool debugMode = false;
    assert(debugMode = true);
    return debugMode;
  }

  // Convenience methods for common HTTP operations
  static Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onReceiveProgress,
  }) {
    return getInstance().get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onReceiveProgress: onReceiveProgress,
    );
  }

  static Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return getInstance().post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  static Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return getInstance().put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }

  static Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) {
    return getInstance().delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  static Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
    ProgressCallback? onSendProgress,
    ProgressCallback? onReceiveProgress,
  }) {
    return getInstance().patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
      onReceiveProgress: onReceiveProgress,
    );
  }
}