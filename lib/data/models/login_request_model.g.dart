// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'login_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$LoginRequestModelImpl _$$LoginRequestModelImplFromJson(
        Map<String, dynamic> json) =>
    _$LoginRequestModelImpl(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$$LoginRequestModelImplToJson(
        _$LoginRequestModelImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };

_$RegisterRequestModelImpl _$$RegisterRequestModelImplFromJson(
        Map<String, dynamic> json) =>
    _$RegisterRequestModelImpl(
      email: json['email'] as String,
      password: json['password'] as String,
    );

Map<String, dynamic> _$$RegisterRequestModelImplToJson(
        _$RegisterRequestModelImpl instance) =>
    <String, dynamic>{
      'email': instance.email,
      'password': instance.password,
    };

_$RefreshTokenRequestModelImpl _$$RefreshTokenRequestModelImplFromJson(
        Map<String, dynamic> json) =>
    _$RefreshTokenRequestModelImpl(
      refreshToken: json['refreshToken'] as String,
      deviceId: json['deviceId'] as String?,
    );

Map<String, dynamic> _$$RefreshTokenRequestModelImplToJson(
        _$RefreshTokenRequestModelImpl instance) =>
    <String, dynamic>{
      'refreshToken': instance.refreshToken,
      'deviceId': instance.deviceId,
    };
