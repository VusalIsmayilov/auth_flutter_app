import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import '../core/security/request_signing_service.dart';

/// Production-ready security configuration manager
class SecurityConfig {
  final String environment;
  final bool enableCertificatePinning;
  final bool enableRequestSigning;
  final RequestSigningConfig requestSigningConfig;
  final Map<String, List<String>> certificatePins;
  final SecurityLevel securityLevel;

  const SecurityConfig({
    required this.environment,
    required this.enableCertificatePinning,
    required this.enableRequestSigning,
    required this.requestSigningConfig,
    required this.certificatePins,
    required this.securityLevel,
  });

  /// Create security configuration for different environments
  factory SecurityConfig.forEnvironment(String environment) {
    switch (environment.toLowerCase()) {
      case 'production':
        return SecurityConfig._production();
      case 'staging':
        return SecurityConfig._staging();
      case 'development':
      case 'debug':
        return SecurityConfig._development();
      default:
        return SecurityConfig._development();
    }
  }

  /// Production security configuration - MAXIMUM SECURITY
  factory SecurityConfig._production() {
    return SecurityConfig(
      environment: 'production',
      enableCertificatePinning: true,
      enableRequestSigning: true,
      securityLevel: SecurityLevel.maximum,
      requestSigningConfig: RequestSigningConfig(
        // IMPORTANT: Replace these with your actual production keys
        apiKey: const String.fromEnvironment(
          'PROD_API_KEY',
          defaultValue: _ProductionSecrets.apiKey,
        ),
        secretKey: const String.fromEnvironment(
          'PROD_SECRET_KEY', 
          defaultValue: _ProductionSecrets.secretKey,
        ),
        enableSigning: true,
        timestampTolerance: const Duration(minutes: 2), // Strict timing
      ),
      certificatePins: {
        // IMPORTANT: Replace with your actual certificate fingerprints
        'your-api.yourdomain.com': [
          _ProductionSecrets.primaryCertFingerprint,
          _ProductionSecrets.backupCertFingerprint,
        ],
        'auth-api.yourdomain.com': [
          _ProductionSecrets.authCertFingerprint,
          _ProductionSecrets.authBackupCertFingerprint,
        ],
      },
    );
  }

  /// Staging security configuration - HIGH SECURITY
  factory SecurityConfig._staging() {
    return SecurityConfig(
      environment: 'staging',
      enableCertificatePinning: true,
      enableRequestSigning: true,
      securityLevel: SecurityLevel.high,
      requestSigningConfig: RequestSigningConfig(
        apiKey: const String.fromEnvironment(
          'STAGING_API_KEY',
          defaultValue: _StagingSecrets.apiKey,
        ),
        secretKey: const String.fromEnvironment(
          'STAGING_SECRET_KEY',
          defaultValue: _StagingSecrets.secretKey,
        ),
        enableSigning: true,
        timestampTolerance: const Duration(minutes: 5),
      ),
      certificatePins: {
        'staging-api.yourdomain.com': [
          _StagingSecrets.primaryCertFingerprint,
          _StagingSecrets.backupCertFingerprint,
        ],
      },
    );
  }

  /// Development security configuration - BASIC SECURITY
  factory SecurityConfig._development() {
    return SecurityConfig(
      environment: 'development',
      enableCertificatePinning: false, // Disabled for local development
      enableRequestSigning: false, // Disabled for local development
      securityLevel: SecurityLevel.basic,
      requestSigningConfig: RequestSigningConfig(
        apiKey: _DevelopmentSecrets.apiKey,
        secretKey: _DevelopmentSecrets.secretKey,
        enableSigning: false,
        timestampTolerance: const Duration(minutes: 10),
        excludedPaths: ['/health', '/debug', '/api/auth/register', '/api/auth/login'],
      ),
      certificatePins: {}, // No certificate pinning in development
    );
  }

  /// Check if configuration is production-ready
  bool get isProductionReady {
    if (environment == 'production') {
      // Verify all production secrets are properly configured
      return _ProductionSecrets.areSecretsConfigured() &&
             enableCertificatePinning &&
             enableRequestSigning &&
             certificatePins.isNotEmpty;
    }
    return true; // Non-production environments are fine as-is
  }

