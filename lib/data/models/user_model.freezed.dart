// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserModel _$UserModelFromJson(Map<String, dynamic> json) {
  return _UserModel.fromJson(json);
}

/// @nodoc
mixin _$UserModel {
  int get id => throw _privateConstructorUsedError;
  String? get email => throw _privateConstructorUsedError;
  String? get phoneNumber => throw _privateConstructorUsedError;
  String? get firstName => throw _privateConstructorUsedError;
  String? get lastName => throw _privateConstructorUsedError;
  bool get isEmailVerified => throw _privateConstructorUsedError;
  bool get isPhoneVerified => throw _privateConstructorUsedError;
  String? get currentRole => throw _privateConstructorUsedError;
  String? get currentRoleDisplayName => throw _privateConstructorUsedError;
  DateTime? get createdAt => throw _privateConstructorUsedError;
  DateTime? get lastLoginAt => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;

  /// Serializes this UserModel to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $UserModelCopyWith<UserModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserModelCopyWith<$Res> {
  factory $UserModelCopyWith(UserModel value, $Res Function(UserModel) then) =
      _$UserModelCopyWithImpl<$Res, UserModel>;
  @useResult
  $Res call(
      {int id,
      String? email,
      String? phoneNumber,
      String? firstName,
      String? lastName,
      bool isEmailVerified,
      bool isPhoneVerified,
      String? currentRole,
      String? currentRoleDisplayName,
      DateTime? createdAt,
      DateTime? lastLoginAt,
      bool isActive});
}

/// @nodoc
class _$UserModelCopyWithImpl<$Res, $Val extends UserModel>
    implements $UserModelCopyWith<$Res> {
  _$UserModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? isEmailVerified = null,
    Object? isPhoneVerified = null,
    Object? currentRole = freezed,
    Object? currentRoleDisplayName = freezed,
    Object? createdAt = freezed,
    Object? lastLoginAt = freezed,
    Object? isActive = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      isEmailVerified: null == isEmailVerified
          ? _value.isEmailVerified
          : isEmailVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isPhoneVerified: null == isPhoneVerified
          ? _value.isPhoneVerified
          : isPhoneVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      currentRole: freezed == currentRole
          ? _value.currentRole
          : currentRole // ignore: cast_nullable_to_non_nullable
              as String?,
      currentRoleDisplayName: freezed == currentRoleDisplayName
          ? _value.currentRoleDisplayName
          : currentRoleDisplayName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastLoginAt: freezed == lastLoginAt
          ? _value.lastLoginAt
          : lastLoginAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserModelImplCopyWith<$Res>
    implements $UserModelCopyWith<$Res> {
  factory _$$UserModelImplCopyWith(
          _$UserModelImpl value, $Res Function(_$UserModelImpl) then) =
      __$$UserModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {int id,
      String? email,
      String? phoneNumber,
      String? firstName,
      String? lastName,
      bool isEmailVerified,
      bool isPhoneVerified,
      String? currentRole,
      String? currentRoleDisplayName,
      DateTime? createdAt,
      DateTime? lastLoginAt,
      bool isActive});
}

