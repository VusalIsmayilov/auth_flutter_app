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
    @JsonKey(name: 'FirstName') String? firstName,
    @JsonKey(name: 'LastName') String? lastName,
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

  String get displayName {
    // Use firstName and lastName if available
    if (firstName != null && lastName != null) {
      final fullName = '${firstName!.trim()} ${lastName!.trim()}'.trim();
      if (fullName.isNotEmpty) return fullName;
    }
    
    // Use just firstName if lastName is not available
    if (firstName != null && firstName!.trim().isNotEmpty) {
      return firstName!.trim();
    }
    
    // Fallback to email or phone number
    return email ?? phoneNumber ?? 'User $id';
  }

  bool get hasRole => currentRole != null;

  bool get isAdmin => currentRole == 'Admin';
  
  bool get isModerator => currentRole == 'Moderator';
  
  bool get isSupport => currentRole == 'Support';

  bool get isUser => currentRole == 'User' || currentRole == null;
}
