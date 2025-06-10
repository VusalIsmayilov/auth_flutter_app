class StorageKeys {
  static const String accessToken = 'access_token';
  static const String refreshToken = 'refresh_token';
  static const String authResponse = 'auth_response';
  static const String userProfile = 'user_profile';
  static const String biometricEnabled = 'biometric_enabled';
  static const String rememberMe = 'remember_me';
  static const String deviceId = 'device_id';
  static const String fcmToken = 'fcm_token';
  static const String lastLoginTime = 'last_login_time';
  static const String sessionId = 'session_id';
  static const String requestSigningApiKey = 'request_signing_api_key';
  static const String requestSigningSecretKey = 'request_signing_secret_key';
  static const String tokenBlacklist = 'token_blacklist';
  static const String userTokenBlacklist = 'user_token_blacklist';
  
  static const String keyPrefix = 'auth_app_';
  
  static String withPrefix(String key) => '$keyPrefix$key';
}