import '../../core/errors/exceptions.dart';
import '../../core/network/http_client.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/secure_storage_service.dart';
import '../models/auth_response_model.dart';
import '../models/login_request_model.dart';
import '../models/user_model.dart';
import '../models/email_verification_models.dart';

class AuthRepositoryHttpImpl implements AuthRepository {
  final SecureStorageService _storageService;

  AuthRepositoryHttpImpl({
    required SecureStorageService storageService,
  }) : _storageService = storageService;

  @override
  Future<AuthResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await HttpClientService.post(
        '/auth/login/email',
        data: request.toJson(),
      );
      
      if (!response.isSuccess) {
        throw ServerException(
          message: response.data?['message'] ?? 'Login failed',
          statusCode: response.statusCode,
        );
      }
      
      if (response.data == null) {
        throw ServerException(message: 'No data received from server');
      }
      
      final authResponse = AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      await _storageService.storeAuthResponse(authResponse);
      if (authResponse.tokens != null) {
        await _storageService.storeToken(authResponse.tokens!);
      }
      return authResponse;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<AuthResponseModel> register(RegisterRequestModel request) async {
    try {
      print('DEBUG: Repository sending registration request: ${request.toJson()}');
      final response = await HttpClientService.post(
        '/auth/register/email',
        data: request.toJson(),
      );
      
      if (!response.isSuccess) {
        throw ServerException(
          message: response.data?['message'] ?? 'Registration failed',
          statusCode: response.statusCode,
        );
      }
      
      if (response.data == null) {
        throw ServerException(message: 'No data received from server');
      }
      
      final authResponse = AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      await _storageService.storeAuthResponse(authResponse);
      if (authResponse.tokens != null) {
        await _storageService.storeToken(authResponse.tokens!);
      }
      return authResponse;
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final token = await _storageService.getAccessToken();
      if (token != null) {
        await HttpClientService.post(
          '/auth/logout',
          headers: {'Authorization': 'Bearer $token'},
        );
      }
    } catch (e) {
      // Log but don't throw - logout should succeed even if server call fails
      print('Logout server call failed: $e');
    } finally {
      await _storageService.clearTokens();
    }
  }

  @override
  Future<TokenModel> refreshToken() async {
    try {
      final refreshToken = await _storageService.getRefreshToken();
      if (refreshToken == null) {
        throw ServerException(message: 'No refresh token available');
      }

      final response = await HttpClientService.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );
      
      if (!response.isSuccess) {
        throw ServerException(
          message: response.data?['message'] ?? 'Token refresh failed',
          statusCode: response.statusCode,
        );
      }
      
      if (response.data == null) {
        throw ServerException(message: 'No data received from server');
      }
      
      final authResponse = AuthResponseModel.fromJson(response.data as Map<String, dynamic>);
      await _storageService.storeAuthResponse(authResponse);
      if (authResponse.tokens != null) {
        await _storageService.storeToken(authResponse.tokens!);
        return authResponse.tokens!;
      }
      throw ServerException(message: 'No tokens in refresh response');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<UserModel> getUserProfile() async {
    try {
      final token = await _storageService.getAccessToken();
      if (token == null) {
        throw ServerException(message: 'No access token available');
      }

      final response = await HttpClientService.get(
        '/auth/me',
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (!response.isSuccess) {
        throw ServerException(
          message: response.data?['message'] ?? 'Failed to get user profile',
          statusCode: response.statusCode,
        );
      }
      
      if (response.data == null) {
        throw ServerException(message: 'No user data received from server');
      }
      
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<UserModel> updateProfile(Map<String, dynamic> data) async {
    try {
      final token = await _storageService.getAccessToken();
      if (token == null) {
        throw ServerException(message: 'No access token available');
      }

      // Convert camelCase to PascalCase for backend compatibility
      final backendData = <String, dynamic>{};
      if (data.containsKey('firstName')) {
        backendData['FirstName'] = data['firstName'];
      }
      if (data.containsKey('lastName')) {
        backendData['LastName'] = data['lastName'];
      }
      if (data.containsKey('phoneNumber')) {
        backendData['PhoneNumber'] = data['phoneNumber'];
      }
      
      print('DEBUG: Attempting profile update with backend data: $backendData');
      final response = await HttpClientService.put(
        '/auth/me',
        data: backendData,
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (!response.isSuccess) {
        throw ServerException(
          message: response.data?['message'] ?? 'Failed to update profile',
          statusCode: response.statusCode,
        );
      }
      
      if (response.data == null) {
        throw ServerException(message: 'No user data received from server');
      }
      
      return UserModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final response = await HttpClientService.post(
        '/auth/forgot-password',
        data: {'email': email},
      );
      
      if (!response.isSuccess) {
        throw ServerException(
          message: response.data?['message'] ?? 'Failed to send reset email',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<void> resetPassword(String token, String newPassword) async {
    try {
      final response = await HttpClientService.post(
        '/auth/reset-password',
        data: {
          'token': token,
          'newPassword': newPassword,
        },
      );
      
      if (!response.isSuccess) {
        throw ServerException(
          message: response.data?['message'] ?? 'Failed to reset password',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<EmailVerificationResponseModel> verifyEmail(String token) async {
    try {
      final response = await HttpClientService.post(
        '/auth/verify-email',
        data: {'token': token},
      );
      
      if (!response.isSuccess) {
        throw ServerException(
          message: response.data?['message'] ?? 'Email verification failed',
          statusCode: response.statusCode,
        );
      }
      
      if (response.data == null) {
        throw ServerException(message: 'No data received from server');
      }
      
      return EmailVerificationResponseModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<EmailVerificationResponseModel> resendVerification(String email) async {
    try {
      final response = await HttpClientService.post(
        '/auth/resend-verification',
        data: {'email': email},
      );
      
      if (!response.isSuccess) {
        throw ServerException(
          message: response.data?['message'] ?? 'Failed to resend verification email',
          statusCode: response.statusCode,
        );
      }
      
      if (response.data == null) {
        throw ServerException(message: 'No data received from server');
      }
      
      return EmailVerificationResponseModel.fromJson(response.data as Map<String, dynamic>);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<bool> hasValidToken() async {
    final token = await _storageService.getAccessToken();
    return token != null && await isTokenValid();
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
  Future<bool> validateResetToken(String token) async {
    try {
      final response = await HttpClientService.post(
        '/auth/validate-reset-token',
        data: {'token': token},
      );
      return response.isSuccess;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> changePassword(String currentPassword, String newPassword) async {
    try {
      final token = await _storageService.getAccessToken();
      if (token == null) {
        throw ServerException(message: 'No access token available');
      }

      final response = await HttpClientService.post(
        '/auth/change-password',
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
        headers: {'Authorization': 'Bearer $token'},
      );
      
      if (!response.isSuccess) {
        throw ServerException(
          message: response.data?['message'] ?? 'Failed to change password',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: 'Unexpected error occurred: $e');
    }
  }

  @override
  Future<bool> isTokenValid() async {
    try {
      final token = await _storageService.getAccessToken();
      if (token == null) return false;

      final response = await HttpClientService.get(
        '/auth/validate-token',
        headers: {'Authorization': 'Bearer $token'},
      );
      return response.isSuccess;
    } catch (e) {
      return false;
    }
  }
}