  /// Get security recommendations
  List<String> getSecurityRecommendations() {
    final recommendations = <String>[];

    if (environment == 'production') {
      if (!enableCertificatePinning) {
        recommendations.add('Enable certificate pinning for production');
      }
      if (!enableRequestSigning) {
        recommendations.add('Enable request signing for production');
      }
      if (!_ProductionSecrets.areSecretsConfigured()) {
        recommendations.add('Configure production API keys and secrets');
      }
      if (certificatePins.isEmpty) {
        recommendations.add('Configure certificate pinning for production domains');
      }
    }

    return recommendations;
  }
}

/// Security levels for different environments
enum SecurityLevel {
  basic,
  high,
  maximum,
}

/// Production secrets - REPLACE WITH YOUR ACTUAL VALUES
/// 
/// CRITICAL SECURITY NOTICE:
/// These are placeholder values that MUST be replaced before production deployment!
/// 
/// Proper production deployment should:
/// 1. Generate unique API keys and secrets using cryptographically secure methods
/// 2. Store secrets in environment variables or secure key management systems
/// 3. Obtain real certificate fingerprints from your production domains
/// 4. Never commit real secrets to version control
class _ProductionSecrets {
  // PLACEHOLDER - Generate real production API key
  static const String apiKey = String.fromEnvironment(
    'PROD_API_KEY',
    defaultValue: 'PLACEHOLDER-PROD-API-KEY-MUST-REPLACE',
  );

  // PLACEHOLDER - Generate real production secret key (min 64 chars)
  static const String secretKey = String.fromEnvironment(
    'PROD_SECRET_KEY',
    defaultValue: 'PLACEHOLDER-PROD-SECRET-KEY-MUST-REPLACE-WITH-MINIMUM-64-CHARS',
  );

  // PLACEHOLDER - Get real certificate fingerprints from your domain
  static const String primaryCertFingerprint = String.fromEnvironment(
    'PROD_CERT_PRIMARY',
    defaultValue: 'sha256:PLACEHOLDER-PRIMARY-CERT-FINGERPRINT-MUST-REPLACE',
  );

  static const String backupCertFingerprint = String.fromEnvironment(
    'PROD_CERT_BACKUP',
    defaultValue: 'sha256:PLACEHOLDER-BACKUP-CERT-FINGERPRINT-MUST-REPLACE',
  );

  static const String authCertFingerprint = String.fromEnvironment(
    'PROD_AUTH_CERT_PRIMARY',
    defaultValue: 'sha256:PLACEHOLDER-AUTH-CERT-FINGERPRINT-MUST-REPLACE',
  );

  static const String authBackupCertFingerprint = String.fromEnvironment(
    'PROD_AUTH_CERT_BACKUP',
    defaultValue: 'sha256:PLACEHOLDER-AUTH-BACKUP-CERT-FINGERPRINT-MUST-REPLACE',
  );

  /// Check if production secrets are properly configured
  static bool areSecretsConfigured() {
    return !apiKey.contains('PLACEHOLDER') &&
           !secretKey.contains('PLACEHOLDER') &&
           !primaryCertFingerprint.contains('PLACEHOLDER') &&
           !backupCertFingerprint.contains('PLACEHOLDER') &&
           !authCertFingerprint.contains('PLACEHOLDER') &&
           !authBackupCertFingerprint.contains('PLACEHOLDER');
  }
}

/// Staging secrets
class _StagingSecrets {
  static const String apiKey = String.fromEnvironment(
    'STAGING_API_KEY',
    defaultValue: 'staging-api-key-generated-timestamp-placeholder',
  );

  static const String secretKey = String.fromEnvironment(
    'STAGING_SECRET_KEY',
    defaultValue: 'staging-secret-key-generated-with-sufficient-length-for-hmac-security',
  );

  static const String primaryCertFingerprint = String.fromEnvironment(
    'STAGING_CERT_PRIMARY',
    defaultValue: 'sha256:staging-cert-fingerprint-to-be-replaced',
  );

  static const String backupCertFingerprint = String.fromEnvironment(
    'STAGING_CERT_BACKUP',
    defaultValue: 'sha256:staging-backup-cert-fingerprint-to-be-replaced',
  );
}

/// Development secrets - Safe for version control
class _DevelopmentSecrets {
  static const String apiKey = 'dev-api-key-localhost-testing';
  static const String secretKey = 'dev-secret-key-localhost-testing-minimum-32-chars';
}

