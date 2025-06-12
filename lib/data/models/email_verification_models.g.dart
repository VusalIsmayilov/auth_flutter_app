// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'email_verification_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$VerifyEmailRequestModelImpl _$$VerifyEmailRequestModelImplFromJson(
        Map<String, dynamic> json) =>
    _$VerifyEmailRequestModelImpl(
      token: json['token'] as String,
    );

Map<String, dynamic> _$$VerifyEmailRequestModelImplToJson(
        _$VerifyEmailRequestModelImpl instance) =>
    <String, dynamic>{
      'token': instance.token,
    };

_$ResendVerificationRequestModelImpl
    _$$ResendVerificationRequestModelImplFromJson(Map<String, dynamic> json) =>
        _$ResendVerificationRequestModelImpl(
          email: json['email'] as String,
        );

Map<String, dynamic> _$$ResendVerificationRequestModelImplToJson(
        _$ResendVerificationRequestModelImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
    };

_$EmailVerificationResponseModelImpl
    _$$EmailVerificationResponseModelImplFromJson(Map<String, dynamic> json) =>
        _$EmailVerificationResponseModelImpl(
          message: json['message'] as String,
          success: json['success'] as bool,
          email: json['email'] as String?,
          verifiedAt: json['verifiedAt'] == null
              ? null
              : DateTime.parse(json['verifiedAt'] as String),
        );

Map<String, dynamic> _$$EmailVerificationResponseModelImplToJson(
        _$EmailVerificationResponseModelImpl instance) =>
    <String, dynamic>{
      'message': instance.message,
      'success': instance.success,
      'email': instance.email,
      'verifiedAt': instance.verifiedAt?.toIso8601String(),
    };
