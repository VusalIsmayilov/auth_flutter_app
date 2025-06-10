import '../../data/models/auth_response_model.dart';
import '../../data/models/login_request_model.dart';
import '../../data/models/user_model.dart';
import '../../data/models/email_verification_models.dart';

abstract class AuthRepository {
  Future<AuthResponseModel> login(LoginRequestModel request);
  Future<AuthResponseModel> register(RegisterRequestModel request);
  Future<TokenModel> refreshToken();
  Future<void> logout();
  Future<UserModel> getUserProfile();
  Future<UserModel> updateProfile(Map<String, dynamic> profileData);
  Future<bool> hasValidToken();
  Future<String?> getAccessToken();
  Future<AuthResponseModel?> getCachedAuthResponse();
  Future<void> forgotPassword(String email);
  Future<bool> validateResetToken(String token);
  Future<void> resetPassword(String token, String newPassword);
  Future<void> changePassword(String currentPassword, String newPassword);
  Future<bool> isTokenValid();
  Future<EmailVerificationResponseModel> verifyEmail(String email, String verificationCode);
  Future<EmailVerificationResponseModel> resendVerification(String email);
}