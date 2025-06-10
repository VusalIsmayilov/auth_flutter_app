import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:logger/logger.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';

/// SSL Certificate pinning implementation for enhanced security
class CertificatePinning {
  final Map<String, List<String>> _pinnedCertificates;
  final Logger _logger;
  final bool _enablePinning;

  CertificatePinning({
    required Map<String, List<String>> pinnedCertificates,
    Logger? logger,
    bool enablePinning = true,
  }) : _pinnedCertificates = pinnedCertificates,
       _logger = logger ?? Logger(),
       _enablePinning = enablePinning;

  /// Create a Dio interceptor for certificate pinning
  Interceptor createInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        if (_enablePinning) {
          options.extra['_certificate_pinning'] = true;
        }
        handler.next(options);
      },
      onError: (error, handler) {
        if (error.type == DioExceptionType.connectionError &&
            error.error is HandshakeException) {
          _logger.e('SSL Handshake failed - possible certificate pinning violation');
        }
        handler.next(error);
      },
    );
  }

  /// Create HttpClientAdapter with certificate pinning
  HttpClientAdapter createHttpClientAdapter() {
    return IOHttpClientAdapter(
      createHttpClient: () {
        final client = HttpClient();
        
        if (_enablePinning) {
          client.badCertificateCallback = (cert, host, port) {
            return _validateCertificate(cert, host);
          };
        }
        
        return client;
      },
    );
  }

  /// Validate certificate against pinned certificates
  bool _validateCertificate(X509Certificate cert, String host) {
    try {
      final pinnedCerts = _pinnedCertificates[host];
      if (pinnedCerts == null || pinnedCerts.isEmpty) {
        _logger.w('No pinned certificates found for host: $host');
        return false; // Reject if no pins are configured for this host
      }

      // Get certificate fingerprint (SHA-256 of DER-encoded certificate)
      final certBytes = cert.der;
      final fingerprint = sha256.convert(certBytes).toString();
      
      // Get Subject Public Key Info (SPKI) fingerprint
      final spkiFingerprint = _extractSPKIFingerprint(cert);
      
      _logger.d('Validating certificate for $host');
      _logger.d('Certificate fingerprint: $fingerprint');
      _logger.d('SPKI fingerprint: $spkiFingerprint');

      // Check against pinned fingerprints
      for (final pinnedFingerprint in pinnedCerts) {
        if (fingerprint == pinnedFingerprint || spkiFingerprint == pinnedFingerprint) {
          _logger.d('Certificate validation successful for $host');
          return true;
        }
      }

      _logger.e('Certificate validation failed for $host - no matching pins');
      _logger.e('Expected one of: ${pinnedCerts.join(', ')}');
      _logger.e('Got: $fingerprint (cert) or $spkiFingerprint (SPKI)');
      
      return false;
    } catch (e) {
      _logger.e('Error during certificate validation: $e');
      return false;
    }
  }

  /// Extract SPKI (Subject Public Key Info) fingerprint from certificate
  String _extractSPKIFingerprint(X509Certificate cert) {
    try {
      // This is a simplified SPKI extraction
      // In production, you'd want to use a proper ASN.1 parser
      final certBytes = cert.der;
      
      // For demo purposes, we'll hash the entire certificate
      // In production, extract the actual SPKI from the ASN.1 structure
      final spkiHash = sha256.convert(certBytes);
      return spkiHash.toString();
    } catch (e) {
      _logger.e('Error extracting SPKI fingerprint: $e');
      return '';
    }
  }

  /// Add a pinned certificate for a host
  void addPin(String host, String fingerprint) {
    _pinnedCertificates.putIfAbsent(host, () => []).add(fingerprint);
    _logger.d('Added certificate pin for $host: $fingerprint');
  }

  /// Remove all pins for a host
  void removeHostPins(String host) {
    _pinnedCertificates.remove(host);
    _logger.d('Removed all certificate pins for $host');
  }

  /// Get configuration for different environments
  static Map<String, List<String>> getProductionPins() {
    return {
      'api.yourdomain.com': [
        // Replace with your actual certificate fingerprints
        'sha256:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=',
        'sha256:BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB=',
      ],
      'auth.yourdomain.com': [
        'sha256:CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC=',
        'sha256:DDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDDD=',
      ],
    };
  }

  static Map<String, List<String>> getStagingPins() {
    return {
      'staging-api.yourdomain.com': [
        'sha256:EEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE=',
        'sha256:FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF=',
      ],
    };
  }

  static Map<String, List<String>> getDevelopmentPins() {
    // In development, you might want to disable pinning or use self-signed certs
    return {
      'dev-api.yourdomain.com': [
        'sha256:GGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGGG=',
      ],
    };
  }
}

