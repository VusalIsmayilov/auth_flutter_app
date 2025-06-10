import '../../repositories/auth_repository.dart';
import '../../../services/jwt_service.dart';

class LogoutUseCase {
  final AuthRepository _authRepository;
  final JwtService _jwtService;

  LogoutUseCase({
    required AuthRepository authRepository,
    required JwtService jwtService,
  })  : _authRepository = authRepository,
        _jwtService = jwtService;

  Future<void> call() async {
    try {
      // Stop token refresh timer
      await _jwtService.stopTokenRefreshTimer();

      // Perform logout (clears tokens and calls API)
      await _authRepository.logout();
    } catch (e) {
      // Even if logout fails, we should dispose the JWT service
      _jwtService.dispose();
      rethrow;
    }
  }
}