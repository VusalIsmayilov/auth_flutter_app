import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:crypto/crypto.dart';
import '../../../core/constants/storage_keys.dart';
import '../../models/auth_response_model.dart';

class SecureStorageService {
  static const _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  static String _generateKey(String key) {
    final bytes = utf8.encode(key);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  Future<void> storeToken(TokenModel token) async {
    final tokenJson = jsonEncode(token.toJson());
    await _storage.write(
      key: _generateKey(StorageKeys.accessToken),
      value: tokenJson,
    );
  }

  Future<void> storeAuthResponse(AuthResponseModel authResponse) async {
    final authJson = jsonEncode(authResponse.toJson());
    await _storage.write(
      key: _generateKey(StorageKeys.authResponse),
      value: authJson,
    );
  }

  Future<TokenModel?> getToken() async {
    try {
      final tokenJson = await _storage.read(
        key: _generateKey(StorageKeys.accessToken),
      );
      if (tokenJson == null) return null;
      
      final tokenMap = jsonDecode(tokenJson) as Map<String, dynamic>;
      return TokenModel.fromJson(tokenMap);
    } catch (e) {
      return null;
    }
  }

  Future<AuthResponseModel?> getAuthResponse() async {
    try {
      final authJson = await _storage.read(
        key: _generateKey(StorageKeys.authResponse),
      );
      if (authJson == null) return null;
      
      final authMap = jsonDecode(authJson) as Map<String, dynamic>;
      return AuthResponseModel.fromJson(authMap);
    } catch (e) {
      return null;
    }
  }

  Future<String?> getAccessToken() async {
    final token = await getToken();
    return token?.accessToken;
  }

  Future<String?> getRefreshToken() async {
    final token = await getToken();
    return token?.refreshToken;
  }

  Future<bool> hasValidToken() async {
    final token = await getToken();
    return token != null && !token.isExpired;
  }

  Future<bool> isTokenExpiringSoon() async {
    final token = await getToken();
    return token?.isExpiringSoon ?? true;
  }

  Future<void> clearTokens() async {
    await Future.wait([
      _storage.delete(key: _generateKey(StorageKeys.accessToken)),
      _storage.delete(key: _generateKey(StorageKeys.authResponse)),
    ]);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<void> storeUserPreference(String key, String value) async {
    await _storage.write(
      key: _generateKey('pref_$key'),
      value: value,
    );
  }

  Future<String?> getUserPreference(String key) async {
    return await _storage.read(key: _generateKey('pref_$key'));
  }

  Future<void> storeBiometricEnabled(bool enabled) async {
    await storeUserPreference('biometric_enabled', enabled.toString());
  }

  Future<bool> isBiometricEnabled() async {
    final value = await getUserPreference('biometric_enabled');
    return value == 'true';
  }
}