/// Certificate pinning service for managing SSL security
class CertificatePinningService {
  static CertificatePinning? _instance;
  static final Logger _logger = Logger();

  /// Reset instance for testing
  @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }

  /// Initialize certificate pinning based on environment
  static CertificatePinning initialize({
    required String environment,
    Map<String, List<String>>? customPins,
    bool enablePinning = true,
  }) {
    Map<String, List<String>> pins;

    if (customPins != null) {
      pins = customPins;
    } else {
      switch (environment.toLowerCase()) {
        case 'production':
          pins = CertificatePinning.getProductionPins();
          break;
        case 'staging':
          pins = CertificatePinning.getStagingPins();
          break;
        case 'development':
        case 'debug':
          pins = CertificatePinning.getDevelopmentPins();
          enablePinning = false; // Typically disabled in development
          break;
        default:
          pins = {};
          enablePinning = false;
          _logger.w('Unknown environment: $environment. Certificate pinning disabled.');
      }
    }

    _instance = CertificatePinning(
      pinnedCertificates: pins,
      logger: _logger,
      enablePinning: enablePinning,
    );

    _logger.i('Certificate pinning initialized for environment: $environment');
    _logger.i('Pinning enabled: $enablePinning');
    _logger.d('Pinned hosts: ${pins.keys.join(', ')}');

    return _instance!;
  }

  /// Get the current certificate pinning instance
  static CertificatePinning? get instance => _instance;

  /// Check if certificate pinning is initialized
  static bool get isInitialized => _instance != null;
}

/// Certificate pinning configuration
class CertPinConfig {
  final String host;
  final List<String> pins;
  final bool enabled;

  const CertPinConfig({
    required this.host,
    required this.pins,
    this.enabled = true,
  });

  factory CertPinConfig.fromJson(Map<String, dynamic> json) {
    return CertPinConfig(
      host: json['host'] as String,
      pins: List<String>.from(json['pins'] as List),
      enabled: json['enabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'pins': pins,
      'enabled': enabled,
    };
  }
}

/// Exception thrown when certificate pinning fails
class CertificatePinningException implements Exception {
  final String message;
  final String host;
  final String? actualFingerprint;
  final List<String>? expectedFingerprints;

  const CertificatePinningException({
    required this.message,
    required this.host,
    this.actualFingerprint,
    this.expectedFingerprints,
  });

  @override
  String toString() {
    var result = 'CertificatePinningException: $message (Host: $host)';
    if (actualFingerprint != null) {
      result += '\nActual: $actualFingerprint';
    }
    if (expectedFingerprints != null) {
      result += '\nExpected one of: ${expectedFingerprints!.join(', ')}';
    }
    return result;
  }
}

/// Utility functions for certificate management
class CertificateUtils {
  /// Convert PEM certificate to fingerprint
  static String pemToFingerprint(String pemCert) {
    try {
      // Remove PEM headers and decode base64
      final cleanPem = pemCert
          .replaceAll('-----BEGIN CERTIFICATE-----', '')
          .replaceAll('-----END CERTIFICATE-----', '')
          .replaceAll('\n', '')
          .replaceAll('\r', '')
          .trim();
      
      final certBytes = base64.decode(cleanPem);
      final fingerprint = sha256.convert(certBytes);
      
      return fingerprint.toString();
    } catch (e) {
      throw ArgumentError('Invalid PEM certificate format: $e');
    }
  }

  /// Format fingerprint for display
  static String formatFingerprint(String fingerprint) {
    if (fingerprint.length != 64) return fingerprint;
    
    final buffer = StringBuffer();
    for (int i = 0; i < fingerprint.length; i += 2) {
      if (i > 0) buffer.write(':');
      buffer.write(fingerprint.substring(i, i + 2).toUpperCase());
    }
    return buffer.toString();
  }

  /// Validate fingerprint format
  static bool isValidFingerprint(String fingerprint) {
    // SHA-256 fingerprint should be 64 hex characters
    final regex = RegExp(r'^[a-fA-F0-9]{64}$');
    return regex.hasMatch(fingerprint);
  }
}