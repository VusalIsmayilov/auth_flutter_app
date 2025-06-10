import 'package:flutter/foundation.dart';
import 'environment_config.dart';

/// Production-specific security configurations
class ProductionConfig {
  /// Security configurations for production
  static const Map<String, dynamic> securityConfig = {
    // Certificate pinning configurations
    'certificate_pinning': {
      'enabled': true,
      'pins': {
        'api.yourdomain.com': [
          // Production API server certificates (replace with actual)
          'sha256:YourActualCertificateFingerprint1==',
          'sha256:YourActualCertificateFingerprint2==', // Backup certificate
        ],
        'auth.yourdomain.com': [
          // Auth server certificates (if separate)
          'sha256:YourActualAuthCertificateFingerprint==',
        ],
      },
    },
    
    // Network security
    'network': {
      'enforce_https': true,
      'min_tls_version': '1.2',
      'timeout_seconds': 30,
      'max_retries': 3,
      'enable_request_signing': true,
    },
    
    // Authentication security
    'authentication': {
      'max_login_attempts': 3,
      'lockout_duration_minutes': 15,
      'session_timeout_minutes': 30,
      'token_refresh_threshold_minutes': 5,
      'enable_biometric_fallback': true,
      'require_device_registration': true,
    },
    
    // Logging and monitoring
    'monitoring': {
      'enable_crash_reporting': true,
      'enable_performance_monitoring': true,
      'enable_analytics': true,
      'log_level': 'ERROR', // Only errors in production
      'enable_debug_logs': false,
    },
    
    // Storage security
    'storage': {
      'encrypt_local_data': true,
      'secure_keychain_access': true,
      'auto_clear_cache_hours': 24,
      'sensitive_data_retention_hours': 1,
    },
  };

  /// Get certificate pins for production
  static Map<String, List<String>> get certificatePins {
    final pins = securityConfig['certificate_pinning']['pins'] as Map<String, dynamic>;
    return pins.map((key, value) => MapEntry(key, List<String>.from(value)));
  }

  /// Check if certificate pinning is enabled
  static bool get isCertificatePinningEnabled {
    return securityConfig['certificate_pinning']['enabled'] as bool;
  }

  /// Get network timeout
  static Duration get networkTimeout {
    final seconds = securityConfig['network']['timeout_seconds'] as int;
    return Duration(seconds: seconds);
  }

  /// Get maximum login attempts
  static int get maxLoginAttempts {
    return securityConfig['authentication']['max_login_attempts'] as int;
  }

  /// Get session timeout
  static Duration get sessionTimeout {
    final minutes = securityConfig['authentication']['session_timeout_minutes'] as int;
    return Duration(minutes: minutes);
  }

  /// Get token refresh threshold
  static Duration get tokenRefreshThreshold {
    final minutes = securityConfig['authentication']['token_refresh_threshold_minutes'] as int;
    return Duration(minutes: minutes);
  }

  /// Check if crash reporting is enabled
  static bool get isCrashReportingEnabled {
    return securityConfig['monitoring']['enable_crash_reporting'] as bool;
  }

  /// Check if analytics is enabled
  static bool get isAnalyticsEnabled {
    return securityConfig['monitoring']['enable_analytics'] as bool;
  }

  /// Get log level for production
  static String get logLevel {
    return securityConfig['monitoring']['log_level'] as String;
  }

  /// Check if debug logs are enabled
  static bool get isDebugLogsEnabled {
    return securityConfig['monitoring']['enable_debug_logs'] as bool;
  }

  /// Production API endpoints
  static const Map<String, String> apiEndpoints = {
    'base_url': 'https://api.yourdomain.com',
    'auth_url': 'https://auth.yourdomain.com',
    'websocket_url': 'wss://ws.yourdomain.com',
    'cdn_url': 'https://cdn.yourdomain.com',
  };

  /// API rate limiting configuration
  static const Map<String, int> rateLimits = {
    'login_attempts_per_minute': 5,
    'api_requests_per_minute': 100,
    'password_reset_per_hour': 3,
    'registration_attempts_per_day': 5,
  };

  /// Security headers for production
  static const Map<String, String> securityHeaders = {
    'X-Content-Type-Options': 'nosniff',
    'X-Frame-Options': 'DENY',
    'X-XSS-Protection': '1; mode=block',
    'Strict-Transport-Security': 'max-age=31536000; includeSubDomains',
    'Referrer-Policy': 'strict-origin-when-cross-origin',
    'Permissions-Policy': 'geolocation=(), microphone=(), camera=()',
  };

  /// Validate production configuration
  static bool validateConfig() {
    try {
      // Validate certificate pins
      final pins = certificatePins;
      if (pins.isEmpty) {
        if (kDebugMode) print('Warning: No certificate pins configured for production');
        return false;
      }

      // Validate API endpoints
      for (final endpoint in apiEndpoints.values) {
        if (!endpoint.startsWith('https://')) {
          if (kDebugMode) print('Error: Non-HTTPS endpoint in production: $endpoint');
          return false;
        }
      }

      // Validate timeouts
      if (networkTimeout.inSeconds < 10 || networkTimeout.inSeconds > 60) {
        if (kDebugMode) print('Warning: Network timeout outside recommended range');
      }

      // Validate security settings
      if (maxLoginAttempts > 5) {
        if (kDebugMode) print('Warning: Max login attempts higher than recommended');
      }

      if (sessionTimeout.inMinutes > 60) {
        if (kDebugMode) print('Warning: Session timeout longer than recommended');
      }

      return true;
    } catch (e) {
      if (kDebugMode) print('Error validating production config: $e');
      return false;
    }
  }

  /// Initialize production configuration
  static void initialize() {
    if (!validateConfig()) {
      throw Exception('Invalid production configuration detected');
    }

    if (kDebugMode) {
      print('Production configuration initialized');
      print('Certificate pinning: $isCertificatePinningEnabled');
      print('API base URL: ${apiEndpoints['base_url']}');
      print('Max login attempts: $maxLoginAttempts');
      print('Session timeout: ${sessionTimeout.inMinutes} minutes');
    }
  }

  /// Get environment-specific configuration
  static EnvironmentConfig getEnvironmentConfig() {
    return EnvironmentConfig(
      environment: Environment.production,
      baseUrl: apiEndpoints['base_url']!,
      enableLogging: isDebugLogsEnabled,
      enableCertificatePinning: isCertificatePinningEnabled,
      enableAnalytics: isAnalyticsEnabled,
      certificatePins: certificatePins,
      connectTimeout: networkTimeout,
      receiveTimeout: networkTimeout,
      sendTimeout: networkTimeout,
    );
  }
}

/// Development overrides for testing production features
class DevelopmentOverrides {
  /// Override certificate pinning for development
  static const bool disableCertificatePinning = true;

  /// Override API endpoints for local development
  static const Map<String, String> devApiEndpoints = {
    'base_url': 'http://localhost:8080',
    'auth_url': 'http://localhost:8080',
    'websocket_url': 'ws://localhost:8080',
  };

  /// Relaxed security for development
  static const Map<String, dynamic> devSecurityConfig = {
    'max_login_attempts': 10,
    'session_timeout_minutes': 120,
    'enable_debug_logs': true,
    'log_level': 'DEBUG',
  };

  /// Get development environment config
  static EnvironmentConfig getDevelopmentConfig() {
    return EnvironmentConfig(
      environment: Environment.development,
      baseUrl: devApiEndpoints['base_url']!,
      enableLogging: true,
      enableCertificatePinning: false,
      enableAnalytics: false,
      certificatePins: const {},
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
    );
  }
}