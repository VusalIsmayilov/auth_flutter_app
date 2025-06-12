class ApiEndpoints {
  static const String baseUrl = 'http://192.168.1.156:5001/api';
  
  // Authentication endpoints - Updated to match backend AuthController
  static const String loginEmail = '/auth/login/email';
  static const String loginPhone = '/auth/login/phone';
  static const String registerEmail = '/auth/register/email';
  static const String registerPhone = '/auth/register/phone';
  static const String verifyOtp = '/auth/verify-otp';
  static const String sendOtp = '/auth/send-otp';
  static const String refreshToken = '/auth/refresh';
  static const String revokeToken = '/auth/revoke';
  static const String revokeAllTokens = '/auth/revoke-all';
  static const String getCurrentUser = '/auth/me';
  static const String verifyEmail = '/auth/verify-email';
  static const String resendVerification = '/auth/resend-verification';
  
  // Password reset endpoints
  static const String forgotPassword = '/auth/forgot-password';
  static const String validateResetToken = '/auth/validate-reset-token';
  static const String resetPassword = '/auth/reset-password';
  
  // Legacy endpoints for backwards compatibility
  static const String legacyLoginEmail = '/auth/legacy/login/email';
  static const String legacyRegisterEmail = '/auth/legacy/register/email';
  
  // User endpoints
  static const String profile = '/user/profile';
  static const String updateProfile = '/user/profile';
  static const String changePassword = '/user/change-password';
  static const String deleteAccount = '/user/delete';
  
  // Admin endpoints
  static const String users = '/admin/users';
  static const String userDetails = '/admin/users/{id}';
  static const String userRoles = '/admin/users/{id}/roles';
  
  // Protected resources
  static const String dashboard = '/dashboard';
  static const String settings = '/settings';
  
  static String getUserDetailsUrl(String userId) =>
      userDetails.replaceAll('{id}', userId);
  
  static String getUserRolesUrl(String userId) =>
      userRoles.replaceAll('{id}', userId);
}