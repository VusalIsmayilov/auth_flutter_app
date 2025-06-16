import 'package:flutter/foundation.dart';
import '../core/network/certificate_pinning.dart';

/// Environment configuration for the application
enum Environment {
  development,
  staging,
  production,
}

/// Application configuration based on environment
class EnvironmentConfig {
  final Environment environment;
  final String baseUrl;
  final String apiVersion;
  final bool enableLogging;
  final bool enableCertificatePinning;
  final bool enableRequestSigning;
  final bool enableAnalytics;
  final Map<String, List<String>> certificatePins;
  final Duration connectTimeout;
  final Duration receiveTimeout;
  final Duration sendTimeout;

  const EnvironmentConfig({
    required this.environment,
    required this.baseUrl,
    this.apiVersion = 'v1',
    this.enableLogging = true,
    this.enableCertificatePinning = true,
    this.enableRequestSigning = true,
    this.enableAnalytics = true,
    this.certificatePins = const {},
    this.connectTimeout = const Duration(seconds: 30),
    this.receiveTimeout = const Duration(seconds: 30),
    this.sendTimeout = const Duration(seconds: 30),
  });

  /// Get configuration for development environment
  static const EnvironmentConfig development = EnvironmentConfig(
    environment: Environment.development,
    baseUrl: 'http://localhost:5000', // ASP.NET Core backend URL
    enableLogging: true,
    enableCertificatePinning: false, // Disabled for HTTP testing
    enableRequestSigning: false, // Disabled for local development
    enableAnalytics: false,
    certificatePins: {
      'localhost': [
        'sha256:JiDEHHD1V7llfZAFYQJ3zQmKVDotIwmzkTScMb/7Rmc=', // Development self-signed cert
      ],
    },
  );

  /// Get configuration for staging environment
  static const EnvironmentConfig staging = EnvironmentConfig(
    environment: Environment.staging,
    baseUrl: 'https://staging-api.yourdomain.com',
    enableLogging: true,
    enableCertificatePinning: true,
    enableRequestSigning: true,
    enableAnalytics: true,
    certificatePins: {
      'staging-api.yourdomain.com': [
        // Replace with actual staging certificate fingerprints
        'sha256:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
        'sha256:BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
      ],
    },
  );

  /// Get configuration for production environment
  static const EnvironmentConfig production = EnvironmentConfig(
    environment: Environment.production,
    baseUrl: 'https://api.yourdomain.com',
    enableLogging: false, // Disabled in production for performance
    enableCertificatePinning: true,
    enableRequestSigning: true,
    enableAnalytics: true,
    certificatePins: {
      'api.yourdomain.com': [
        // Replace with actual production certificate fingerprints
        'sha256:CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=',
        'sha256:DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD=',
      ],
      'auth.yourdomain.com': [
        'sha256:EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE=',
        'sha256:FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF=',
      ],
    },
  );

  /// Get the current configuration based on build mode and environment variables
  static EnvironmentConfig get current {
    // In a real app, you might read from environment variables or build configs
    // For now, we'll use Flutter's build mode as a proxy
    
    if (kDebugMode) {
      return development;
    } else if (kProfileMode) {
      return staging;
    } else {
      return production;
    }
  }

  /// Initialize certificate pinning for this environment
  void initializeCertificatePinning() {
    if (enableCertificatePinning && certificatePins.isNotEmpty) {
      CertificatePinningService.initialize(
        environment: environment.name,
        customPins: certificatePins,
        enablePinning: enableCertificatePinning,
      );
    }
  }

  /// Get full API URL with version
  String get apiUrl => '$baseUrl/api';

  /// Check if this is a production environment
  bool get isProduction => environment == Environment.production;

  /// Check if this is a development environment
  bool get isDevelopment => environment == Environment.development;

  /// Check if this is a staging environment
  bool get isStaging => environment == Environment.staging;

  @override
  String toString() {
    return 'EnvironmentConfig{environment: $environment, baseUrl: $baseUrl, enableCertificatePinning: $enableCertificatePinning}';
  }
}

/// Service for managing environment configuration
class EnvironmentService {
  static EnvironmentConfig? _config;

  /// Initialize the environment configuration
  static void initialize([EnvironmentConfig? config]) {
    _config = config ?? EnvironmentConfig.current;
    
    // Initialize certificate pinning
    _config!.initializeCertificatePinning();
    
    print('Environment initialized: ${_config!.environment.name}');
    print('Base URL: ${_config!.baseUrl}');
    print('Certificate pinning: ${_config!.enableCertificatePinning}');
  }

  /// Get the current environment configuration
  static EnvironmentConfig get config {
    if (_config == null) {
      initialize();
    }
    return _config!;
  }

  /// Check if environment is initialized
  static bool get isInitialized => _config != null;

  /// Override environment configuration (useful for testing)
  static void override(EnvironmentConfig config) {
    _config = config;
    config.initializeCertificatePinning();
  }

  /// Reset to default environment
  static void reset() {
    _config = null;
    initialize();
  }
}

/// Environment-specific feature flags
class FeatureFlags {
  static EnvironmentConfig get _config => EnvironmentService.config;

  /// Whether to enable debug logging
  static bool get enableLogging => _config.enableLogging;

  /// Whether to enable certificate pinning
  static bool get enableCertificatePinning => _config.enableCertificatePinning;

  /// Whether to enable request signing
  static bool get enableRequestSigning => _config.enableRequestSigning;

  /// Whether to enable analytics
  static bool get enableAnalytics => _config.enableAnalytics;

  /// Whether biometric authentication is available
  static bool get enableBiometricAuth => true; // Always available for this app

  /// Whether to show debug information in UI
  static bool get showDebugInfo => _config.isDevelopment;

  /// Whether to use strict security policies
  static bool get strictSecurity => _config.isProduction;

  /// Maximum number of login attempts
  static int get maxLoginAttempts => _config.isProduction ? 3 : 10;

  /// Token refresh threshold (minutes before expiry)
  static int get tokenRefreshThreshold => _config.isProduction ? 5 : 15;

  /// Session timeout (minutes)
  static int get sessionTimeout => _config.isProduction ? 30 : 120;
}