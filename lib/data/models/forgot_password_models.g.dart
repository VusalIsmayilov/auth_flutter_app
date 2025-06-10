// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'forgot_password_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ForgotPasswordRequestModelImpl _$$ForgotPasswordRequestModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ForgotPasswordRequestModelImpl(
      email: json['email'] as String,
    );

Map<String, dynamic> _$$ForgotPasswordRequestModelImplToJson(
        _$ForgotPasswordRequestModelImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
    };

_$ResetPasswordRequestModelImpl _$$ResetPasswordRequestModelImplFromJson(
        Map<String, dynamic> json) =>
    _$ResetPasswordRequestModelImpl(
      token: json['token'] as String,
      newPassword: json['newPassword'] as String,
    );

Map<String, dynamic> _$$ResetPasswordRequestModelImplToJson(
        _$ResetPasswordRequestModelImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
      'newPassword': instance.newPassword,
    };

_$ValidateResetTokenRequestModelImpl
    _$$ValidateResetTokenRequestModelImplFromJson(Map<String, dynamic> json) =>
        _$ValidateResetTokenRequestModelImpl(
          token: json['token'] as String,
        );

Map<String, dynamic> _$$ValidateResetTokenRequestModelImplToJson(
        _$ValidateResetTokenRequestModelImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
    };

_$PasswordResetResponseModelImpl _$$PasswordResetResponseModelImplFromJson(
        Map<String, dynamic> json) =>
    _$PasswordResetResponseModelImpl(
      message: json['message'] as String,
      success: json['success'] as bool,
      resetToken: json['resetToken'] as String?,
      expiresAt: json['expiresAt'] == null
          ? null
          : DateTime.parse(json['expiresAt'] as String),
    );

Map<String, dynamic> _$$PasswordResetResponseModelImplToJson(
        _$PasswordResetResponseModelImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
      'resetToken': instance.resetToken,
      'expiresAt': instance.expiresAt?.toIso8601String(),
    };
