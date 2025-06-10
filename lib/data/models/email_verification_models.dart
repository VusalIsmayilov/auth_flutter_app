import 'package:freezed_annotation/freezed_annotation.dart';

part 'email_verification_models.freezed.dart';
part 'email_verification_models.g.dart';

@freezed
class VerifyEmailRequestModel with _$VerifyEmailRequestModel {
  const factory VerifyEmailRequestModel({
    required String email,
    required String verificationCode,
  }) = _VerifyEmailRequestModel;

  factory VerifyEmailRequestModel.fromJson(Map<String, dynamic> json) =>
      _$VerifyEmailRequestModelFromJson(json);
}

@freezed
class ResendVerificationRequestModel with _$ResendVerificationRequestModel {
  const factory ResendVerificationRequestModel({
    required String email,
  }) = _ResendVerificationRequestModel;

  factory ResendVerificationRequestModel.fromJson(Map<String, dynamic> json) =>
      _$ResendVerificationRequestModelFromJson(json);
}

@freezed
class EmailVerificationResponseModel with _$EmailVerificationResponseModel {
  const factory EmailVerificationResponseModel({
    required String message,
    required bool success,
    String? email,
    DateTime? verifiedAt,
  }) = _EmailVerificationResponseModel;

  factory EmailVerificationResponseModel.fromJson(Map<String, dynamic> json) =>
      _$EmailVerificationResponseModelFromJson(json);
}