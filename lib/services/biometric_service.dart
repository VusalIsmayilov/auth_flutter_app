import 'package:local_auth/local_auth.dart';
import 'package:logger/logger.dart';
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

  /// Store user credentials for biometric login
  Future<void> storeBiometricCredentials(String email, String hashedPassword) async {
    try {
      await _storageService.storeUserPreference('biometric_email', email);
      await _storageService.storeUserPreference('biometric_password', hashedPassword);
      _logger.d('Biometric credentials stored for user: $email');
    } catch (e) {
      _logger.e('Error storing biometric credentials: $e');
      throw BiometricException(message: 'Failed to store biometric credentials');
    }
  }

  /// Get stored biometric credentials
  Future<Map<String, String>?> getBiometricCredentials() async {
    try {
      final email = await _storageService.getUserPreference('biometric_email');
      final password = await _storageService.getUserPreference('biometric_password');
      
      if (email != null && password != null) {
        return {
          'email': email,
          'password': password,
        };
      }
      return null;
    } catch (e) {
      _logger.e('Error getting biometric credentials: $e');
      return null;
    }
  }

  /// Clear stored biometric credentials
  Future<void> clearBiometricCredentials() async {
    try {
      await Future.wait([
        _storageService.storeUserPreference('biometric_email', ''),
        _storageService.storeUserPreference('biometric_password', ''),
      ]);
      _logger.d('Biometric credentials cleared');
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

  /// Setup biometric authentication for first time
  Future<bool> setupBiometricAuthentication({
    required String email,
    required String hashedPassword,
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
        // Store credentials and enable biometric auth
        await storeBiometricCredentials(email, hashedPassword);
        await setBiometricEnabled(true);
        _logger.d('Biometric authentication setup successful for user: $email');
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
      final credentials = await getBiometricCredentials();
      return credentials != null && 
             credentials['email']?.isNotEmpty == true && 
             credentials['password']?.isNotEmpty == true;
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
}