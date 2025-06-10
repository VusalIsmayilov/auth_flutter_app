// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'email_verification_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

VerifyEmailRequestModel _$VerifyEmailRequestModelFromJson(
    Map<String, dynamic> json) {
  return _VerifyEmailRequestModel.fromJson(json);
}

/// @nodoc
mixin _$VerifyEmailRequestModel {
  String get email => throw _privateConstructorUsedError;
  String get verificationCode => throw _privateConstructorUsedError;

  /// Serializes this VerifyEmailRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of VerifyEmailRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $VerifyEmailRequestModelCopyWith<VerifyEmailRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $VerifyEmailRequestModelCopyWith<$Res> {
  factory $VerifyEmailRequestModelCopyWith(VerifyEmailRequestModel value,
          $Res Function(VerifyEmailRequestModel) then) =
      _$VerifyEmailRequestModelCopyWithImpl<$Res, VerifyEmailRequestModel>;
  @useResult
  $Res call({String email, String verificationCode});
}

/// @nodoc
class _$VerifyEmailRequestModelCopyWithImpl<$Res,
        $Val extends VerifyEmailRequestModel>
    implements $VerifyEmailRequestModelCopyWith<$Res> {
  _$VerifyEmailRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of VerifyEmailRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? verificationCode = null,
  }) {
    return _then(_value.copyWith(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      verificationCode: null == verificationCode
          ? _value.verificationCode
          : verificationCode // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$VerifyEmailRequestModelImplCopyWith<$Res>
    implements $VerifyEmailRequestModelCopyWith<$Res> {
  factory _$$VerifyEmailRequestModelImplCopyWith(
          _$VerifyEmailRequestModelImpl value,
          $Res Function(_$VerifyEmailRequestModelImpl) then) =
      __$$VerifyEmailRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email, String verificationCode});
}

/// @nodoc
class __$$VerifyEmailRequestModelImplCopyWithImpl<$Res>
    extends _$VerifyEmailRequestModelCopyWithImpl<$Res,
        _$VerifyEmailRequestModelImpl>
    implements _$$VerifyEmailRequestModelImplCopyWith<$Res> {
  __$$VerifyEmailRequestModelImplCopyWithImpl(
      _$VerifyEmailRequestModelImpl _value,
      $Res Function(_$VerifyEmailRequestModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of VerifyEmailRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
    Object? verificationCode = null,
  }) {
    return _then(_$VerifyEmailRequestModelImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
      verificationCode: null == verificationCode
          ? _value.verificationCode
          : verificationCode // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$VerifyEmailRequestModelImpl implements _VerifyEmailRequestModel {
  const _$VerifyEmailRequestModelImpl(
      {required this.email, required this.verificationCode});

  factory _$VerifyEmailRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$VerifyEmailRequestModelImplFromJson(json);

  @override
  final String email;
  @override
  final String verificationCode;

  @override
  String toString() {
    return 'VerifyEmailRequestModel(email: $email, verificationCode: $verificationCode)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$VerifyEmailRequestModelImpl &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.verificationCode, verificationCode) ||
                other.verificationCode == verificationCode));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email, verificationCode);

  /// Create a copy of VerifyEmailRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$VerifyEmailRequestModelImplCopyWith<_$VerifyEmailRequestModelImpl>
      get copyWith => __$$VerifyEmailRequestModelImplCopyWithImpl<
          _$VerifyEmailRequestModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$VerifyEmailRequestModelImplToJson(
      this,
    );
  }
}

abstract class _VerifyEmailRequestModel implements VerifyEmailRequestModel {
  const factory _VerifyEmailRequestModel(
      {required final String email,
      required final String verificationCode}) = _$VerifyEmailRequestModelImpl;

  factory _VerifyEmailRequestModel.fromJson(Map<String, dynamic> json) =
      _$VerifyEmailRequestModelImpl.fromJson;

  @override
  String get email;
  @override
  String get verificationCode;

