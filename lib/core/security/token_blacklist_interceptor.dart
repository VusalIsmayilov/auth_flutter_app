import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'token_blacklist_service.dart';
import '../../services/jwt_service.dart';

/// Interceptor that validates tokens against the blacklist
/// Automatically handles blacklisted token scenarios
class TokenBlacklistInterceptor extends Interceptor {
  final TokenBlacklistService _blacklistService;
  final JwtService? _jwtService;
  final Logger _logger;

  TokenBlacklistInterceptor({
    required TokenBlacklistService blacklistService,
    JwtService? jwtService,
    Logger? logger,
  }) : _blacklistService = blacklistService,
       _jwtService = jwtService,
       _logger = logger ?? Logger();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    try {
      // Extract token from Authorization header
      final authHeader = options.headers['Authorization'] as String?;
      if (authHeader != null && authHeader.startsWith('Bearer ')) {
        final token = authHeader.substring(7); // Remove 'Bearer ' prefix
        
        // Check if token is blacklisted
        final isBlacklisted = await _blacklistService.isTokenBlacklisted(token);
        if (isBlacklisted) {
          _logger.w('Blocked request with blacklisted token');
          
          // Clear local tokens since they're blacklisted
          await _clearLocalTokens();
          
          // Return 401 Unauthorized error
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response(
                requestOptions: options,
                statusCode: 401,
                statusMessage: 'Token has been revoked',
                data: {
                  'error': 'token_blacklisted',
                  'message': 'The provided token has been revoked and is no longer valid',
                },
              ),
              type: DioExceptionType.badResponse,
            ),
          );
          return;
        }
      }

      handler.next(options);
    } catch (e) {
      _logger.e('Error in token blacklist interceptor: $e');
      // In case of error, allow request to proceed to avoid blocking valid requests
      handler.next(options);
    }
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) async {
    try {
      // Check for server-side token revocation notifications
      if (response.statusCode == 200) {
        final data = response.data;
        if (data is Map<String, dynamic>) {
          // Look for token revocation signals from server
          final tokenRevoked = data['token_revoked'] as bool?;
          final revokedTokens = data['revoked_tokens'] as List<dynamic>?;
          
          if (tokenRevoked == true || revokedTokens != null) {
            await _handleServerTokenRevocation(revokedTokens);
          }
        }
      }

      handler.next(response);
    } catch (e) {
      _logger.e('Error processing response in blacklist interceptor: $e');
      handler.next(response);
    }
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    try {
      // Handle 401 responses that might indicate token revocation
      if (err.response?.statusCode == 401) {
        final data = err.response?.data;
        if (data is Map<String, dynamic>) {
          final error = data['error'] as String?;
          
          if (error == 'token_blacklisted' || error == 'token_revoked') {
            _logger.w('Server reported token revocation: $error');
            
            // Extract and blacklist the token that was rejected
            final authHeader = err.requestOptions.headers['Authorization'] as String?;
            if (authHeader != null && authHeader.startsWith('Bearer ')) {
              final token = authHeader.substring(7);
              await _blacklistService.blacklistToken(
                token,
                reason: TokenBlacklistReason.adminRevocation,
              );
            }
            
            await _clearLocalTokens();
          }
        }
      }

      handler.next(err);
    } catch (e) {
      _logger.e('Error in token blacklist error handler: $e');
      handler.next(err);
    }
  }

  /// Handle server-side token revocation notifications
  Future<void> _handleServerTokenRevocation(List<dynamic>? revokedTokens) async {
    if (revokedTokens == null || revokedTokens.isEmpty) return;

    try {
      for (final tokenData in revokedTokens) {
        if (tokenData is Map<String, dynamic>) {
          final token = tokenData['token'] as String?;
          final reason = tokenData['reason'] as String?;
          final userId = tokenData['user_id'] as String?;
          
          if (token != null) {
            final blacklistReason = _parseBlacklistReason(reason);
            await _blacklistService.blacklistToken(
              token,
              reason: blacklistReason,
              userId: userId,
            );
            
            _logger.i('Blacklisted token from server notification: ${blacklistReason.name}');
          }
        }
      }
    } catch (e) {
      _logger.e('Failed to handle server token revocation: $e');
    }
  }

  /// Parse blacklist reason from server response
  TokenBlacklistReason _parseBlacklistReason(String? reason) {
    if (reason == null) return TokenBlacklistReason.adminRevocation;
    
    switch (reason.toLowerCase()) {
      case 'logout':
        return TokenBlacklistReason.logout;
      case 'security_breach':
        return TokenBlacklistReason.securityBreach;
      case 'suspicious_activity':
        return TokenBlacklistReason.suspiciousActivity;
      case 'device_lost':
        return TokenBlacklistReason.deviceLost;
      case 'password_change':
        return TokenBlacklistReason.passwordChange;
      case 'account_deactivation':
        return TokenBlacklistReason.accountDeactivation;
      default:
        return TokenBlacklistReason.adminRevocation;
    }
  }

  /// Clear local tokens when they're found to be blacklisted
  Future<void> _clearLocalTokens() async {
    if (_jwtService != null) {
      try {
        await _jwtService!.clearTokens();
        _logger.d('Cleared local tokens due to blacklisting');
      } catch (e) {
        _logger.e('Failed to clear local tokens: $e');
      }
    }
  }
}

