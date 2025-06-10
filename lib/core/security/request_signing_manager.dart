import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart';
import '../constants/storage_keys.dart';
import '../../data/datasources/local/secure_storage_service.dart';
import 'request_signing_service.dart';

/// Manages request signing configuration and lifecycle
class RequestSigningManager {
  static RequestSigningManager? _instance;
  static final Logger _logger = Logger();

  final SecureStorageService _storageService;
  RequestSigningService? _requestSigningService;
  RequestSigningConfig? _currentConfig;

  RequestSigningManager._({
    required SecureStorageService storageService,
  }) : _storageService = storageService;

  /// Get the singleton instance
  static RequestSigningManager get instance {
    if (_instance == null) {
      throw StateError('RequestSigningManager not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  /// Initialize the request signing manager
  static Future<RequestSigningManager> initialize({
    required SecureStorageService storageService,
    String environment = 'development',
    String? customApiKey,
    String? customSecretKey,
  }) async {
    _instance = RequestSigningManager._(storageService: storageService);
    
    await _instance!._initializeConfiguration(
      environment: environment,
      customApiKey: customApiKey,
      customSecretKey: customSecretKey,
    );

    _logger.i('RequestSigningManager initialized for environment: $environment');
    return _instance!;
  }

  /// Initialize configuration based on environment
  Future<void> _initializeConfiguration({
    required String environment,
    String? customApiKey,
    String? customSecretKey,
  }) async {
    try {
      // Try to load existing keys from secure storage
      String? apiKey = customApiKey ?? await _loadApiKey();
      String? secretKey = customSecretKey ?? await _loadSecretKey();

      // Generate new keys if not found and not in production
      if (apiKey == null || secretKey == null) {
        if (environment.toLowerCase() == 'production') {
          throw RequestSigningException(
            message: 'API keys must be provided for production environment',
            details: 'Cannot generate keys in production for security reasons',
          );
        }

        _logger.w('Generating new API keys for environment: $environment');
        apiKey = RequestSigningUtils.generateApiKey();
        secretKey = RequestSigningUtils.generateSecretKey();

        // Store generated keys
        await _storeApiKey(apiKey);
        await _storeSecretKey(secretKey);
      }

      // Create configuration
      _currentConfig = RequestSigningConfig.fromEnvironment(
        environment: environment,
        customApiKey: apiKey,
        customSecretKey: secretKey,
      );

      // Create request signing service
      if (_currentConfig!.enableSigning) {
        _requestSigningService = RequestSigningService(
          apiKey: _currentConfig!.apiKey,
          secretKey: _currentConfig!.secretKey,
          logger: _logger,
          enableSigning: _currentConfig!.enableSigning,
        );
        _logger.i('Request signing enabled');
      } else {
        _logger.i('Request signing disabled for environment: $environment');
      }
    } catch (e) {
      _logger.e('Failed to initialize request signing configuration: $e');
      rethrow;
    }
  }

  /// Get the current request signing service
  RequestSigningService? get requestSigningService => _requestSigningService;

  /// Get the current configuration
  RequestSigningConfig? get currentConfig => _currentConfig;

  /// Check if request signing is enabled
  bool get isSigningEnabled => _currentConfig?.enableSigning ?? false;

  /// Update configuration
  Future<void> updateConfiguration(RequestSigningConfig config) async {
    try {
      _currentConfig = config;

      // Store new keys securely
      await _storeApiKey(config.apiKey);
      await _storeSecretKey(config.secretKey);

      // Update or create request signing service
      if (config.enableSigning) {
        _requestSigningService = RequestSigningService(
          apiKey: config.apiKey,
          secretKey: config.secretKey,
          logger: _logger,
          enableSigning: config.enableSigning,
        );
        _logger.i('Request signing configuration updated and enabled');
      } else {
        _requestSigningService = null;
        _logger.i('Request signing disabled');
      }
    } catch (e) {
      _logger.e('Failed to update request signing configuration: $e');
      rethrow;
    }
  }

  /// Rotate API keys
  Future<void> rotateKeys() async {
    try {
      if (_currentConfig == null) {
        throw RequestSigningException(
          message: 'Cannot rotate keys: configuration not initialized',
        );
      }

      _logger.i('Rotating API keys...');

      // Generate new keys
      final newApiKey = RequestSigningUtils.generateApiKey();
      final newSecretKey = RequestSigningUtils.generateSecretKey();

      // Update configuration with new keys
      final newConfig = _currentConfig!.copyWith(
        apiKey: newApiKey,
        secretKey: newSecretKey,
      );

      await updateConfiguration(newConfig);
      _logger.i('API keys rotated successfully');
    } catch (e) {
      _logger.e('Failed to rotate API keys: $e');
      rethrow;
    }
  }

  /// Validate current configuration
  bool validateConfiguration() {
    if (_currentConfig == null) return false;

    final config = _currentConfig!;
    
    // Validate API key format
    if (!RequestSigningUtils.isValidApiKey(config.apiKey)) {
      _logger.e('Invalid API key format');
      return false;
    }

    // Validate secret key format
    if (!RequestSigningUtils.isValidSecretKey(config.secretKey)) {
      _logger.e('Invalid secret key format');
      return false;
    }

    return true;
  }

  /// Clear all request signing data
  Future<void> clearConfiguration() async {
    try {
      await _deleteApiKey();
      await _deleteSecretKey();
      
      _currentConfig = null;
      _requestSigningService = null;
      
      _logger.i('Request signing configuration cleared');
    } catch (e) {
      _logger.e('Failed to clear request signing configuration: $e');
      rethrow;
    }
  }

  /// Load API key from secure storage
  Future<String?> _loadApiKey() async {
    return await _storageService.getUserPreference(StorageKeys.requestSigningApiKey);
  }

  /// Load secret key from secure storage
  Future<String?> _loadSecretKey() async {
    return await _storageService.getUserPreference(StorageKeys.requestSigningSecretKey);
  }

  /// Store API key in secure storage
  Future<void> _storeApiKey(String apiKey) async {
    await _storageService.storeUserPreference(StorageKeys.requestSigningApiKey, apiKey);
  }

  /// Store secret key in secure storage
  Future<void> _storeSecretKey(String secretKey) async {
    await _storageService.storeUserPreference(StorageKeys.requestSigningSecretKey, secretKey);
  }

  /// Delete API key from secure storage
  Future<void> _deleteApiKey() async {
    await _storageService.storeUserPreference(StorageKeys.requestSigningApiKey, '');
  }

  /// Delete secret key from secure storage
  Future<void> _deleteSecretKey() async {
    await _storageService.storeUserPreference(StorageKeys.requestSigningSecretKey, '');
  }

  /// Get signing statistics
  Map<String, dynamic> getSigningStats() {
    return {
      'enabled': isSigningEnabled,
      'hasConfig': _currentConfig != null,
      'hasService': _requestSigningService != null,
      'apiKeyValid': _currentConfig != null ? 
        RequestSigningUtils.isValidApiKey(_currentConfig!.apiKey) : false,
      'secretKeyValid': _currentConfig != null ? 
        RequestSigningUtils.isValidSecretKey(_currentConfig!.secretKey) : false,
      'timestampTolerance': _currentConfig?.timestampTolerance.inMinutes,
      'excludedPaths': _currentConfig?.excludedPaths,
    };
  }

  /// Reset instance for testing
  @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }

  /// Check if instance is initialized
  static bool get isInitialized => _instance != null;
}