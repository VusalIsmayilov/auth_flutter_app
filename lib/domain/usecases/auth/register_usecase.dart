import '../../../core/errors/exceptions.dart';
import '../../../core/security/password_policy.dart';
import '../../../data/models/auth_response_model.dart';
import '../../../data/models/login_request_model.dart';
import '../../repositories/auth_repository.dart';
import '../../../services/jwt_service.dart';
import '../../../config/environment_config.dart';

class RegisterUseCase {
  final AuthRepository _authRepository;
  final JwtService _jwtService;
  final PasswordPolicy _passwordPolicy;

  RegisterUseCase({
    required AuthRepository authRepository,
    required JwtService jwtService,
    PasswordPolicy? passwordPolicy,
  })  : _authRepository = authRepository,
        _jwtService = jwtService,
        _passwordPolicy = passwordPolicy ?? PasswordPolicy.forEnvironment(EnvironmentService.config.environment.name);

  Future<AuthResponseModel> call(RegisterRequestModel request) async {
    try {
      // Validate input
      _validateRegisterRequest(request);

      // Perform registration
      final authResponse = await _authRepository.register(request);

      // Start token refresh timer
      await _jwtService.startTokenRefreshTimer();

      return authResponse;
    } catch (e) {
      rethrow;
    }
  }

  void _validateRegisterRequest(RegisterRequestModel request) {
    final errors = <String, List<String>>{};

    // Email validation
    if (request.email.isEmpty) {
      errors['email'] = ['Email is required'];
    } else if (!_isValidEmail(request.email)) {
      errors['email'] = ['Please enter a valid email address'];
    }

    // Comprehensive password validation using password policy
    if (request.password.isEmpty) {
      errors['password'] = ['Password is required'];
    } else {
      final passwordValidation = _passwordPolicy.validatePassword(
        request.password,
        userEmail: request.email,
      );
      
      if (!passwordValidation.isValid) {
        errors['password'] = passwordValidation.errors;
      }
      
      // Add warnings as additional validation notes
      if (passwordValidation.warnings.isNotEmpty) {
        errors['password_warnings'] = passwordValidation.warnings;
      }
    }

    // Name validation removed - now using email/password only registration

    if (errors.isNotEmpty) {
      throw ValidationException(
        message: 'Registration validation failed',
        fieldErrors: errors,
      );
    }
  }

  /// Get password policy instance for external access
  PasswordPolicy get passwordPolicy => _passwordPolicy;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}