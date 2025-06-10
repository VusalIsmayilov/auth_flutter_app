// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'forgot_password_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

ForgotPasswordRequestModel _$ForgotPasswordRequestModelFromJson(
    Map<String, dynamic> json) {
  return _ForgotPasswordRequestModel.fromJson(json);
}

/// @nodoc
mixin _$ForgotPasswordRequestModel {
  String get email => throw _privateConstructorUsedError;

  /// Serializes this ForgotPasswordRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ForgotPasswordRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ForgotPasswordRequestModelCopyWith<ForgotPasswordRequestModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ForgotPasswordRequestModelCopyWith<$Res> {
  factory $ForgotPasswordRequestModelCopyWith(ForgotPasswordRequestModel value,
          $Res Function(ForgotPasswordRequestModel) then) =
      _$ForgotPasswordRequestModelCopyWithImpl<$Res,
          ForgotPasswordRequestModel>;
  @useResult
  $Res call({String email});
}

/// @nodoc
class _$ForgotPasswordRequestModelCopyWithImpl<$Res,
        $Val extends ForgotPasswordRequestModel>
    implements $ForgotPasswordRequestModelCopyWith<$Res> {
  _$ForgotPasswordRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ForgotPasswordRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
  }) {
    return _then(_value.copyWith(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ForgotPasswordRequestModelImplCopyWith<$Res>
    implements $ForgotPasswordRequestModelCopyWith<$Res> {
  factory _$$ForgotPasswordRequestModelImplCopyWith(
          _$ForgotPasswordRequestModelImpl value,
          $Res Function(_$ForgotPasswordRequestModelImpl) then) =
      __$$ForgotPasswordRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email});
}

/// @nodoc
class __$$ForgotPasswordRequestModelImplCopyWithImpl<$Res>
    extends _$ForgotPasswordRequestModelCopyWithImpl<$Res,
        _$ForgotPasswordRequestModelImpl>
    implements _$$ForgotPasswordRequestModelImplCopyWith<$Res> {
  __$$ForgotPasswordRequestModelImplCopyWithImpl(
      _$ForgotPasswordRequestModelImpl _value,
      $Res Function(_$ForgotPasswordRequestModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ForgotPasswordRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
  }) {
    return _then(_$ForgotPasswordRequestModelImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ForgotPasswordRequestModelImpl implements _ForgotPasswordRequestModel {
  const _$ForgotPasswordRequestModelImpl({required this.email});

  factory _$ForgotPasswordRequestModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ForgotPasswordRequestModelImplFromJson(json);

  @override
  final String email;

  @override
  String toString() {
    return 'ForgotPasswordRequestModel(email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ForgotPasswordRequestModelImpl &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email);

  /// Create a copy of ForgotPasswordRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ForgotPasswordRequestModelImplCopyWith<_$ForgotPasswordRequestModelImpl>
      get copyWith => __$$ForgotPasswordRequestModelImplCopyWithImpl<
          _$ForgotPasswordRequestModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ForgotPasswordRequestModelImplToJson(
      this,
    );
  }
}

abstract class _ForgotPasswordRequestModel
    implements ForgotPasswordRequestModel {
  const factory _ForgotPasswordRequestModel({required final String email}) =
      _$ForgotPasswordRequestModelImpl;

  factory _ForgotPasswordRequestModel.fromJson(Map<String, dynamic> json) =
      _$ForgotPasswordRequestModelImpl.fromJson;

  @override
  String get email;

  /// Create a copy of ForgotPasswordRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ForgotPasswordRequestModelImplCopyWith<_$ForgotPasswordRequestModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ResetPasswordRequestModel _$ResetPasswordRequestModelFromJson(
    Map<String, dynamic> json) {
  return _ResetPasswordRequestModel.fromJson(json);
}

/// @nodoc
mixin _$ResetPasswordRequestModel {
  String get token => throw _privateConstructorUsedError;
  String get newPassword => throw _privateConstructorUsedError;

  /// Serializes this ResetPasswordRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResetPasswordRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResetPasswordRequestModelCopyWith<ResetPasswordRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResetPasswordRequestModelCopyWith<$Res> {
  factory $ResetPasswordRequestModelCopyWith(ResetPasswordRequestModel value,
          $Res Function(ResetPasswordRequestModel) then) =
      _$ResetPasswordRequestModelCopyWithImpl<$Res, ResetPasswordRequestModel>;
  @useResult
  $Res call({String token, String newPassword});
}

/// @nodoc
class _$ResetPasswordRequestModelCopyWithImpl<$Res,
        $Val extends ResetPasswordRequestModel>
    implements $ResetPasswordRequestModelCopyWith<$Res> {
  _$ResetPasswordRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResetPasswordRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? newPassword = null,
  }) {
    return _then(_value.copyWith(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      newPassword: null == newPassword
          ? _value.newPassword
          : newPassword // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ResetPasswordRequestModelImplCopyWith<$Res>
    implements $ResetPasswordRequestModelCopyWith<$Res> {
  factory _$$ResetPasswordRequestModelImplCopyWith(
          _$ResetPasswordRequestModelImpl value,
          $Res Function(_$ResetPasswordRequestModelImpl) then) =
      __$$ResetPasswordRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String token, String newPassword});
}

/// @nodoc
class __$$ResetPasswordRequestModelImplCopyWithImpl<$Res>
    extends _$ResetPasswordRequestModelCopyWithImpl<$Res,
        _$ResetPasswordRequestModelImpl>
    implements _$$ResetPasswordRequestModelImplCopyWith<$Res> {
  __$$ResetPasswordRequestModelImplCopyWithImpl(
      _$ResetPasswordRequestModelImpl _value,
      $Res Function(_$ResetPasswordRequestModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ResetPasswordRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
    Object? newPassword = null,
  }) {
    return _then(_$ResetPasswordRequestModelImpl(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
      newPassword: null == newPassword
          ? _value.newPassword
          : newPassword // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ResetPasswordRequestModelImpl implements _ResetPasswordRequestModel {
  const _$ResetPasswordRequestModelImpl(
      {required this.token, required this.newPassword});

  factory _$ResetPasswordRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$ResetPasswordRequestModelImplFromJson(json);

  @override
  final String token;
  @override
  final String newPassword;

  @override
  String toString() {
    return 'ResetPasswordRequestModel(token: $token, newPassword: $newPassword)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResetPasswordRequestModelImpl &&
            (identical(other.token, token) || other.token == token) &&
            (identical(other.newPassword, newPassword) ||
                other.newPassword == newPassword));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, token, newPassword);

  /// Create a copy of ResetPasswordRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResetPasswordRequestModelImplCopyWith<_$ResetPasswordRequestModelImpl>
      get copyWith => __$$ResetPasswordRequestModelImplCopyWithImpl<
          _$ResetPasswordRequestModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResetPasswordRequestModelImplToJson(
      this,
    );
  }
}

abstract class _ResetPasswordRequestModel implements ResetPasswordRequestModel {
  const factory _ResetPasswordRequestModel(
      {required final String token,
      required final String newPassword}) = _$ResetPasswordRequestModelImpl;

  factory _ResetPasswordRequestModel.fromJson(Map<String, dynamic> json) =
      _$ResetPasswordRequestModelImpl.fromJson;

  @override
  String get token;
  @override
  String get newPassword;

  /// Create a copy of ResetPasswordRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResetPasswordRequestModelImplCopyWith<_$ResetPasswordRequestModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ValidateResetTokenRequestModel _$ValidateResetTokenRequestModelFromJson(
    Map<String, dynamic> json) {
  return _ValidateResetTokenRequestModel.fromJson(json);
}

/// @nodoc
mixin _$ValidateResetTokenRequestModel {
  String get token => throw _privateConstructorUsedError;

  /// Serializes this ValidateResetTokenRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ValidateResetTokenRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ValidateResetTokenRequestModelCopyWith<ValidateResetTokenRequestModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ValidateResetTokenRequestModelCopyWith<$Res> {
  factory $ValidateResetTokenRequestModelCopyWith(
          ValidateResetTokenRequestModel value,
          $Res Function(ValidateResetTokenRequestModel) then) =
      _$ValidateResetTokenRequestModelCopyWithImpl<$Res,
          ValidateResetTokenRequestModel>;
  @useResult
  $Res call({String token});
}

/// @nodoc
class _$ValidateResetTokenRequestModelCopyWithImpl<$Res,
        $Val extends ValidateResetTokenRequestModel>
    implements $ValidateResetTokenRequestModelCopyWith<$Res> {
  _$ValidateResetTokenRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ValidateResetTokenRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
  }) {
    return _then(_value.copyWith(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$ValidateResetTokenRequestModelImplCopyWith<$Res>
    implements $ValidateResetTokenRequestModelCopyWith<$Res> {
  factory _$$ValidateResetTokenRequestModelImplCopyWith(
          _$ValidateResetTokenRequestModelImpl value,
          $Res Function(_$ValidateResetTokenRequestModelImpl) then) =
      __$$ValidateResetTokenRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String token});
}

/// @nodoc
class __$$ValidateResetTokenRequestModelImplCopyWithImpl<$Res>
    extends _$ValidateResetTokenRequestModelCopyWithImpl<$Res,
        _$ValidateResetTokenRequestModelImpl>
    implements _$$ValidateResetTokenRequestModelImplCopyWith<$Res> {
  __$$ValidateResetTokenRequestModelImplCopyWithImpl(
      _$ValidateResetTokenRequestModelImpl _value,
      $Res Function(_$ValidateResetTokenRequestModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ValidateResetTokenRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
  }) {
    return _then(_$ValidateResetTokenRequestModelImpl(
      token: null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ValidateResetTokenRequestModelImpl
    implements _ValidateResetTokenRequestModel {
  const _$ValidateResetTokenRequestModelImpl({required this.token});

  factory _$ValidateResetTokenRequestModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ValidateResetTokenRequestModelImplFromJson(json);

  @override
  final String token;

  @override
  String toString() {
    return 'ValidateResetTokenRequestModel(token: $token)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ValidateResetTokenRequestModelImpl &&
            (identical(other.token, token) || other.token == token));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, token);

  /// Create a copy of ValidateResetTokenRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ValidateResetTokenRequestModelImplCopyWith<
          _$ValidateResetTokenRequestModelImpl>
      get copyWith => __$$ValidateResetTokenRequestModelImplCopyWithImpl<
          _$ValidateResetTokenRequestModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ValidateResetTokenRequestModelImplToJson(
      this,
    );
  }
}

abstract class _ValidateResetTokenRequestModel
    implements ValidateResetTokenRequestModel {
  const factory _ValidateResetTokenRequestModel({required final String token}) =
      _$ValidateResetTokenRequestModelImpl;

  factory _ValidateResetTokenRequestModel.fromJson(Map<String, dynamic> json) =
      _$ValidateResetTokenRequestModelImpl.fromJson;

  @override
  String get token;

  /// Create a copy of ValidateResetTokenRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ValidateResetTokenRequestModelImplCopyWith<
          _$ValidateResetTokenRequestModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

PasswordResetResponseModel _$PasswordResetResponseModelFromJson(
    Map<String, dynamic> json) {
  return _PasswordResetResponseModel.fromJson(json);
}

/// @nodoc
mixin _$PasswordResetResponseModel {
  String get message => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;
  String? get resetToken => throw _privateConstructorUsedError;
  DateTime? get expiresAt => throw _privateConstructorUsedError;

  /// Serializes this PasswordResetResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of PasswordResetResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PasswordResetResponseModelCopyWith<PasswordResetResponseModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PasswordResetResponseModelCopyWith<$Res> {
  factory $PasswordResetResponseModelCopyWith(PasswordResetResponseModel value,
          $Res Function(PasswordResetResponseModel) then) =
      _$PasswordResetResponseModelCopyWithImpl<$Res,
          PasswordResetResponseModel>;
  @useResult
  $Res call(
      {String message, bool success, String? resetToken, DateTime? expiresAt});
}

/// @nodoc
class _$PasswordResetResponseModelCopyWithImpl<$Res,
        $Val extends PasswordResetResponseModel>
    implements $PasswordResetResponseModelCopyWith<$Res> {
  _$PasswordResetResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PasswordResetResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? success = null,
    Object? resetToken = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_value.copyWith(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      resetToken: freezed == resetToken
          ? _value.resetToken
          : resetToken // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PasswordResetResponseModelImplCopyWith<$Res>
    implements $PasswordResetResponseModelCopyWith<$Res> {
  factory _$$PasswordResetResponseModelImplCopyWith(
          _$PasswordResetResponseModelImpl value,
          $Res Function(_$PasswordResetResponseModelImpl) then) =
      __$$PasswordResetResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String message, bool success, String? resetToken, DateTime? expiresAt});
}

/// @nodoc
class __$$PasswordResetResponseModelImplCopyWithImpl<$Res>
    extends _$PasswordResetResponseModelCopyWithImpl<$Res,
        _$PasswordResetResponseModelImpl>
    implements _$$PasswordResetResponseModelImplCopyWith<$Res> {
  __$$PasswordResetResponseModelImplCopyWithImpl(
      _$PasswordResetResponseModelImpl _value,
      $Res Function(_$PasswordResetResponseModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of PasswordResetResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? success = null,
    Object? resetToken = freezed,
    Object? expiresAt = freezed,
  }) {
    return _then(_$PasswordResetResponseModelImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      resetToken: freezed == resetToken
          ? _value.resetToken
          : resetToken // ignore: cast_nullable_to_non_nullable
              as String?,
      expiresAt: freezed == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$PasswordResetResponseModelImpl implements _PasswordResetResponseModel {
  const _$PasswordResetResponseModelImpl(
      {required this.message,
      required this.success,
      this.resetToken,
      this.expiresAt});

  factory _$PasswordResetResponseModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$PasswordResetResponseModelImplFromJson(json);

  @override
  final String message;
  @override
  final bool success;
  @override
  final String? resetToken;
  @override
  final DateTime? expiresAt;

  @override
  String toString() {
    return 'PasswordResetResponseModel(message: $message, success: $success, resetToken: $resetToken, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PasswordResetResponseModelImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.resetToken, resetToken) ||
                other.resetToken == resetToken) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, message, success, resetToken, expiresAt);

  /// Create a copy of PasswordResetResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PasswordResetResponseModelImplCopyWith<_$PasswordResetResponseModelImpl>
      get copyWith => __$$PasswordResetResponseModelImplCopyWithImpl<
          _$PasswordResetResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$PasswordResetResponseModelImplToJson(
      this,
    );
  }
}

abstract class _PasswordResetResponseModel
    implements PasswordResetResponseModel {
  const factory _PasswordResetResponseModel(
      {required final String message,
      required final bool success,
      final String? resetToken,
      final DateTime? expiresAt}) = _$PasswordResetResponseModelImpl;

  factory _PasswordResetResponseModel.fromJson(Map<String, dynamic> json) =
      _$PasswordResetResponseModelImpl.fromJson;

  @override
  String get message;
  @override
  bool get success;
  @override
  String? get resetToken;
  @override
  DateTime? get expiresAt;

  /// Create a copy of PasswordResetResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PasswordResetResponseModelImplCopyWith<_$PasswordResetResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
