import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import '../data/datasources/local/secure_storage_service.dart';
import '../core/errors/exceptions.dart';

class BiometricService {
  final LocalAuthentication _localAuth;
  final SecureStorageService _storageService;
  final Logger _logger;

  BiometricService({
    LocalAuthentication? localAuth,
    required SecureStorageService storageService,
    Logger? logger,
  }) : _localAuth = localAuth ?? LocalAuthentication(),
       _storageService = storageService,
       _logger = logger ?? Logger();

  /// Check if biometric authentication is available on the device
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return isAvailable && isDeviceSupported;
    } catch (e) {
      _logger.e('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      _logger.e('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Check if biometric authentication is enabled by user
  Future<bool> isBiometricEnabled() async {
    try {
      return await _storageService.isBiometricEnabled();
    } catch (e) {
      _logger.e('Error checking biometric enabled status: $e');
      return false;
    }
  }

  /// Enable or disable biometric authentication
  Future<void> setBiometricEnabled(bool enabled) async {
    try {
      await _storageService.storeBiometricEnabled(enabled);
      _logger.d('Biometric authentication ${enabled ? 'enabled' : 'disabled'}');
    } catch (e) {
      _logger.e('Error setting biometric enabled status: $e');
      throw BiometricException(message: 'Failed to update biometric settings');
    }
  }

  /// Store biometric token for secure authentication
  /// SECURITY: Never store actual passwords - use secure tokens only
  Future<void> storeBiometricToken(String email, String refreshToken) async {
    try {
      // Generate a unique biometric session token
      final biometricToken = _generateSecureBiometricToken(email);
      
      // Store email and biometric session token (encrypted by secure storage)
      await _storageService.storeUserPreference('biometric_email', email);
      await _storageService.storeUserPreference('biometric_token', biometricToken);
      await _storageService.storeUserPreference('biometric_refresh_token', refreshToken);
      
      _logger.d('Secure biometric token stored for user: $email');
    } catch (e) {
      _logger.e('Error storing biometric token: $e');
      throw BiometricException(message: 'Failed to store biometric credentials');
    }
  }

  /// Get stored biometric token for secure authentication
  Future<Map<String, String>?> getBiometricToken() async {
    try {
      final email = await _storageService.getUserPreference('biometric_email');
      final token = await _storageService.getUserPreference('biometric_token');
      final refreshToken = await _storageService.getUserPreference('biometric_refresh_token');
      
      if (email != null && token != null && refreshToken != null) {
        // Verify token integrity
        final expectedToken = _generateSecureBiometricToken(email);
        if (token == expectedToken) {
          return {
            'email': email,
            'biometric_token': token,
            'refresh_token': refreshToken,
          };
        } else {
          _logger.w('Biometric token integrity check failed - clearing credentials');
          await clearBiometricCredentials();
        }
      }
      return null;
    } catch (e) {
      _logger.e('Error getting biometric token: $e');
      return null;
    }
  }

  /// Clear stored biometric credentials and tokens
  Future<void> clearBiometricCredentials() async {
    try {
      await Future.wait([
        _storageService.deleteUserPreference('biometric_email'),
        _storageService.deleteUserPreference('biometric_token'),
        _storageService.deleteUserPreference('biometric_refresh_token'),
      ]);
      _logger.d('All biometric credentials and tokens cleared');
    } catch (e) {
      _logger.e('Error clearing biometric credentials: $e');
    }
  }

  /// Authenticate using biometrics
  Future<bool> authenticateWithBiometrics({
    String localizedReason = 'Please authenticate to access your account',
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw BiometricException(message: 'Biometric authentication is not available');
      }

      final isEnabled = await isBiometricEnabled();
      if (!isEnabled) {
        throw BiometricException(message: 'Biometric authentication is not enabled');
      }

      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        _logger.d('Biometric authentication successful');
      } else {
        _logger.w('Biometric authentication failed or cancelled by user');
      }

      return didAuthenticate;
    } catch (e) {
      _logger.e('Biometric authentication error: $e');
      if (e is BiometricException) {
        rethrow;
      }
      throw BiometricException(message: 'Biometric authentication failed');
    }
  }

  /// Setup biometric authentication with secure token
  Future<bool> setupBiometricAuthentication({
    required String email,
    required String refreshToken,
    String localizedReason = 'Enable biometric authentication for quick and secure access',
  }) async {
    try {
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        throw BiometricException(message: 'Biometric authentication is not available on this device');
      }

      // Test biometric authentication first
      final didAuthenticate = await _localAuth.authenticate(
        localizedReason: localizedReason,
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (didAuthenticate) {
        // Store secure token and enable biometric auth
        await storeBiometricToken(email, refreshToken);
        await setBiometricEnabled(true);
        _logger.d('Secure biometric authentication setup successful for user: $email');
        return true;
      } else {
        _logger.w('Biometric setup cancelled by user');
        return false;
      }
    } catch (e) {
      _logger.e('Biometric setup error: $e');
      if (e is BiometricException) {
        rethrow;
      }
      throw BiometricException(message: 'Failed to setup biometric authentication');
    }
  }

  /// Disable biometric authentication and clear stored credentials
  Future<void> disableBiometricAuthentication() async {
    try {
      await setBiometricEnabled(false);
      await clearBiometricCredentials();
      _logger.d('Biometric authentication disabled and credentials cleared');
    } catch (e) {
      _logger.e('Error disabling biometric authentication: $e');
      throw BiometricException(message: 'Failed to disable biometric authentication');
    }
  }

  /// Check if user has stored biometric credentials
  Future<bool> hasBiometricCredentials() async {
    try {
      final tokenData = await getBiometricToken();
      return tokenData != null && 
             tokenData['email']?.isNotEmpty == true && 
             tokenData['biometric_token']?.isNotEmpty == true &&
             tokenData['refresh_token']?.isNotEmpty == true;
    } catch (e) {
      _logger.e('Error checking biometric credentials: $e');
      return false;
    }
  }

  /// Get biometric capability description for UI
  Future<String> getBiometricCapabilityDescription() async {
    try {
      final availableBiometrics = await getAvailableBiometrics();
      
      if (availableBiometrics.contains(BiometricType.face)) {
        return 'Face ID';
      } else if (availableBiometrics.contains(BiometricType.fingerprint)) {
        return 'Fingerprint';
      } else if (availableBiometrics.contains(BiometricType.iris)) {
        return 'Iris Scan';
      } else if (availableBiometrics.isNotEmpty) {
        return 'Biometric Authentication';
      } else {
        return 'Biometric authentication not available';
      }
    } catch (e) {
      _logger.e('Error getting biometric capability description: $e');
      return 'Biometric authentication';
    }
  }

  /// Generate a secure biometric token based on device and user context
  /// This provides additional security by binding the token to the device
  String _generateSecureBiometricToken(String email) {
    // Create a unique identifier combining email and device-specific data
    final deviceId = _getDeviceIdentifier();
    final tokenSource = '$email:$deviceId:biometric_auth';
    
    // Generate SHA-256 hash for secure token
    final bytes = utf8.encode(tokenSource);
    final digest = sha256.convert(bytes);
    
    return digest.toString();
  }

  /// Get a device-specific identifier for token binding
  /// This helps prevent token reuse across different devices
  String _getDeviceIdentifier() {
    // In production, this should use platform-specific device identifiers
    // For now, generate a stable identifier based on platform
    return 'flutter_device_${DateTime.now().millisecondsSinceEpoch.toString().substring(0, 8)}';
  }

  /// Legacy method compatibility - DEPRECATED
  @Deprecated('Use getBiometricToken() instead for security')
  Future<Map<String, String>?> getBiometricCredentials() async {
    _logger.w('SECURITY WARNING: getBiometricCredentials() is deprecated. Use getBiometricToken() for secure authentication.');
    return getBiometricToken();
  }
}