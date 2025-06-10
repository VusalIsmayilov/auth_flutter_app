import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';
import '../core/errors/exceptions.dart';
import '../data/datasources/local/secure_storage_service.dart';
import '../domain/repositories/auth_repository.dart';

class JwtService {
  final AuthRepository _authRepository;
  final SecureStorageService _storageService;
  final Logger _logger;

  Timer? _refreshTimer;
  bool _isRefreshing = false;
  final List<Completer<String?>> _pendingRequests = [];

  JwtService({
    required AuthRepository authRepository,
    required SecureStorageService storageService,
    Logger? logger,
  }) : _authRepository = authRepository,
       _storageService = storageService,
       _logger = logger ?? Logger();

  Future<void> startTokenRefreshTimer() async {
    await _cancelRefreshTimer();

    final token = await _storageService.getToken();
    if (token == null || token.isExpired) {
      _logger.w('No valid token found for refresh timer');
      return;
    }

    final refreshDuration = _calculateRefreshDuration(token.expiresAt);
    _logger.d(
      'Setting token refresh timer for ${refreshDuration.inMinutes} minutes',
    );

    _refreshTimer = Timer(refreshDuration, () async {
      await _performTokenRefresh();
    });
  }

  Duration _calculateRefreshDuration(DateTime expiresAt) {
    final now = DateTime.now();
    final timeUntilExpiry = expiresAt.difference(now);

    // Refresh 5 minutes before expiry, or immediately if less than 5 minutes left
    final refreshBuffer = const Duration(minutes: 5);
    final refreshTime = timeUntilExpiry - refreshBuffer;

    return refreshTime.isNegative ? Duration.zero : refreshTime;
  }

  Future<String?> getValidAccessToken() async {
    final token = await _storageService.getToken();

    if (token == null) {
      _logger.w('No token found in storage');
      return null;
    }

    if (!token.isExpired) {
      return token.accessToken;
    }

    // Token is expired, attempt refresh
    if (token.isExpiringSoon || token.isExpired) {
      return await _refreshTokenIfNeeded();
    }

    return token.accessToken;
  }

  Future<String?> _refreshTokenIfNeeded() async {
    // If already refreshing, wait for the current refresh to complete
    if (_isRefreshing) {
      final completer = Completer<String?>();
      _pendingRequests.add(completer);
      return await completer.future;
    }

    _isRefreshing = true;

    try {
      _logger.d('Refreshing access token');
      final newToken = await _authRepository.refreshToken();

      // Complete all pending requests with the new token
      for (final completer in _pendingRequests) {
        completer.complete(newToken.accessToken);
      }
      _pendingRequests.clear();

      // Restart the refresh timer with the new expiry time
      await startTokenRefreshTimer();

      _logger.d('Token refreshed successfully');
      return newToken.accessToken;
    } catch (e) {
      _logger.e('Token refresh failed: $e');

      // Complete all pending requests with null
      for (final completer in _pendingRequests) {
        completer.complete(null);
      }
      _pendingRequests.clear();

      // Clear stored tokens on refresh failure
      await _storageService.clearTokens();

      if (e is AuthenticationException) {
        throw TokenExpiredException();
      }

      return null;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<void> _performTokenRefresh() async {
    try {
      await _refreshTokenIfNeeded();
    } catch (e) {
      _logger.e('Scheduled token refresh failed: $e');
    }
  }

  Map<String, dynamic>? parseJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) {
        _logger.w('Invalid JWT format');
        return null;
      }

      final payload = parts[1];
      final normalizedPayload = base64Url.normalize(payload);
      final decodedPayload = utf8.decode(base64Url.decode(normalizedPayload));

      return jsonDecode(decodedPayload) as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Failed to parse JWT payload: $e');
      return null;
    }
  }

  DateTime? getTokenExpiryTime(String token) {
    final payload = parseJwtPayload(token);
    if (payload == null) return null;

    final exp = payload['exp'] as int?;
    if (exp == null) return null;

    return DateTime.fromMillisecondsSinceEpoch(exp * 1000);
  }

  bool isTokenExpired(String token) {
    final expiryTime = getTokenExpiryTime(token);
    if (expiryTime == null) return true;

    return DateTime.now().isAfter(expiryTime);
  }

  List<String>? getTokenRoles(String token) {
    final payload = parseJwtPayload(token);
    if (payload == null) return null;

    final roles = payload['roles'] as List<dynamic>?;
    return roles?.map((role) => role.toString()).toList();
  }

  String? getTokenUserId(String token) {
    final payload = parseJwtPayload(token);
    if (payload == null) return null;

    return payload['sub'] as String? ?? payload['user_id'] as String?;
  }

  Future<void> _cancelRefreshTimer() async {
    _refreshTimer?.cancel();
    _refreshTimer = null;
  }

  Future<void> stopTokenRefreshTimer() async {
    await _cancelRefreshTimer();
    _logger.d('Token refresh timer stopped');
  }

  /// Get the current access token (if valid)
  Future<String?> getAccessToken() async {
    final token = await _storageService.getToken();
    return token?.accessToken;
  }

  /// Get the current refresh token
  Future<String?> getRefreshToken() async {
    final token = await _storageService.getToken();
    return token?.refreshToken;
  }

  /// Get token expiration time
  DateTime? getTokenExpiration(String token) {
    return getTokenExpiryTime(token);
  }

  /// Clear all stored tokens
  Future<void> clearTokens() async {
    await _storageService.clearTokens();
    await stopTokenRefreshTimer();
    _logger.d('All tokens cleared');
  }

  void dispose() {
    stopTokenRefreshTimer();
    _pendingRequests.clear();
  }
}