  /// Create a copy of VerifyEmailRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$VerifyEmailRequestModelImplCopyWith<_$VerifyEmailRequestModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

ResendVerificationRequestModel _$ResendVerificationRequestModelFromJson(
    Map<String, dynamic> json) {
  return _ResendVerificationRequestModel.fromJson(json);
}

/// @nodoc
mixin _$ResendVerificationRequestModel {
  String get email => throw _privateConstructorUsedError;

  /// Serializes this ResendVerificationRequestModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of ResendVerificationRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $ResendVerificationRequestModelCopyWith<ResendVerificationRequestModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $ResendVerificationRequestModelCopyWith<$Res> {
  factory $ResendVerificationRequestModelCopyWith(
          ResendVerificationRequestModel value,
          $Res Function(ResendVerificationRequestModel) then) =
      _$ResendVerificationRequestModelCopyWithImpl<$Res,
          ResendVerificationRequestModel>;
  @useResult
  $Res call({String email});
}

/// @nodoc
class _$ResendVerificationRequestModelCopyWithImpl<$Res,
        $Val extends ResendVerificationRequestModel>
    implements $ResendVerificationRequestModelCopyWith<$Res> {
  _$ResendVerificationRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of ResendVerificationRequestModel
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
abstract class _$$ResendVerificationRequestModelImplCopyWith<$Res>
    implements $ResendVerificationRequestModelCopyWith<$Res> {
  factory _$$ResendVerificationRequestModelImplCopyWith(
          _$ResendVerificationRequestModelImpl value,
          $Res Function(_$ResendVerificationRequestModelImpl) then) =
      __$$ResendVerificationRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String email});
}

