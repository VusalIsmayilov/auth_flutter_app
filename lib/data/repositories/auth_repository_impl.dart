import 'package:dio/dio.dart';
import '../../core/errors/exceptions.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/secure_storage_service.dart';
import '../datasources/remote/auth_api_service.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/user_model.dart';
import '../models/email_verification_models.dart';
import '../models/forgot_password_models.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthApiService _apiService;
  final SecureStorageService _storageService;

  AuthRepositoryImpl({
    required AuthApiService apiService,
    required SecureStorageService storageService,
  }) : _apiService = apiService,
       _storageService = storageService;

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _apiService.loginEmail(request);
      await _storageService.storeAuthResponse(response);
      if (response.tokens != null) {
        await _storageService.storeToken(response.tokens!);
      }
      return response;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Login failed',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      final response = await _apiService.registerEmail(request);
      await _storageService.storeAuthResponse(response);
      if (response.tokens != null) {
        await _storageService.storeToken(response.tokens!);
      }
      return response;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Registration failed',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<TokenModel> refreshToken() async {
    try {
      final currentRefreshToken = await _storageService.getRefreshToken();
      if (currentRefreshToken == null) {
        throw CacheException(message: 'No refresh token found');
      }

      final request = RefreshTokenRequestModel(
        refreshToken: currentRefreshToken,
      );
      final newToken = await _apiService.refreshToken(request);
      await _storageService.storeToken(newToken);
      return newToken;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _storageService.clearTokens();
        throw AuthenticationException(message: 'Refresh token expired');
      }
      throw ServerException(
        message: e.response?.data['message'] ?? 'Token refresh failed',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _apiService.revokeAllTokens();
    } catch (e) {
      // Even if API call fails, we should clear local storage
    } finally {
      await _storageService.clearAll();
    }
  }

  @override
  Future<UserModel> getUserProfile() async {
    try {
      return await _apiService.getUserProfile();
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to get user profile',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> profileData) async {
    try {
      return await _apiService.updateProfile(profileData);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to update profile',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<bool> hasValidToken() async {
    return await _storageService.hasValidToken();
  }

  @override
  Future<String?> getAccessToken() async {
    return await _storageService.getAccessToken();
  }

  @override
  Future<AuthResponseModel?> getCachedAuthResponse() async {
    return await _storageService.getAuthResponse();
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final request = ForgotPasswordRequestModel(email: email);
      await _apiService.forgotPassword(request);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to send reset email',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      final request = ResetPasswordRequestModel(
        token: token,
        newPassword: newPassword,
      );
      await _apiService.resetPassword(request);
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to reset password',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<bool> validateResetToken(String token) async {
    try {
      final request = ValidateResetTokenRequestModel(token: token);
      await _apiService.validateResetToken(request);
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        return false; // Invalid or expired token
      }
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to validate token',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    try {
      await _apiService.changePassword({
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to change password',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<bool> isTokenValid() async {
    return await _storageService.hasValidToken();
  }

  @override
  Future<EmailVerificationResponseModel> verifyEmail(String email, String verificationCode) async {
    try {
      final request = VerifyEmailRequestModel(
        email: email,
        verificationCode: verificationCode,
      );
      final response = await _apiService.verifyEmail(request);
      return response;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Email verification failed',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred');
    }
  }

  @override
  Future<EmailVerificationResponseModel> resendVerification(String email) async {
    try {
      final request = ResendVerificationRequestModel(email: email);
      final response = await _apiService.resendVerification(request);
      return response;
    } on DioException catch (e) {
      throw ServerException(
        message: e.response?.data['message'] ?? 'Failed to resend verification email',
        statusCode: e.response?.statusCode ?? 500,
      );
    } catch (e) {
      throw ServerException(message: 'Unexpected error occurred');
    }
  }
}