/// @nodoc
class __$$UserModelImplCopyWithImpl<$Res>
    extends _$UserModelCopyWithImpl<$Res, _$UserModelImpl>
    implements _$$UserModelImplCopyWith<$Res> {
  __$$UserModelImplCopyWithImpl(
      _$UserModelImpl _value, $Res Function(_$UserModelImpl) _then)
      : super(_value, _then);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? email = freezed,
    Object? phoneNumber = freezed,
    Object? firstName = freezed,
    Object? lastName = freezed,
    Object? isEmailVerified = null,
    Object? isPhoneVerified = null,
    Object? currentRole = freezed,
    Object? currentRoleDisplayName = freezed,
    Object? createdAt = freezed,
    Object? lastLoginAt = freezed,
    Object? isActive = null,
  }) {
    return _then(_$UserModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as int,
      email: freezed == email
          ? _value.email
          : email // ignore: cast_nullable_to_non_nullable
              as String?,
      phoneNumber: freezed == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String?,
      firstName: freezed == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String?,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      isEmailVerified: null == isEmailVerified
          ? _value.isEmailVerified
          : isEmailVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      isPhoneVerified: null == isPhoneVerified
          ? _value.isPhoneVerified
          : isPhoneVerified // ignore: cast_nullable_to_non_nullable
              as bool,
      currentRole: freezed == currentRole
          ? _value.currentRole
          : currentRole // ignore: cast_nullable_to_non_nullable
              as String?,
      currentRoleDisplayName: freezed == currentRoleDisplayName
          ? _value.currentRoleDisplayName
          : currentRoleDisplayName // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: freezed == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      lastLoginAt: freezed == lastLoginAt
          ? _value.lastLoginAt
          : lastLoginAt // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserModelImpl extends _UserModel {
  const _$UserModelImpl(
      {required this.id,
      this.email,
      this.phoneNumber,
      this.firstName,
      this.lastName,
      this.isEmailVerified = false,
      this.isPhoneVerified = false,
      this.currentRole,
      this.currentRoleDisplayName,
      this.createdAt,
      this.lastLoginAt,
      this.isActive = true})
      : super._();

  factory _$UserModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserModelImplFromJson(json);

  @override
  final int id;
  @override
  final String? email;
  @override
  final String? phoneNumber;
  @override
  final String? firstName;
  @override
  final String? lastName;
  @override
  @JsonKey()
  final bool isEmailVerified;
  @override
  @JsonKey()
  final bool isPhoneVerified;
  @override
  final String? currentRole;
  @override
  final String? currentRoleDisplayName;
  @override
  final DateTime? createdAt;
  @override
  final DateTime? lastLoginAt;
  @override
  @JsonKey()
  final bool isActive;

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email, phoneNumber: $phoneNumber, firstName: $firstName, lastName: $lastName, isEmailVerified: $isEmailVerified, isPhoneVerified: $isPhoneVerified, currentRole: $currentRole, currentRoleDisplayName: $currentRoleDisplayName, createdAt: $createdAt, lastLoginAt: $lastLoginAt, isActive: $isActive)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.email, email) || other.email == email) &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.isEmailVerified, isEmailVerified) ||
                other.isEmailVerified == isEmailVerified) &&
            (identical(other.isPhoneVerified, isPhoneVerified) ||
                other.isPhoneVerified == isPhoneVerified) &&
            (identical(other.currentRole, currentRole) ||
                other.currentRole == currentRole) &&
            (identical(other.currentRoleDisplayName, currentRoleDisplayName) ||
                other.currentRoleDisplayName == currentRoleDisplayName) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt) &&
            (identical(other.lastLoginAt, lastLoginAt) ||
                other.lastLoginAt == lastLoginAt) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      email,
      phoneNumber,
      firstName,
      lastName,
      isEmailVerified,
      isPhoneVerified,
      currentRole,
      currentRoleDisplayName,
      createdAt,
      lastLoginAt,
      isActive);

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      __$$UserModelImplCopyWithImpl<_$UserModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserModelImplToJson(
      this,
    );
  }
}

abstract class _UserModel extends UserModel {
  const factory _UserModel(
      {required final int id,
      final String? email,
      final String? phoneNumber,
      final String? firstName,
      final String? lastName,
      final bool isEmailVerified,
      final bool isPhoneVerified,
      final String? currentRole,
      final String? currentRoleDisplayName,
      final DateTime? createdAt,
      final DateTime? lastLoginAt,
      final bool isActive}) = _$UserModelImpl;
  const _UserModel._() : super._();

  factory _UserModel.fromJson(Map<String, dynamic> json) =
      _$UserModelImpl.fromJson;

  @override
  int get id;
  @override
  String? get email;
  @override
  String? get phoneNumber;
  @override
  String? get firstName;
  @override
  String? get lastName;
  @override
  bool get isEmailVerified;
  @override
  bool get isPhoneVerified;
  @override
  String? get currentRole;
  @override
  String? get currentRoleDisplayName;
  @override
  DateTime? get createdAt;
  @override
  DateTime? get lastLoginAt;
  @override
  bool get isActive;

  /// Create a copy of UserModel
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$UserModelImplCopyWith<_$UserModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
