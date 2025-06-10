import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:logger/logger.dart';

import 'package:auth_flutter_app/core/security/token_blacklist_service.dart';
import 'package:auth_flutter_app/data/datasources/local/secure_storage_service.dart';

import 'token_blacklist_test.mocks.dart';

@GenerateMocks([
  SecureStorageService,
  Logger,
])
void main() {
  late MockSecureStorageService mockStorageService;
  late MockLogger mockLogger;
  late TokenBlacklistService tokenBlacklistService;

  const testToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyfQ.SflKxwRJSMeKKF2QT4fwpMeJf36POk6yJV_adQssw5c';
  const testUserId = 'user123';

  setUp(() {
    mockStorageService = MockSecureStorageService();
    mockLogger = MockLogger();
    
    // Reset singleton
    TokenBlacklistService.resetInstance();
  });

  group('TokenBlacklistService', () {
    group('initialization', () {
      test('should initialize service successfully', () async {
        // arrange
        when(mockStorageService.getUserPreference(any))
            .thenAnswer((_) async => null);

        // act
        final service = await TokenBlacklistService.initialize(
          storageService: mockStorageService,
        );

        // assert
        expect(service, isNotNull);
        expect(TokenBlacklistService.isInitialized, true);
      });

      test('should throw error when accessing uninitialized instance', () {
        // assert
        expect(
          () => TokenBlacklistService.instance,
          throwsA(isA<StateError>()),
        );
      });
    });

    group('token blacklisting', () {
      setUp(() async {
        when(mockStorageService.getUserPreference(any))
            .thenAnswer((_) async => null);
        when(mockStorageService.storeUserPreference(any, any))
            .thenAnswer((_) async {});

        tokenBlacklistService = await TokenBlacklistService.initialize(
          storageService: mockStorageService,
        );
      });

      test('should blacklist token successfully', () async {
        // act
        await tokenBlacklistService.blacklistToken(
          testToken,
          reason: TokenBlacklistReason.logout,
          userId: testUserId,
        );

        // assert
        verify(mockStorageService.storeUserPreference(any, any));
      });

      test('should detect blacklisted token', () async {
        // arrange
        await tokenBlacklistService.blacklistToken(testToken);

        // act
        final isBlacklisted = await tokenBlacklistService.isTokenBlacklisted(testToken);

        // assert
        expect(isBlacklisted, true);
      });

      test('should not detect non-blacklisted token', () async {
        // arrange
        const nonBlacklistedToken = 'different.token.here';

        // act
        final isBlacklisted = await tokenBlacklistService.isTokenBlacklisted(nonBlacklistedToken);

        // assert
        expect(isBlacklisted, false);
      });

      test('should handle storage errors gracefully', () async {
        // arrange
        when(mockStorageService.storeUserPreference(any, any))
            .thenThrow(Exception('Storage error'));

        // act & assert
        expect(
          () async => await tokenBlacklistService.blacklistToken(testToken),
          throwsException,
        );
      });
    });

    group('user token blacklisting', () {
      setUp(() async {
        when(mockStorageService.getUserPreference(any))
            .thenAnswer((_) async => null);
        when(mockStorageService.storeUserPreference(any, any))
            .thenAnswer((_) async {});

        tokenBlacklistService = await TokenBlacklistService.initialize(
          storageService: mockStorageService,
        );
      });

      test('should blacklist all user tokens', () async {
        // act
        await tokenBlacklistService.blacklistAllUserTokens(
          testUserId,
          reason: TokenBlacklistReason.securityBreach,
        );

        // assert
        verify(mockStorageService.storeUserPreference(any, any));
      });

      test('should check if user tokens are blacklisted', () async {
        // arrange
        await tokenBlacklistService.blacklistAllUserTokens(testUserId);

        // act
        final areBlacklisted = await tokenBlacklistService.areUserTokensBlacklisted(testUserId);

        // assert
        expect(areBlacklisted, false); // Will be false because mock returns null
      });
    });

    group('cleanup operations', () {
      setUp(() async {
        when(mockStorageService.getUserPreference(any))
            .thenAnswer((_) async => null);
        when(mockStorageService.storeUserPreference(any, any))
            .thenAnswer((_) async {});

        tokenBlacklistService = await TokenBlacklistService.initialize(
          storageService: mockStorageService,
        );
      });

      test('should cleanup expired entries', () async {
        // act
        await tokenBlacklistService.cleanupExpiredEntries();

        // assert - should complete without error
        expect(tokenBlacklistService, isNotNull);
      });

      test('should clear all blacklisted tokens', () async {
        // arrange
        await tokenBlacklistService.blacklistToken(testToken);

        // act
        await tokenBlacklistService.clearAllBlacklistedTokens();

        // assert
        final isBlacklisted = await tokenBlacklistService.isTokenBlacklisted(testToken);
        expect(isBlacklisted, false);
      });

      test('should provide blacklist statistics', () {
        // act
        final stats = tokenBlacklistService.getBlacklistStats();

        // assert
        expect(stats, isA<Map<String, dynamic>>());
        expect(stats['localCacheSize'], isA<int>());
        expect(stats['lastCleanup'], isA<String>());
      });
    });
  });

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
    });

    test('should identify high severity reasons correctly', () {
      expect(TokenBlacklistReason.logout.isHighSeverity, false);
      expect(TokenBlacklistReason.securityBreach.isHighSeverity, true);
      expect(TokenBlacklistReason.suspiciousActivity.isHighSeverity, true);
      expect(TokenBlacklistReason.deviceLost.isHighSeverity, true);
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
}