/// Enhanced logout service that integrates with token blacklisting
class SecureLogoutService {
  final TokenBlacklistService _blacklistService;
  final JwtService _jwtService;
  final Logger _logger;

  SecureLogoutService({
    required TokenBlacklistService blacklistService,
    required JwtService jwtService,
    Logger? logger,
  }) : _blacklistService = blacklistService,
       _jwtService = jwtService,
       _logger = logger ?? Logger();

  /// Perform secure logout with token blacklisting
  Future<void> secureLogout({
    TokenBlacklistReason reason = TokenBlacklistReason.logout,
    bool blacklistRefreshToken = true,
  }) async {
    try {
      // Get current tokens before clearing them
      final accessToken = await _jwtService.getAccessToken();
      final refreshToken = await _jwtService.getRefreshToken();

      // Blacklist the access token
      if (accessToken != null) {
        await _blacklistService.blacklistToken(
          accessToken,
          reason: reason,
          expiresAt: _jwtService.getTokenExpiration(accessToken),
        );
        _logger.d('Access token blacklisted');
      }

      // Blacklist the refresh token if requested
      if (blacklistRefreshToken && refreshToken != null) {
        await _blacklistService.blacklistToken(
          refreshToken,
          reason: reason,
          expiresAt: _jwtService.getTokenExpiration(refreshToken),
        );
        _logger.d('Refresh token blacklisted');
      }

      // Clear local tokens
      await _jwtService.clearTokens();

      _logger.i('Secure logout completed: ${reason.displayName}');
    } catch (e) {
      _logger.e('Failed to perform secure logout: $e');
      
      // Even if blacklisting fails, clear local tokens
      try {
        await _jwtService.clearTokens();
      } catch (clearError) {
        _logger.e('Failed to clear local tokens during error recovery: $clearError');
      }
      
      rethrow;
    }
  }

  /// Logout from all devices by blacklisting all user tokens
  Future<void> logoutFromAllDevices({
    required String userId,
    TokenBlacklistReason reason = TokenBlacklistReason.securityBreach,
  }) async {
    try {
      // Blacklist all tokens for the user
      await _blacklistService.blacklistAllUserTokens(userId, reason: reason);
      
      // Clear local tokens
      await _jwtService.clearTokens();
      
      _logger.i('Logged out from all devices for user: $userId (${reason.displayName})');
    } catch (e) {
      _logger.e('Failed to logout from all devices: $e');
      rethrow;
    }
  }

  /// Emergency logout (for security incidents)
  Future<void> emergencyLogout({
    required String userId,
  }) async {
    await logoutFromAllDevices(
      userId: userId,
      reason: TokenBlacklistReason.securityBreach,
    );
  }
}

/// Utility class for token blacklist management
class TokenBlacklistUtils {
  /// Check if a logout reason requires immediate action
  static bool requiresImmediateAction(TokenBlacklistReason reason) {
    return reason.isHighSeverity;
  }

  /// Get recommended cleanup interval based on environment
  static Duration getCleanupInterval({bool isProduction = false}) {
    return isProduction 
      ? const Duration(hours: 6)  // More frequent in production
      : const Duration(hours: 24); // Less frequent in development
  }

  /// Calculate token blacklist duration based on original expiry
  static DateTime? calculateBlacklistExpiry(DateTime? originalExpiry) {
    if (originalExpiry == null) return null;
    
    // Keep blacklisted for some time after original expiry for security
    return originalExpiry.add(const Duration(days: 1));
  }

  /// Validate token format before blacklisting
  static bool isValidTokenFormat(String token) {
    // Basic JWT format validation (3 parts separated by dots)
    final parts = token.split('.');
    return parts.length == 3 && parts.every((part) => part.isNotEmpty);
  }
}