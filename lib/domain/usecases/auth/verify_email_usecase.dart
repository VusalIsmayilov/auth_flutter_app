import '../../../core/errors/failures.dart';
import '../../../data/models/email_verification_models.dart';
import '../../repositories/auth_repository.dart';

class VerifyEmailUseCase {
  final AuthRepository _authRepository;

  const VerifyEmailUseCase(this._authRepository);

  Future<EmailVerificationResponseModel> execute(String email, String verificationCode) async {
    if (email.isEmpty) {
      throw const ValidationFailure(message: 'Email is required');
    }

    if (verificationCode.isEmpty) {
      throw const ValidationFailure(message: 'Verification code is required');
    }

    if (verificationCode.length != 6) {
      throw const ValidationFailure(message: 'Verification code must be 6 digits');
    }

    if (!RegExp(r'^[0-9]+$').hasMatch(verificationCode)) {
      throw const ValidationFailure(message: 'Verification code must contain only numbers');
    }

    try {
      return await _authRepository.verifyEmail(email, verificationCode);
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