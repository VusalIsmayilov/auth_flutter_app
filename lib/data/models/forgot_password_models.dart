import 'package:freezed_annotation/freezed_annotation.dart';

part 'forgot_password_models.freezed.dart';
part 'forgot_password_models.g.dart';

@freezed
class ForgotPasswordRequestModel with _$ForgotPasswordRequestModel {
  const factory ForgotPasswordRequestModel({
    required String email,
  }) = _ForgotPasswordRequestModel;

  factory ForgotPasswordRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ForgotPasswordRequestModelFromJson(json);
}

@freezed
class ResetPasswordRequestModel with _$ResetPasswordRequestModel {
  const factory ResetPasswordRequestModel({
    required String token,
    required String newPassword,
  }) = _ResetPasswordRequestModel;

  factory ResetPasswordRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ResetPasswordRequestModelFromJson(json);
}

@freezed
class ValidateResetTokenRequestModel with _$ValidateResetTokenRequestModel {
  const factory ValidateResetTokenRequestModel({
    required String token,
  }) = _ValidateResetTokenRequestModel;

  factory ValidateResetTokenRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ValidateResetTokenRequestModelFromJson(json);
}

@freezed
class PasswordResetResponseModel with _$PasswordResetResponseModel {
  const factory PasswordResetResponseModel({
    required String message,
    required bool success,
    String? resetToken,
    DateTime? expiresAt,
  }) = _PasswordResetResponseModel;

  factory PasswordResetResponseModel.fromJson(Map<String, dynamic> json) =>
      _$PasswordResetResponseModelFromJson(json);
}