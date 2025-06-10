import 'package:freezed_annotation/freezed_annotation.dart';
import 'user_model.dart';

part 'auth_response_model.freezed.dart';
part 'auth_response_model.g.dart';

@freezed
class AuthResponseModel with _$AuthResponseModel {
  const factory AuthResponseModel({
    required bool success,
    required String message,
    TokenModel? tokens,
    UserModel? user,
  }) = _AuthResponseModel;

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);
}

@freezed
class TokenModel with _$TokenModel {
  const TokenModel._();
  
  const factory TokenModel({
    required String accessToken,
    required String refreshToken,
    required DateTime accessTokenExpiresAt,
    required DateTime refreshTokenExpiresAt,
    @Default('Bearer') String tokenType,
  }) = _TokenModel;

  factory TokenModel.fromJson(Map<String, dynamic> json) =>
      _$TokenModelFromJson(json);
  
  bool get isExpired => DateTime.now().isAfter(accessTokenExpiresAt);
  
  bool get isExpiringSoon => 
      DateTime.now().add(const Duration(minutes: 5)).isAfter(accessTokenExpiresAt);
  
  Duration get timeUntilExpiry => accessTokenExpiresAt.difference(DateTime.now());
  
  // Legacy compatibility - use accessTokenExpiresAt as the primary expiry
  DateTime get expiresAt => accessTokenExpiresAt;
}