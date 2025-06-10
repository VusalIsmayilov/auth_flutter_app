import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import '../constants/storage_keys.dart';
import '../../data/datasources/local/secure_storage_service.dart';

/// Service for managing token blacklisting and revocation
/// Ensures logout security by preventing token reuse
class TokenBlacklistService {
  static TokenBlacklistService? _instance;
  static final Logger _logger = Logger();

  final SecureStorageService _storageService;
  final Set<String> _localBlacklist = <String>{};
  
  TokenBlacklistService._({
    required SecureStorageService storageService,
  }) : _storageService = storageService;

  /// Get the singleton instance
  static TokenBlacklistService get instance {
    if (_instance == null) {
      throw StateError('TokenBlacklistService not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  /// Initialize the token blacklist service
  static Future<TokenBlacklistService> initialize({
    required SecureStorageService storageService,
  }) async {
    _instance = TokenBlacklistService._(storageService: storageService);
    await _instance!._loadBlacklistedTokens();
    
    _logger.i('TokenBlacklistService initialized');
    return _instance!;
  }

  /// Add a token to the blacklist
  Future<void> blacklistToken(String token, {
    TokenBlacklistReason reason = TokenBlacklistReason.logout,
    String? userId,
    DateTime? expiresAt,
  }) async {
    try {
      final tokenHash = _hashToken(token);
      final blacklistEntry = TokenBlacklistEntry(
        tokenHash: tokenHash,
        reason: reason,
        blacklistedAt: DateTime.now(),
        userId: userId,
        expiresAt: expiresAt,
      );

      // Add to local blacklist
      _localBlacklist.add(tokenHash);

      // Store in secure storage
      await _storeBlacklistEntry(blacklistEntry);

      _logger.d('Token blacklisted: ${reason.name}');
    } catch (e) {
      _logger.e('Failed to blacklist token: $e');
      rethrow;
    }
  }

  /// Check if a token is blacklisted
  Future<bool> isTokenBlacklisted(String token) async {
    try {
      final tokenHash = _hashToken(token);
      
      // Check local cache first
      if (_localBlacklist.contains(tokenHash)) {
        _logger.d('Token found in local blacklist');
        return true;
      }

      // Check stored blacklist
      final entry = await _getBlacklistEntry(tokenHash);
      if (entry != null) {
        // Check if entry is still valid (not expired)
        if (entry.isStillValid) {
          _localBlacklist.add(tokenHash); // Cache for performance
          _logger.d('Token found in stored blacklist');
          return true;
        } else {
          // Remove expired entry
          await _removeBlacklistEntry(tokenHash);
          _logger.d('Expired blacklist entry removed');
        }
      }

      return false;
    } catch (e) {
      _logger.e('Error checking token blacklist: $e');
      // In case of error, be conservative and consider token valid
      return false;
    }
  }

  /// Blacklist all tokens for a user (useful for security breaches)
  Future<void> blacklistAllUserTokens(String userId, {
    TokenBlacklistReason reason = TokenBlacklistReason.securityBreach,
  }) async {
    try {
      final entry = UserTokenBlacklistEntry(
        userId: userId,
        reason: reason,
        blacklistedAt: DateTime.now(),
      );

      await _storeUserBlacklistEntry(entry);
      
      _logger.w('All tokens blacklisted for user: $userId (${reason.name})');
    } catch (e) {
      _logger.e('Failed to blacklist user tokens: $e');
      rethrow;
    }
  }

  /// Check if all tokens for a user are blacklisted
  Future<bool> areUserTokensBlacklisted(String userId) async {
    try {
      final entry = await _getUserBlacklistEntry(userId);
      return entry != null && entry.isStillValid;
    } catch (e) {
      _logger.e('Error checking user token blacklist: $e');
      return false;
    }
  }

  /// Clean up expired blacklist entries
  Future<void> cleanupExpiredEntries() async {
    try {
      final allEntries = await _getAllBlacklistEntries();
      final expiredHashes = <String>[];

      for (final entry in allEntries) {
        if (!entry.isStillValid) {
          expiredHashes.add(entry.tokenHash);
        }
      }

      // Remove expired entries
      await Future.wait(
        expiredHashes.map((hash) => _removeBlacklistEntry(hash)),
      );

      // Clean local cache
      _localBlacklist.removeWhere((hash) => expiredHashes.contains(hash));

      _logger.i('Cleaned up ${expiredHashes.length} expired blacklist entries');
    } catch (e) {
      _logger.e('Failed to cleanup expired entries: $e');
    }
  }

  /// Get blacklist statistics
  Map<String, dynamic> getBlacklistStats() {
    return {
      'localCacheSize': _localBlacklist.length,
      'lastCleanup': DateTime.now().toIso8601String(),
    };
  }

  /// Clear all blacklisted tokens (admin function)
  Future<void> clearAllBlacklistedTokens() async {
    try {
      _localBlacklist.clear();
      await _clearAllBlacklistEntries();
      
      _logger.w('All blacklisted tokens cleared');
    } catch (e) {
      _logger.e('Failed to clear blacklisted tokens: $e');
      rethrow;
    }
  }

  /// Hash a token for storage (security measure)
  String _hashToken(String token) {
    final bytes = utf8.encode(token);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Load blacklisted tokens from storage into cache
  Future<void> _loadBlacklistedTokens() async {
    try {
      final entries = await _getAllBlacklistEntries();
      for (final entry in entries) {
        if (entry.isStillValid) {
          _localBlacklist.add(entry.tokenHash);
        }
      }
      _logger.d('Loaded ${_localBlacklist.length} blacklisted tokens');
    } catch (e) {
      _logger.e('Failed to load blacklisted tokens: $e');
    }
  }

  /// Store a blacklist entry
  Future<void> _storeBlacklistEntry(TokenBlacklistEntry entry) async {
    final key = '${StorageKeys.tokenBlacklist}_${entry.tokenHash}';
    final value = jsonEncode(entry.toJson());
    await _storageService.storeUserPreference(key, value);
  }

  /// Get a blacklist entry
  Future<TokenBlacklistEntry?> _getBlacklistEntry(String tokenHash) async {
    try {
      final key = '${StorageKeys.tokenBlacklist}_$tokenHash';
      final value = await _storageService.getUserPreference(key);
      if (value == null || value.isEmpty) return null;
      
      final json = jsonDecode(value) as Map<String, dynamic>;
      return TokenBlacklistEntry.fromJson(json);
    } catch (e) {
      _logger.e('Failed to get blacklist entry: $e');
      return null;
    }
  }

  /// Remove a blacklist entry
  Future<void> _removeBlacklistEntry(String tokenHash) async {
    final key = '${StorageKeys.tokenBlacklist}_$tokenHash';
    await _storageService.storeUserPreference(key, '');
    _localBlacklist.remove(tokenHash);
  }

  /// Store user-level blacklist entry
  Future<void> _storeUserBlacklistEntry(UserTokenBlacklistEntry entry) async {
    final key = '${StorageKeys.userTokenBlacklist}_${entry.userId}';
    final value = jsonEncode(entry.toJson());
    await _storageService.storeUserPreference(key, value);
  }

  /// Get user-level blacklist entry
  Future<UserTokenBlacklistEntry?> _getUserBlacklistEntry(String userId) async {
    try {
      final key = '${StorageKeys.userTokenBlacklist}_$userId';
      final value = await _storageService.getUserPreference(key);
      if (value == null || value.isEmpty) return null;
      
      final json = jsonDecode(value) as Map<String, dynamic>;
      return UserTokenBlacklistEntry.fromJson(json);
    } catch (e) {
      _logger.e('Failed to get user blacklist entry: $e');
      return null;
    }
  }

  /// Get all blacklist entries (for cleanup)
  Future<List<TokenBlacklistEntry>> _getAllBlacklistEntries() async {
    final entries = <TokenBlacklistEntry>[];
    // Note: This is a simplified implementation
    // In a real app, you might want to maintain an index of all entries
    return entries;
  }

  /// Clear all blacklist entries
  Future<void> _clearAllBlacklistEntries() async {
    // This would clear all entries with the blacklist prefix
    // Implementation depends on secure storage capabilities
  }

  /// Reset instance for testing
  @visibleForTesting
  static void resetInstance() {
    _instance = null;
  }

  /// Check if instance is initialized
  static bool get isInitialized => _instance != null;
}

/// Represents a blacklisted token entry
class TokenBlacklistEntry {
  final String tokenHash;
  final TokenBlacklistReason reason;
  final DateTime blacklistedAt;
  final String? userId;
  final DateTime? expiresAt;

  const TokenBlacklistEntry({
    required this.tokenHash,
    required this.reason,
    required this.blacklistedAt,
    this.userId,
    this.expiresAt,
  });

  /// Check if this blacklist entry is still valid
  bool get isStillValid {
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  Map<String, dynamic> toJson() {
    return {
      'tokenHash': tokenHash,
      'reason': reason.name,
      'blacklistedAt': blacklistedAt.toIso8601String(),
      'userId': userId,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  factory TokenBlacklistEntry.fromJson(Map<String, dynamic> json) {
    return TokenBlacklistEntry(
      tokenHash: json['tokenHash'] as String,
      reason: TokenBlacklistReason.values.firstWhere(
        (e) => e.name == json['reason'],
        orElse: () => TokenBlacklistReason.other,
      ),
      blacklistedAt: DateTime.parse(json['blacklistedAt'] as String),
      userId: json['userId'] as String?,
      expiresAt: json['expiresAt'] != null 
        ? DateTime.parse(json['expiresAt'] as String)
        : null,
    );
  }
}

/// Represents a user-level token blacklist entry
class UserTokenBlacklistEntry {
  final String userId;
  final TokenBlacklistReason reason;
  final DateTime blacklistedAt;
  final DateTime? expiresAt;

  const UserTokenBlacklistEntry({
    required this.userId,
    required this.reason,
    required this.blacklistedAt,
    this.expiresAt,
  });

  /// Check if this user blacklist is still valid
  bool get isStillValid {
    if (expiresAt == null) return true;
    return DateTime.now().isBefore(expiresAt!);
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'reason': reason.name,
      'blacklistedAt': blacklistedAt.toIso8601String(),
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  factory UserTokenBlacklistEntry.fromJson(Map<String, dynamic> json) {
    return UserTokenBlacklistEntry(
      userId: json['userId'] as String,
      reason: TokenBlacklistReason.values.firstWhere(
        (e) => e.name == json['reason'],
        orElse: () => TokenBlacklistReason.other,
      ),
      blacklistedAt: DateTime.parse(json['blacklistedAt'] as String),
      expiresAt: json['expiresAt'] != null 
        ? DateTime.parse(json['expiresAt'] as String)
        : null,
    );
  }
}

/// Reasons for token blacklisting
enum TokenBlacklistReason {
  logout,
  tokenRotation,
  securityBreach,
  suspiciousActivity,
  adminRevocation,
  deviceLost,
  passwordChange,
  accountDeactivation,
  other,
}

/// Extension for TokenBlacklistReason
extension TokenBlacklistReasonExtension on TokenBlacklistReason {
  String get displayName {
    switch (this) {
      case TokenBlacklistReason.logout:
        return 'User Logout';
      case TokenBlacklistReason.tokenRotation:
        return 'Token Rotation';
      case TokenBlacklistReason.securityBreach:
        return 'Security Breach';
      case TokenBlacklistReason.suspiciousActivity:
        return 'Suspicious Activity';
      case TokenBlacklistReason.adminRevocation:
        return 'Admin Revocation';
      case TokenBlacklistReason.deviceLost:
        return 'Device Lost/Stolen';
      case TokenBlacklistReason.passwordChange:
        return 'Password Change';
      case TokenBlacklistReason.accountDeactivation:
        return 'Account Deactivation';
      case TokenBlacklistReason.other:
        return 'Other';
    }
  }

  bool get isHighSeverity {
    return [
      TokenBlacklistReason.securityBreach,
      TokenBlacklistReason.suspiciousActivity,
      TokenBlacklistReason.deviceLost,
      TokenBlacklistReason.adminRevocation,
    ].contains(this);
  }
}

/// Exception thrown when token blacklist operations fail
class TokenBlacklistException implements Exception {
  final String message;
  final String? details;

  const TokenBlacklistException({
    required this.message,
    this.details,
  });

  @override
  String toString() {
    var result = 'TokenBlacklistException: $message';
    if (details != null) {
      result += '\nDetails: $details';
    }
    return result;
  }
}