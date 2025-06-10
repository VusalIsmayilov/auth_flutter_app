import '../../../core/errors/exceptions.dart';
import '../../../data/models/auth_response_model.dart';
import '../../../data/models/login_request_model.dart';
import '../../repositories/auth_repository.dart';
import '../../../services/jwt_service.dart';

class RegisterUseCase {
  final AuthRepository _authRepository;
  final JwtService _jwtService;

  RegisterUseCase({
    required AuthRepository authRepository,
    required JwtService jwtService,
  })  : _authRepository = authRepository,
        _jwtService = jwtService;

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

    // Password validation
    if (request.password.isEmpty) {
      errors['password'] = ['Password is required'];
    } else {
      final passwordErrors = _validatePassword(request.password);
      if (passwordErrors.isNotEmpty) {
        errors['password'] = passwordErrors;
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

  List<String> _validatePassword(String password) {
    final errors = <String>[];

    if (password.length < 8) {
      errors.add('Password must be at least 8 characters long');
    }

    if (!password.contains(RegExp(r'[A-Z]'))) {
      errors.add('Password must contain at least one uppercase letter');
    }

    if (!password.contains(RegExp(r'[a-z]'))) {
      errors.add('Password must contain at least one lowercase letter');
    }

    if (!password.contains(RegExp(r'[0-9]'))) {
      errors.add('Password must contain at least one number');
    }

    if (!password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      errors.add('Password must contain at least one special character');
    }

    return errors;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}