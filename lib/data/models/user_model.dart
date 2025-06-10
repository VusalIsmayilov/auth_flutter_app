import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_model.freezed.dart';
part 'user_model.g.dart';

@freezed
class UserModel with _$UserModel {
  const UserModel._();

  const factory UserModel({
    required int id,
    String? email,
    String? phoneNumber,
    @Default(false) bool isEmailVerified,
    @Default(false) bool isPhoneVerified,
    String? currentRole,
    String? currentRoleDisplayName,
    DateTime? createdAt,
    DateTime? lastLoginAt,
    @Default(true) bool isActive,
  }) = _UserModel;

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  String get displayName => email ?? phoneNumber ?? 'User $id';

  bool get hasRole => currentRole != null;

  bool get isAdmin => currentRole == 'Admin';
  
  bool get isModerator => currentRole == 'Moderator';
  
  bool get isSupport => currentRole == 'Support';

  bool get isUser => currentRole == 'User' || currentRole == null;
}
