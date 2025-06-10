import '../../../core/errors/failures.dart';
import '../../../data/models/forgot_password_models.dart';
import '../../repositories/auth_repository.dart';

class ForgotPasswordUseCase {
  final AuthRepository _authRepository;

  ForgotPasswordUseCase(this._authRepository);

  Future<PasswordResetResponseModel> execute(String email, {String? redirectUrl}) async {
    try {
      await _authRepository.forgotPassword(email);
      
      return const PasswordResetResponseModel(
        message: 'Password reset email sent successfully. Please check your inbox.',
        success: true,
      );
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
}

class ValidateResetTokenUseCase {
  final AuthRepository _authRepository;

  ValidateResetTokenUseCase(this._authRepository);

  Future<bool> execute(String token) async {
    try {
      return await _authRepository.validateResetToken(token);
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
}

class ResetPasswordUseCase {
  final AuthRepository _authRepository;

  ResetPasswordUseCase(this._authRepository);

  Future<PasswordResetResponseModel> execute({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    if (newPassword != confirmPassword) {
      throw ValidationFailure(message: 'Passwords do not match');
    }

    if (newPassword.length < 6) {
      throw ValidationFailure(message: 'Password must be at least 6 characters long');
    }

    try {
      await _authRepository.resetPassword(token, newPassword);
      
      return const PasswordResetResponseModel(
        message: 'Password reset successfully. You can now login with your new password.',
        success: true,
      );
    } catch (e) {
      throw ServerFailure(message: e.toString());
    }
  }
}