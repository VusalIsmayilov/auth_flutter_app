import 'package:flutter_test/flutter_test.dart';
import 'package:auth_flutter_app/core/security/token_blacklist_service.dart';
import 'package:auth_flutter_app/core/security/token_blacklist_interceptor.dart';

void main() {
  group('TokenBlacklistEntry', () {
    test('should create entry with required fields', () {
      // arrange
      final now = DateTime.now();
      
      // act
      final entry = TokenBlacklistEntry(
        tokenHash: 'hash123',
        reason: TokenBlacklistReason.logout,
        blacklistedAt: now,
      );

      // assert
      expect(entry.tokenHash, 'hash123');
      expect(entry.reason, TokenBlacklistReason.logout);
      expect(entry.blacklistedAt, now);
    });

    test('should check validity correctly', () {
      // arrange
      final now = DateTime.now();
      final futureExpiry = now.add(const Duration(hours: 1));
      final pastExpiry = now.subtract(const Duration(hours: 1));

      final validEntry = TokenBlacklistEntry(
        tokenHash: 'hash1',
        reason: TokenBlacklistReason.logout,
        blacklistedAt: now,
        expiresAt: futureExpiry,
      );

      final expiredEntry = TokenBlacklistEntry(
        tokenHash: 'hash2',
        reason: TokenBlacklistReason.logout,
        blacklistedAt: now,
        expiresAt: pastExpiry,
      );

      final neverExpiresEntry = TokenBlacklistEntry(
        tokenHash: 'hash3',
        reason: TokenBlacklistReason.logout,
        blacklistedAt: now,
      );

      // assert
      expect(validEntry.isStillValid, true);
      expect(expiredEntry.isStillValid, false);
      expect(neverExpiresEntry.isStillValid, true);
    });

    test('should serialize to JSON correctly', () {
      // arrange
      final now = DateTime.now();
      final entry = TokenBlacklistEntry(
        tokenHash: 'hash123',
        reason: TokenBlacklistReason.logout,
        blacklistedAt: now,
        userId: 'user123',
      );

      // act
      final json = entry.toJson();

      // assert
      expect(json['tokenHash'], 'hash123');
      expect(json['reason'], 'logout');
      expect(json['blacklistedAt'], now.toIso8601String());
      expect(json['userId'], 'user123');
    });

    test('should deserialize from JSON correctly', () {
      // arrange
      final now = DateTime.now();
      final json = {
        'tokenHash': 'hash123',
        'reason': 'logout',
        'blacklistedAt': now.toIso8601String(),
        'userId': 'user123',
      };

      // act
      final entry = TokenBlacklistEntry.fromJson(json);

      // assert
      expect(entry.tokenHash, 'hash123');
      expect(entry.reason, TokenBlacklistReason.logout);
      expect(entry.blacklistedAt, now);
      expect(entry.userId, 'user123');
    });
  });

  group('UserTokenBlacklistEntry', () {
    test('should create user entry correctly', () {
      // arrange
      final now = DateTime.now();
      
      // act
      final entry = UserTokenBlacklistEntry(
        userId: 'user123',
        reason: TokenBlacklistReason.securityBreach,
        blacklistedAt: now,
      );

      // assert
      expect(entry.userId, 'user123');
      expect(entry.reason, TokenBlacklistReason.securityBreach);
      expect(entry.blacklistedAt, now);
    });

    test('should serialize and deserialize correctly', () {
      // arrange
      final now = DateTime.now();
      final entry = UserTokenBlacklistEntry(
        userId: 'user123',
        reason: TokenBlacklistReason.securityBreach,
        blacklistedAt: now,
      );

      // act
      final json = entry.toJson();
      final reconstructed = UserTokenBlacklistEntry.fromJson(json);

      // assert
      expect(reconstructed.userId, entry.userId);
      expect(reconstructed.reason, entry.reason);
      expect(reconstructed.blacklistedAt, entry.blacklistedAt);
    });
  });

  group('TokenBlacklistReason', () {
    test('should have correct display names', () {
      expect(TokenBlacklistReason.logout.displayName, 'User Logout');
      expect(TokenBlacklistReason.securityBreach.displayName, 'Security Breach');
      expect(TokenBlacklistReason.suspiciousActivity.displayName, 'Suspicious Activity');
      expect(TokenBlacklistReason.adminRevocation.displayName, 'Admin Revocation');
      expect(TokenBlacklistReason.deviceLost.displayName, 'Device Lost/Stolen');
      expect(TokenBlacklistReason.passwordChange.displayName, 'Password Change');
      expect(TokenBlacklistReason.accountDeactivation.displayName, 'Account Deactivation');
      expect(TokenBlacklistReason.tokenRotation.displayName, 'Token Rotation');
      expect(TokenBlacklistReason.other.displayName, 'Other');
    });

    test('should identify high severity reasons correctly', () {
      expect(TokenBlacklistReason.logout.isHighSeverity, false);
      expect(TokenBlacklistReason.tokenRotation.isHighSeverity, false);
      expect(TokenBlacklistReason.passwordChange.isHighSeverity, false);
      expect(TokenBlacklistReason.other.isHighSeverity, false);
      
      expect(TokenBlacklistReason.securityBreach.isHighSeverity, true);
      expect(TokenBlacklistReason.suspiciousActivity.isHighSeverity, true);
      expect(TokenBlacklistReason.deviceLost.isHighSeverity, true);
      expect(TokenBlacklistReason.adminRevocation.isHighSeverity, true);
    });
  });

  group('TokenBlacklistException', () {
    test('should create exception with message', () {
      const exception = TokenBlacklistException(message: 'Test error');
      
      expect(exception.message, 'Test error');
      expect(exception.details, null);
      expect(exception.toString(), 'TokenBlacklistException: Test error');
    });

    test('should create exception with message and details', () {
      const exception = TokenBlacklistException(
        message: 'Test error',
        details: 'Additional details',
      );
      
      expect(exception.message, 'Test error');
      expect(exception.details, 'Additional details');
      expect(exception.toString(), contains('TokenBlacklistException: Test error'));
      expect(exception.toString(), contains('Details: Additional details'));
    });
  });

  group('TokenBlacklistUtils', () {
    test('should identify reasons requiring immediate action', () {
      expect(TokenBlacklistUtils.requiresImmediateAction(TokenBlacklistReason.logout), false);
      expect(TokenBlacklistUtils.requiresImmediateAction(TokenBlacklistReason.tokenRotation), false);
      
      expect(TokenBlacklistUtils.requiresImmediateAction(TokenBlacklistReason.securityBreach), true);
      expect(TokenBlacklistUtils.requiresImmediateAction(TokenBlacklistReason.suspiciousActivity), true);
      expect(TokenBlacklistUtils.requiresImmediateAction(TokenBlacklistReason.deviceLost), true);
      expect(TokenBlacklistUtils.requiresImmediateAction(TokenBlacklistReason.adminRevocation), true);
    });

    test('should provide correct cleanup intervals', () {
      final productionInterval = TokenBlacklistUtils.getCleanupInterval(isProduction: true);
      final developmentInterval = TokenBlacklistUtils.getCleanupInterval(isProduction: false);
      
      expect(productionInterval, const Duration(hours: 6));
      expect(developmentInterval, const Duration(hours: 24));
    });

    test('should calculate blacklist expiry correctly', () {
      final originalExpiry = DateTime.now().add(const Duration(hours: 2));
      final blacklistExpiry = TokenBlacklistUtils.calculateBlacklistExpiry(originalExpiry);
      
      expect(blacklistExpiry, isNotNull);
      expect(blacklistExpiry!.isAfter(originalExpiry), true);
      expect(blacklistExpiry.difference(originalExpiry), const Duration(days: 1));
      
      final nullExpiry = TokenBlacklistUtils.calculateBlacklistExpiry(null);
      expect(nullExpiry, null);
    });

    test('should validate token format correctly', () {
      // Valid JWT format (3 parts separated by dots)
      const validToken = 'header.payload.signature';
      expect(TokenBlacklistUtils.isValidTokenFormat(validToken), true);
      
      // Invalid formats
      expect(TokenBlacklistUtils.isValidTokenFormat('invalid'), false);
      expect(TokenBlacklistUtils.isValidTokenFormat('only.two'), false);
      expect(TokenBlacklistUtils.isValidTokenFormat('header..signature'), false);
      expect(TokenBlacklistUtils.isValidTokenFormat(''), false);
    });
  });
}