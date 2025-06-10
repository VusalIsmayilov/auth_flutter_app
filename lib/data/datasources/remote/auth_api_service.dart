import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../models/auth_response_model.dart';
import '../../models/login_request_model.dart';
import '../../models/user_model.dart';
import '../../models/email_verification_models.dart';
import '../../models/forgot_password_models.dart';

part 'auth_api_service.g.dart';

@RestApi(baseUrl: ApiEndpoints.baseUrl)
abstract class AuthApiService {
  factory AuthApiService(Dio dio, {String baseUrl}) = _AuthApiService;

  // Email-based authentication
  @POST(ApiEndpoints.loginEmail)
  Future<AuthResponseModel> loginEmail(@Body() LoginRequestModel request);

  @POST(ApiEndpoints.registerEmail)
  Future<AuthResponseModel> registerEmail(@Body() RegisterRequestModel request);

  // Phone-based authentication
  @POST(ApiEndpoints.loginPhone)
  Future<AuthResponseModel> loginPhone(@Body() Map<String, String> request);

  @POST(ApiEndpoints.registerPhone)
  Future<AuthResponseModel> registerPhone(@Body() Map<String, String> request);

  @POST(ApiEndpoints.verifyOtp)
  Future<AuthResponseModel> verifyOtp(@Body() Map<String, String> request);

  @POST(ApiEndpoints.sendOtp)
  Future<AuthResponseModel> sendOtp(@Body() Map<String, String> request);

  // Token management
  @POST(ApiEndpoints.refreshToken)
  Future<TokenModel> refreshToken(@Body() RefreshTokenRequestModel request);

  @POST(ApiEndpoints.revokeToken)
  Future<void> revokeToken(@Body() Map<String, String> request);

  @POST(ApiEndpoints.revokeAllTokens)
  Future<void> revokeAllTokens();

  // User profile
  @GET(ApiEndpoints.getCurrentUser)
  Future<UserModel> getUserProfile();

  @PUT(ApiEndpoints.updateProfile)
  Future<UserModel> updateProfile(@Body() Map<String, dynamic> profileData);

  // Email verification
  @POST(ApiEndpoints.verifyEmail)
  Future<EmailVerificationResponseModel> verifyEmail(@Body() VerifyEmailRequestModel request);

  @POST(ApiEndpoints.resendVerification)
  Future<EmailVerificationResponseModel> resendVerification(@Body() ResendVerificationRequestModel request);

  // Password management
  @POST(ApiEndpoints.forgotPassword)
  Future<PasswordResetResponseModel> forgotPassword(@Body() ForgotPasswordRequestModel request);

  @POST(ApiEndpoints.validateResetToken)
  Future<PasswordResetResponseModel> validateResetToken(@Body() ValidateResetTokenRequestModel request);

  @POST(ApiEndpoints.resetPassword)
  Future<PasswordResetResponseModel> resetPassword(@Body() ResetPasswordRequestModel request);

  @POST(ApiEndpoints.changePassword)
  Future<void> changePassword(@Body() Map<String, String> passwordData);

  @DELETE(ApiEndpoints.deleteAccount)
  Future<void> deleteAccount();
}