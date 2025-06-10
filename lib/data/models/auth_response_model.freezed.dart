// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'auth_response_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

AuthResponseModel _$AuthResponseModelFromJson(Map<String, dynamic> json) {
  return _AuthResponseModel.fromJson(json);
}

/// @nodoc
mixin _$AuthResponseModel {
  bool get success => throw _privateConstructorUsedError;
  String get message => throw _privateConstructorUsedError;
  TokenModel? get tokens => throw _privateConstructorUsedError;
  UserModel? get user => throw _privateConstructorUsedError;

  /// Serializes this AuthResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of AuthResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $AuthResponseModelCopyWith<AuthResponseModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $AuthResponseModelCopyWith<$Res> {
  factory $AuthResponseModelCopyWith(
          AuthResponseModel value, $Res Function(AuthResponseModel) then) =
      _$AuthResponseModelCopyWithImpl<$Res, AuthResponseModel>;
  @useResult
  $Res call(
      {bool success, String message, TokenModel? tokens, UserModel? user});

  $TokenModelCopyWith<$Res>? get tokens;
  $UserModelCopyWith<$Res>? get user;
}

/// @nodoc
class _$AuthResponseModelCopyWithImpl<$Res, $Val extends AuthResponseModel>
    implements $AuthResponseModelCopyWith<$Res> {
  _$AuthResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of AuthResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? tokens = freezed,
    Object? user = freezed,
  }) {
    return _then(_value.copyWith(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      tokens: freezed == tokens
          ? _value.tokens
          : tokens // ignore: cast_nullable_to_non_nullable
              as TokenModel?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel?,
    ) as $Val);
  }

  /// Create a copy of AuthResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $TokenModelCopyWith<$Res>? get tokens {
    if (_value.tokens == null) {
      return null;
    }

    return $TokenModelCopyWith<$Res>(_value.tokens!, (value) {
      return _then(_value.copyWith(tokens: value) as $Val);
    });
  }

  /// Create a copy of AuthResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @pragma('vm:prefer-inline')
  $UserModelCopyWith<$Res>? get user {
    if (_value.user == null) {
      return null;
    }

    return $UserModelCopyWith<$Res>(_value.user!, (value) {
      return _then(_value.copyWith(user: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$AuthResponseModelImplCopyWith<$Res>
    implements $AuthResponseModelCopyWith<$Res> {
  factory _$$AuthResponseModelImplCopyWith(_$AuthResponseModelImpl value,
          $Res Function(_$AuthResponseModelImpl) then) =
      __$$AuthResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {bool success, String message, TokenModel? tokens, UserModel? user});

  @override
  $TokenModelCopyWith<$Res>? get tokens;
  @override
  $UserModelCopyWith<$Res>? get user;
}

/// @nodoc
class __$$AuthResponseModelImplCopyWithImpl<$Res>
    extends _$AuthResponseModelCopyWithImpl<$Res, _$AuthResponseModelImpl>
    implements _$$AuthResponseModelImplCopyWith<$Res> {
  __$$AuthResponseModelImplCopyWithImpl(_$AuthResponseModelImpl _value,
      $Res Function(_$AuthResponseModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of AuthResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? success = null,
    Object? message = null,
    Object? tokens = freezed,
    Object? user = freezed,
  }) {
    return _then(_$AuthResponseModelImpl(
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      tokens: freezed == tokens
          ? _value.tokens
          : tokens // ignore: cast_nullable_to_non_nullable
              as TokenModel?,
      user: freezed == user
          ? _value.user
          : user // ignore: cast_nullable_to_non_nullable
              as UserModel?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$AuthResponseModelImpl implements _AuthResponseModel {
  const _$AuthResponseModelImpl(
      {required this.success, required this.message, this.tokens, this.user});

  factory _$AuthResponseModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$AuthResponseModelImplFromJson(json);

  @override
  final bool success;
  @override
  final String message;
  @override
  final TokenModel? tokens;
  @override
  final UserModel? user;

  @override
  String toString() {
    return 'AuthResponseModel(success: $success, message: $message, tokens: $tokens, user: $user)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$AuthResponseModelImpl &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.tokens, tokens) || other.tokens == tokens) &&
            (identical(other.user, user) || other.user == user));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, success, message, tokens, user);

  /// Create a copy of AuthResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$AuthResponseModelImplCopyWith<_$AuthResponseModelImpl> get copyWith =>
      __$$AuthResponseModelImplCopyWithImpl<_$AuthResponseModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$AuthResponseModelImplToJson(
      this,
    );
  }
}

abstract class _AuthResponseModel implements AuthResponseModel {
  const factory _AuthResponseModel(
      {required final bool success,
      required final String message,
      final TokenModel? tokens,
      final UserModel? user}) = _$AuthResponseModelImpl;

  factory _AuthResponseModel.fromJson(Map<String, dynamic> json) =
      _$AuthResponseModelImpl.fromJson;

  @override
  bool get success;
  @override
  String get message;
  @override
  TokenModel? get tokens;
  @override
  UserModel? get user;

  /// Create a copy of AuthResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$AuthResponseModelImplCopyWith<_$AuthResponseModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TokenModel _$TokenModelFromJson(Map<String, dynamic> json) {
  return _TokenModel.fromJson(json);
}

/// @nodoc
mixin _$TokenModel {
  String get accessToken => throw _privateConstructorUsedError;
  String get refreshToken => throw _privateConstructorUsedError;
  DateTime get accessTokenExpiresAt => throw _privateConstructorUsedError;
  DateTime get refreshTokenExpiresAt => throw _privateConstructorUsedError;
  String get tokenType => throw _privateConstructorUsedError;

  /// Serializes this TokenModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TokenModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TokenModelCopyWith<TokenModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TokenModelCopyWith<$Res> {
  factory $TokenModelCopyWith(
          TokenModel value, $Res Function(TokenModel) then) =
      _$TokenModelCopyWithImpl<$Res, TokenModel>;
  @useResult
  $Res call(
      {String accessToken,
      String refreshToken,
      DateTime accessTokenExpiresAt,
      DateTime refreshTokenExpiresAt,
      String tokenType});
}

/// @nodoc
class _$TokenModelCopyWithImpl<$Res, $Val extends TokenModel>
    implements $TokenModelCopyWith<$Res> {
  _$TokenModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TokenModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? accessTokenExpiresAt = null,
    Object? refreshTokenExpiresAt = null,
    Object? tokenType = null,
  }) {
    return _then(_value.copyWith(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      accessTokenExpiresAt: null == accessTokenExpiresAt
          ? _value.accessTokenExpiresAt
          : accessTokenExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      refreshTokenExpiresAt: null == refreshTokenExpiresAt
          ? _value.refreshTokenExpiresAt
          : refreshTokenExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tokenType: null == tokenType
          ? _value.tokenType
          : tokenType // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TokenModelImplCopyWith<$Res>
    implements $TokenModelCopyWith<$Res> {
  factory _$$TokenModelImplCopyWith(
          _$TokenModelImpl value, $Res Function(_$TokenModelImpl) then) =
      __$$TokenModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String accessToken,
      String refreshToken,
      DateTime accessTokenExpiresAt,
      DateTime refreshTokenExpiresAt,
      String tokenType});
}

/// @nodoc
class __$$TokenModelImplCopyWithImpl<$Res>
    extends _$TokenModelCopyWithImpl<$Res, _$TokenModelImpl>
    implements _$$TokenModelImplCopyWith<$Res> {
  __$$TokenModelImplCopyWithImpl(
      _$TokenModelImpl _value, $Res Function(_$TokenModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of TokenModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? accessToken = null,
    Object? refreshToken = null,
    Object? accessTokenExpiresAt = null,
    Object? refreshTokenExpiresAt = null,
    Object? tokenType = null,
  }) {
    return _then(_$TokenModelImpl(
      accessToken: null == accessToken
          ? _value.accessToken
          : accessToken // ignore: cast_nullable_to_non_nullable
              as String,
      refreshToken: null == refreshToken
          ? _value.refreshToken
          : refreshToken // ignore: cast_nullable_to_non_nullable
              as String,
      accessTokenExpiresAt: null == accessTokenExpiresAt
          ? _value.accessTokenExpiresAt
          : accessTokenExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      refreshTokenExpiresAt: null == refreshTokenExpiresAt
          ? _value.refreshTokenExpiresAt
          : refreshTokenExpiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
      tokenType: null == tokenType
          ? _value.tokenType
          : tokenType // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TokenModelImpl extends _TokenModel {
  const _$TokenModelImpl(
      {required this.accessToken,
      required this.refreshToken,
      required this.accessTokenExpiresAt,
      required this.refreshTokenExpiresAt,
      this.tokenType = 'Bearer'})
      : super._();

  factory _$TokenModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TokenModelImplFromJson(json);

  @override
  final String accessToken;
  @override
  final String refreshToken;
  @override
  final DateTime accessTokenExpiresAt;
  @override
  final DateTime refreshTokenExpiresAt;
  @override
  @JsonKey()
  final String tokenType;

  @override
  String toString() {
    return 'TokenModel(accessToken: $accessToken, refreshToken: $refreshToken, accessTokenExpiresAt: $accessTokenExpiresAt, refreshTokenExpiresAt: $refreshTokenExpiresAt, tokenType: $tokenType)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TokenModelImpl &&
            (identical(other.accessToken, accessToken) ||
                other.accessToken == accessToken) &&
            (identical(other.refreshToken, refreshToken) ||
                other.refreshToken == refreshToken) &&
            (identical(other.accessTokenExpiresAt, accessTokenExpiresAt) ||
                other.accessTokenExpiresAt == accessTokenExpiresAt) &&
            (identical(other.refreshTokenExpiresAt, refreshTokenExpiresAt) ||
                other.refreshTokenExpiresAt == refreshTokenExpiresAt) &&
            (identical(other.tokenType, tokenType) ||
                other.tokenType == tokenType));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, accessToken, refreshToken,
      accessTokenExpiresAt, refreshTokenExpiresAt, tokenType);

  /// Create a copy of TokenModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TokenModelImplCopyWith<_$TokenModelImpl> get copyWith =>
      __$$TokenModelImplCopyWithImpl<_$TokenModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TokenModelImplToJson(
      this,
    );
  }
}

abstract class _TokenModel extends TokenModel {
  const factory _TokenModel(
      {required final String accessToken,
      required final String refreshToken,
      required final DateTime accessTokenExpiresAt,
      required final DateTime refreshTokenExpiresAt,
      final String tokenType}) = _$TokenModelImpl;
  const _TokenModel._() : super._();

  factory _TokenModel.fromJson(Map<String, dynamic> json) =
      _$TokenModelImpl.fromJson;

  @override
  String get accessToken;
  @override
  String get refreshToken;
  @override
  DateTime get accessTokenExpiresAt;
  @override
  DateTime get refreshTokenExpiresAt;
  @override
  String get tokenType;

  /// Create a copy of TokenModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TokenModelImplCopyWith<_$TokenModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