/// @nodoc
class __$$ResendVerificationRequestModelImplCopyWithImpl<$Res>
    extends _$ResendVerificationRequestModelCopyWithImpl<$Res,
        _$ResendVerificationRequestModelImpl>
    implements _$$ResendVerificationRequestModelImplCopyWith<$Res> {
  __$$ResendVerificationRequestModelImplCopyWithImpl(
      _$ResendVerificationRequestModelImpl _value,
      $Res Function(_$ResendVerificationRequestModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of ResendVerificationRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? email = null,
  }) {
    return _then(_$ResendVerificationRequestModelImpl(
      email: null == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$ResendVerificationRequestModelImpl
    implements _ResendVerificationRequestModel {
  const _$ResendVerificationRequestModelImpl({required this.email});

  factory _$ResendVerificationRequestModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$ResendVerificationRequestModelImplFromJson(json);

  @override
  final String email;

  @override
  String toString() {
    return 'ResendVerificationRequestModel(email: $email)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$ResendVerificationRequestModelImpl &&
            (identical(other.email, email) || other.email == email));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(runtimeType, email);

  /// Create a copy of ResendVerificationRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$ResendVerificationRequestModelImplCopyWith<
          _$ResendVerificationRequestModelImpl>
      get copyWith => __$$ResendVerificationRequestModelImplCopyWithImpl<
          _$ResendVerificationRequestModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$ResendVerificationRequestModelImplToJson(
      this,
    );
  }
}

abstract class _ResendVerificationRequestModel
    implements ResendVerificationRequestModel {
  const factory _ResendVerificationRequestModel({required final String email}) =
      _$ResendVerificationRequestModelImpl;

  factory _ResendVerificationRequestModel.fromJson(Map<String, dynamic> json) =
      _$ResendVerificationRequestModelImpl.fromJson;

  @override
  String get email;

  /// Create a copy of ResendVerificationRequestModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$ResendVerificationRequestModelImplCopyWith<
          _$ResendVerificationRequestModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}

EmailVerificationResponseModel _$EmailVerificationResponseModelFromJson(
    Map<String, dynamic> json) {
  return _EmailVerificationResponseModel.fromJson(json);
}

/// @nodoc
mixin _$EmailVerificationResponseModel {
  String get message => throw _privateConstructorUsedError;
  bool get success => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  DateTime? get verifiedAt => throw _privateConstructorUsedError;

  /// Serializes this EmailVerificationResponseModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of EmailVerificationResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $EmailVerificationResponseModelCopyWith<EmailVerificationResponseModel>
      get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $EmailVerificationResponseModelCopyWith<$Res> {
  factory $EmailVerificationResponseModelCopyWith(
          EmailVerificationResponseModel value,
          $Res Function(EmailVerificationResponseModel) then) =
      _$EmailVerificationResponseModelCopyWithImpl<$Res,
          EmailVerificationResponseModel>;
  @useResult
  $Res call(
      {String message, bool success, String? email, DateTime? verifiedAt});
}

/// @nodoc
class _$EmailVerificationResponseModelCopyWithImpl<$Res,
        $Val extends EmailVerificationResponseModel>
    implements $EmailVerificationResponseModelCopyWith<$Res> {
  _$EmailVerificationResponseModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of EmailVerificationResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? success = null,
    Object? email = freezed,
    Object? verifiedAt = freezed,
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
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      verifiedAt: freezed == verifiedAt
          ? _value.verifiedAt
          : verifiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$EmailVerificationResponseModelImplCopyWith<$Res>
    implements $EmailVerificationResponseModelCopyWith<$Res> {
  factory _$$EmailVerificationResponseModelImplCopyWith(
          _$EmailVerificationResponseModelImpl value,
          $Res Function(_$EmailVerificationResponseModelImpl) then) =
      __$$EmailVerificationResponseModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String message, bool success, String? email, DateTime? verifiedAt});
}

/// @nodoc
class __$$EmailVerificationResponseModelImplCopyWithImpl<$Res>
    extends _$EmailVerificationResponseModelCopyWithImpl<$Res,
        _$EmailVerificationResponseModelImpl>
    implements _$$EmailVerificationResponseModelImplCopyWith<$Res> {
  __$$EmailVerificationResponseModelImplCopyWithImpl(
      _$EmailVerificationResponseModelImpl _value,
      $Res Function(_$EmailVerificationResponseModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of EmailVerificationResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? message = null,
    Object? success = null,
    Object? email = freezed,
    Object? verifiedAt = freezed,
  }) {
    return _then(_$EmailVerificationResponseModelImpl(
      message: null == message
          ? _value.message
          : message // ignore: cast_nullable_to_non_nullable
              as String,
      success: null == success
          ? _value.success
          : success // ignore: cast_nullable_to_non_nullable
              as bool,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      verifiedAt: freezed == verifiedAt
          ? _value.verifiedAt
          : verifiedAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$EmailVerificationResponseModelImpl
    implements _EmailVerificationResponseModel {
  const _$EmailVerificationResponseModelImpl(
      {required this.message,
      required this.success,
      this.email,
      this.verifiedAt});

  factory _$EmailVerificationResponseModelImpl.fromJson(
          Map<String, dynamic> json) =>
      _$$EmailVerificationResponseModelImplFromJson(json);

  @override
  final String message;
  @override
  final bool success;
  @override
  final String? email;
  @override
  final DateTime? verifiedAt;

  @override
  String toString() {
    return 'EmailVerificationResponseModel(message: $message, success: $success, email: $email, verifiedAt: $verifiedAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$EmailVerificationResponseModelImpl &&
            (identical(other.message, message) || other.message == message) &&
            (identical(other.success, success) || other.success == success) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.verifiedAt, verifiedAt) ||
                other.verifiedAt == verifiedAt));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode =>
      Object.hash(runtimeType, message, success, email, verifiedAt);

  /// Create a copy of EmailVerificationResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$EmailVerificationResponseModelImplCopyWith<
          _$EmailVerificationResponseModelImpl>
      get copyWith => __$$EmailVerificationResponseModelImplCopyWithImpl<
          _$EmailVerificationResponseModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$EmailVerificationResponseModelImplToJson(
      this,
    );
  }
}

abstract class _EmailVerificationResponseModel
    implements EmailVerificationResponseModel {
  const factory _EmailVerificationResponseModel(
      {required final String message,
      required final bool success,
      final String? email,
      final DateTime? verifiedAt}) = _$EmailVerificationResponseModelImpl;

  factory _EmailVerificationResponseModel.fromJson(Map<String, dynamic> json) =
      _$EmailVerificationResponseModelImpl.fromJson;

  @override
  String get message;
  @override
  bool get success;
  @override
  String? get email;
  @override
  DateTime? get verifiedAt;

  /// Create a copy of EmailVerificationResponseModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$EmailVerificationResponseModelImplCopyWith<
          _$EmailVerificationResponseModelImpl>
      get copyWith => throw _privateConstructorUsedError;
}
