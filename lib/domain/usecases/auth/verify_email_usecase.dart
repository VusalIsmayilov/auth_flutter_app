import '../../../core/errors/failures.dart';
import '../../../data/models/email_verification_models.dart';
import '../../repositories/auth_repository.dart';

class VerifyEmailUseCase {
  final AuthRepository _authRepository;

  const VerifyEmailUseCase(this._authRepository);

  Future<EmailVerificationResponseModel> execute(String token) async {
    if (token.isEmpty) {
      throw const ValidationFailure(message: 'Verification token is required');
    }

    try {
      return await _authRepository.verifyEmail(token);
    } catch (e) {
      rethrow;
    }
  }
}

class ResendVerificationUseCase {
  final AuthRepository _authRepository;

  const ResendVerificationUseCase(this._authRepository);

  Future<EmailVerificationResponseModel> execute(String email) async {
    if (email.isEmpty) {
      throw const ValidationFailure(message: 'Email is required');
    }

    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(email)) {
      throw const ValidationFailure(message: 'Please enter a valid email address');
    }

    try {
      return await _authRepository.resendVerification(email);
    } catch (e) {
      rethrow;
    }
  }
}