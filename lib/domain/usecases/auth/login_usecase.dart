import '../../../core/errors/exceptions.dart';
import '../../../data/models/auth_response_model.dart';
import '../../../data/models/login_request_model.dart';
import '../../repositories/auth_repository.dart';
import '../../../services/jwt_service.dart';

class LoginUseCase {
  final AuthRepository _authRepository;
  final JwtService _jwtService;

  LoginUseCase({
    required AuthRepository authRepository,
    required JwtService jwtService,
  })  : _authRepository = authRepository,
        _jwtService = jwtService;

  Future<AuthResponseModel> call(LoginRequestModel request) async {
    try {
      // Validate input
      _validateLoginRequest(request);

      // Perform login
      final authResponse = await _authRepository.login(request);

      // Start token refresh timer
      await _jwtService.startTokenRefreshTimer();

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  void _validateLoginRequest(LoginRequestModel request) {
    if (request.email.isEmpty) {
      throw ValidationException(
        message: 'Email is required',
        fieldErrors: {'email': ['Email cannot be empty']},
      );
    }

    if (!_isValidEmail(request.email)) {
      throw ValidationException(
        message: 'Invalid email format',
        fieldErrors: {'email': ['Please enter a valid email address']},
      );
    }

    if (request.password.isEmpty) {
      throw ValidationException(
        message: 'Password is required',
        fieldErrors: {'password': ['Password cannot be empty']},
      );
    }

    if (request.password.length < 6) {
      throw ValidationException(
        message: 'Password too short',
        fieldErrors: {'password': ['Password must be at least 6 characters']},
      );
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}