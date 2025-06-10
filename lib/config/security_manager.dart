import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../core/network/certificate_pinning.dart';
import '../core/security/request_signing_service.dart';
import '../core/security/token_blacklist_service.dart';
import '../core/network/dio_client.dart';
import '../data/datasources/local/secure_storage_service.dart';
import '../services/jwt_service.dart';
import 'security_config.dart';
import 'environment_config.dart';

/// Centralized security manager for production-ready security
class SecurityManager {
  static SecurityManager? _instance;
  static final Logger _logger = Logger();
  
  SecurityConfig? _securityConfig;
  RequestSigningService? _requestSigningService;
  bool _isInitialized = false;

  SecurityManager._();

  /// Get singleton instance
  static SecurityManager get instance {
    _instance ??= SecurityManager._();
    return _instance!;
  }

  /// Initialize security systems based on environment
  Future<void> initialize({
    String? environment,
    SecurityConfig? customConfig,
  }) async {
    try {
      final env = environment ?? EnvironmentService.config.environment.name;
      _securityConfig = customConfig ?? SecurityConfig.forEnvironment(env);
      
      _logger.i('🔒 Initializing security systems for environment: $env');
      
      // 1. Initialize certificate pinning
      await _initializeCertificatePinning();
      
      // 2. Initialize request signing
      await _initializeRequestSigning();
      
      // 3. Initialize token blacklist service
      await _initializeTokenBlacklist();
      
      // 4. Validate security configuration
      _validateSecurityConfiguration();
      
      _isInitialized = true;
      _logger.i('✅ Security systems initialized successfully');
      
    } catch (e) {
      _logger.e('❌ Failed to initialize security systems: $e');
      rethrow;
    }
  }

  /// Initialize certificate pinning
  Future<void> _initializeCertificatePinning() async {
    if (_securityConfig!.enableCertificatePinning) {
      CertificatePinningService.initialize(
        environment: _securityConfig!.environment,
        customPins: _securityConfig!.certificatePins,
        enablePinning: true,
      );
      _logger.i('🔐 Certificate pinning enabled');
    } else {
      _logger.w('⚠️ Certificate pinning disabled for ${_securityConfig!.environment}');
    }
  }

  /// Initialize request signing
  Future<void> _initializeRequestSigning() async {
    if (_securityConfig!.enableRequestSigning) {
      _requestSigningService = RequestSigningService(
        apiKey: _securityConfig!.requestSigningConfig.apiKey,
        secretKey: _securityConfig!.requestSigningConfig.secretKey,
        enableSigning: true,
        logger: _logger,
      );
      _logger.i('✍️ Request signing enabled');
    } else {
      _logger.w('⚠️ Request signing disabled for ${_securityConfig!.environment}');
    }
  }

  /// Initialize token blacklist service
  Future<void> _initializeTokenBlacklist() async {
    try {
      // Import the secure storage service
      final storageService = SecureStorageService();
      await TokenBlacklistService.initialize(storageService: storageService);
      _logger.i('🚫 Token blacklist service initialized');
    } catch (e) {
      _logger.w('⚠️ Token blacklist service initialization failed: $e');
    }
  }

  /// Validate security configuration
  void _validateSecurityConfiguration() {
    final audit = SecurityAuditor.auditConfiguration(_securityConfig!);
    
    if (!audit.passed) {
      _logger.e('❌ Security configuration validation failed:');
      for (final error in audit.errors) {
        _logger.e('  • $error');
      }
      
      if (_securityConfig!.environment == 'production') {
        throw SecurityConfigurationException(
          'Production security configuration is invalid',
          errors: audit.errors,
        );
      }
    }
    
    if (audit.warnings.isNotEmpty) {
      _logger.w('⚠️ Security configuration warnings:');
      for (final warning in audit.warnings) {
        _logger.w('  • $warning');
      }
    }
    
    if (audit.recommendations.isNotEmpty) {
      _logger.i('💡 Security recommendations:');
      for (final recommendation in audit.recommendations) {
        _logger.i('  • $recommendation');
      }
    }
  }

  /// Configure Dio client with security features
  void configureDioClient({
    required JwtService jwtService,
    String? baseUrl,
  }) {
    if (!_isInitialized) {
      throw StateError('SecurityManager must be initialized before configuring Dio client');
    }

    DioClient.getInstance(
      jwtService: jwtService,
      baseUrl: baseUrl,
      forceRecreate: true,
      requestSigningService: _requestSigningService,
    );
    
    _logger.i('🌐 Dio client configured with security features');
  }

  /// Update security configuration at runtime
  Future<void> updateConfiguration(SecurityConfig newConfig) async {
    _securityConfig = newConfig;
    
    // Re-initialize systems with new configuration
    await _initializeCertificatePinning();
    await _initializeRequestSigning();
    _validateSecurityConfiguration();
    
    _logger.i('🔄 Security configuration updated');
  }