/// Security configuration utility functions
class SecurityConfigUtils {
  /// Generate a cryptographically secure API key
  static String generateSecureApiKey({int length = 32}) {
    const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-_';
    final random = Random.secure();
    return List.generate(length, (index) => chars[random.nextInt(chars.length)]).join();
  }

  /// Generate a cryptographically secure secret key
  static String generateSecureSecretKey({int length = 64}) {
    final random = Random.secure();
    final bytes = List.generate(length, (index) => random.nextInt(256));
    return base64.encode(bytes);
  }

  /// Generate certificate fingerprint from domain (utility for obtaining real fingerprints)
  static String generateCertFingerprintPlaceholder(String domain) {
    final bytes = utf8.encode('$domain-${DateTime.now().millisecondsSinceEpoch}');
    final digest = sha256.convert(bytes);
    return 'sha256:${digest.toString()}';
  }

  /// Validate API key strength
  static bool isStrongApiKey(String apiKey) {
    return apiKey.length >= 32 &&
           !apiKey.contains('placeholder') &&
           !apiKey.contains('PLACEHOLDER') &&
           RegExp(r'^[a-zA-Z0-9\-_]{32,}$').hasMatch(apiKey);
  }

  /// Validate secret key strength
  static bool isStrongSecretKey(String secretKey) {
    return secretKey.length >= 64 &&
           !secretKey.contains('placeholder') &&
           !secretKey.contains('PLACEHOLDER');
  }

  /// Generate production-ready configuration template
  static Map<String, String> generateProductionTemplate() {
    return {
      'PROD_API_KEY': generateSecureApiKey(),
      'PROD_SECRET_KEY': generateSecureSecretKey(),
      'STAGING_API_KEY': generateSecureApiKey(),
      'STAGING_SECRET_KEY': generateSecureSecretKey(),
      'PROD_CERT_PRIMARY': 'sha256:REPLACE-WITH-YOUR-DOMAIN-CERT-FINGERPRINT',
      'PROD_CERT_BACKUP': 'sha256:REPLACE-WITH-YOUR-BACKUP-CERT-FINGERPRINT',
      'PROD_AUTH_CERT_PRIMARY': 'sha256:REPLACE-WITH-YOUR-AUTH-DOMAIN-CERT-FINGERPRINT',
      'PROD_AUTH_CERT_BACKUP': 'sha256:REPLACE-WITH-YOUR-AUTH-BACKUP-CERT-FINGERPRINT',
    };
  }
}

/// Security audit results
class SecurityAuditResult {
  final bool passed;
  final List<String> warnings;
  final List<String> errors;
  final List<String> recommendations;

  const SecurityAuditResult({
    required this.passed,
    required this.warnings,
    required this.errors,
    required this.recommendations,
  });

  bool get hasIssues => warnings.isNotEmpty || errors.isNotEmpty;
}

/// Security auditor for configuration validation
class SecurityAuditor {
  /// Perform comprehensive security audit
  static SecurityAuditResult auditConfiguration(SecurityConfig config) {
    final warnings = <String>[];
    final errors = <String>[];
    final recommendations = <String>[];

    // Check environment-specific requirements
    if (config.environment == 'production') {
      if (!config.enableCertificatePinning) {
        errors.add('Certificate pinning must be enabled in production');
      }
      if (!config.enableRequestSigning) {
        errors.add('Request signing must be enabled in production');
      }
      if (!_ProductionSecrets.areSecretsConfigured()) {
        errors.add('Production secrets contain placeholder values');
      }
      if (config.certificatePins.isEmpty) {
        errors.add('Certificate pins must be configured for production');
      }
    }

    // Validate API key strength
    if (!SecurityConfigUtils.isStrongApiKey(config.requestSigningConfig.apiKey)) {
      if (config.environment == 'production') {
        errors.add('Production API key is not strong enough');
      } else {
        warnings.add('API key could be stronger');
      }
    }

    // Validate secret key strength
    if (!SecurityConfigUtils.isStrongSecretKey(config.requestSigningConfig.secretKey)) {
      if (config.environment == 'production') {
        errors.add('Production secret key is not strong enough');
      } else {
        warnings.add('Secret key could be stronger');
      }
    }

    // Add recommendations
    recommendations.addAll(config.getSecurityRecommendations());

    return SecurityAuditResult(
      passed: errors.isEmpty,
      warnings: warnings,
      errors: errors,
      recommendations: recommendations,
    );
  }
}