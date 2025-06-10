import '../../../core/errors/exceptions.dart';
import '../../../data/models/auth_response_model.dart';
import '../../repositories/auth_repository.dart';
import '../../../services/jwt_service.dart';

class RefreshTokenUseCase {
  final AuthRepository _authRepository;
  final JwtService _jwtService;

  RefreshTokenUseCase({
    required AuthRepository authRepository,
    required JwtService jwtService,
  })  : _authRepository = authRepository,
        _jwtService = jwtService;

  Future<TokenModel> call() async {
    try {
      // Attempt to refresh token
      final newToken = await _authRepository.refreshToken();

      // Restart token refresh timer with new expiry
      await _jwtService.startTokenRefreshTimer();

      return newToken;
    } on AuthenticationException {
      // Token refresh failed, stop timer and clear tokens
      await _jwtService.stopTokenRefreshTimer();
      rethrow;
    } catch (e) {
      // For other errors, also stop timer
      await _jwtService.stopTokenRefreshTimer();
      rethrow;
    }
  }

  Future<bool> isTokenValid() async {
    return await _authRepository.hasValidToken();
  }

  Future<String?> getValidAccessToken() async {
    try {
      return await _jwtService.getValidAccessToken();
    } catch (e) {
      return null;
    }
  }
}