  /// Generate production security template
  Map<String, String> generateProductionTemplate() {
    return SecurityConfigUtils.generateProductionTemplate();
  }

  /// Check if security is properly configured for production
  bool isProductionReady() {
    return _securityConfig?.isProductionReady ?? false;
  }

  /// Get current security configuration
  SecurityConfig? get securityConfig => _securityConfig;

  /// Get request signing service
  RequestSigningService? get requestSigningService => _requestSigningService;

  /// Check if security manager is initialized
  bool get isInitialized => _isInitialized;

  /// Get security audit report
  SecurityAuditResult getSecurityAudit() {
    if (_securityConfig == null) {
      return const SecurityAuditResult(
        passed: false,
        errors: ['Security configuration not initialized'],
        warnings: [],
        recommendations: ['Initialize SecurityManager before use'],
      );
    }
    
    return SecurityAuditor.auditConfiguration(_securityConfig!);
  }

  /// Print security status report
  void printSecurityStatus() {
    if (!_isInitialized) {
      print('🔒 Security Status: NOT INITIALIZED');
      return;
    }

    final config = _securityConfig!;
    final audit = getSecurityAudit();

    print('\n🔒 Security Status Report');
    print('=' * 50);
    print('Environment: ${config.environment}');
    print('Security Level: ${config.securityLevel.name.toUpperCase()}');
    print('Certificate Pinning: ${config.enableCertificatePinning ? "✅ Enabled" : "❌ Disabled"}');
    print('Request Signing: ${config.enableRequestSigning ? "✅ Enabled" : "❌ Disabled"}');
    print('Production Ready: ${config.isProductionReady ? "✅ Yes" : "❌ No"}');
    print('Configuration Valid: ${audit.passed ? "✅ Yes" : "❌ No"}');

    if (audit.errors.isNotEmpty) {
      print('\n❌ Errors:');
      for (final error in audit.errors) {
        print('  • $error');
      }
    }

    if (audit.warnings.isNotEmpty) {
      print('\n⚠️ Warnings:');
      for (final warning in audit.warnings) {
        print('  • $warning');
      }
    }

    if (audit.recommendations.isNotEmpty) {
      print('\n💡 Recommendations:');
      for (final recommendation in audit.recommendations) {
        print('  • $recommendation');
      }
    }

    print('=' * 50);
  }

  /// Reset security manager (for testing)
  @visibleForTesting
  static void reset() {
    _instance = null;
  }
}

/// Exception for security configuration issues
class SecurityConfigurationException implements Exception {
  final String message;
  final List<String> errors;
  final List<String>? warnings;

  const SecurityConfigurationException(
    this.message, {
    required this.errors,
    this.warnings,
  });

  @override
  String toString() {
    final buffer = StringBuffer('SecurityConfigurationException: $message\n');
    
    if (errors.isNotEmpty) {
      buffer.writeln('Errors:');
      for (final error in errors) {
        buffer.writeln('  • $error');
      }
    }
    
    if (warnings != null && warnings!.isNotEmpty) {
      buffer.writeln('Warnings:');
      for (final warning in warnings!) {
        buffer.writeln('  • $warning');
      }
    }
    
    return buffer.toString();
  }
}

/// Security initialization helper
class SecurityInitializer {
  /// Initialize security for app startup
  static Future<void> initializeForApp({
    String? environment,
    SecurityConfig? customConfig,
  }) async {
    final securityManager = SecurityManager.instance;
    
    // Initialize security systems
    await securityManager.initialize(
      environment: environment,
      customConfig: customConfig,
    );
    
    // Print security status in debug mode
    if (kDebugMode) {
      securityManager.printSecurityStatus();
    }
    
    // Validate production security
    if (environment == 'production' && !securityManager.isProductionReady()) {
      throw SecurityConfigurationException(
        'Production security configuration is not ready',
        errors: ['Production secrets and certificates must be configured'],
      );
    }
  }

  /// Generate production deployment checklist
  static List<String> getProductionDeploymentChecklist() {
    return [
      '🔑 Generate unique API keys using SecurityConfigUtils.generateSecureApiKey()',
      '🔐 Generate secure secret keys using SecurityConfigUtils.generateSecureSecretKey()',
      '📜 Obtain real SSL certificate fingerprints for your production domains',
      '🌍 Configure environment variables for production secrets',
      '🚫 Ensure no placeholder values remain in security configuration',
      '✅ Run security audit using SecurityAuditor.auditConfiguration()',
      '🔒 Enable certificate pinning for production domains',
      '✍️ Enable request signing for API security',
      '🧪 Test security features in staging environment first',
      '📋 Review and document security incident response procedures',
    ];
  }

  /// Validate production readiness
  static bool validateProductionReadiness() {
    final securityManager = SecurityManager.instance;
    
    if (!securityManager.isInitialized) {
      return false;
    }
    
    final audit = securityManager.getSecurityAudit();
    return audit.passed && securityManager.isProductionReady();
  }
}