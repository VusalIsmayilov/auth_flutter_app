import '../../../core/errors/exceptions.dart';
import '../../../data/models/user_model.dart';
import '../../repositories/auth_repository.dart';

class UpdateProfileUseCase {
  final AuthRepository _authRepository;

  UpdateProfileUseCase({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  Future<UserModel> call(Map<String, dynamic> profileData) async {
    try {
      // Validate profile data
      _validateProfileData(profileData);

      // Update profile
      return await _authRepository.updateProfile(profileData);
    } catch (e) {
      rethrow;
    }
  }

  void _validateProfileData(Map<String, dynamic> data) {
    final errors = <String, List<String>>{};

    // First name validation
    if (data.containsKey('firstName')) {
      final firstName = data['firstName'] as String?;
      if (firstName != null) {
        if (firstName.isEmpty) {
          errors['firstName'] = ['First name cannot be empty'];
        } else if (firstName.length < 2) {
          errors['firstName'] = ['First name must be at least 2 characters'];
        } else if (firstName.length > 50) {
          errors['firstName'] = ['First name must be less than 50 characters'];
        }
      }
    }

    // Last name validation
    if (data.containsKey('lastName')) {
      final lastName = data['lastName'] as String?;
      if (lastName != null) {
        if (lastName.isEmpty) {
          errors['lastName'] = ['Last name cannot be empty'];
        } else if (lastName.length < 2) {
          errors['lastName'] = ['Last name must be at least 2 characters'];
        } else if (lastName.length > 50) {
          errors['lastName'] = ['Last name must be less than 50 characters'];
        }
      }
    }

    // Email validation
    if (data.containsKey('email')) {
      final email = data['email'] as String?;
      if (email != null) {
        if (email.isEmpty) {
          errors['email'] = ['Email cannot be empty'];
        } else if (!_isValidEmail(email)) {
          errors['email'] = ['Please enter a valid email address'];
        }
      }
    }

    // Avatar URL validation
    if (data.containsKey('avatar')) {
      final avatar = data['avatar'] as String?;
      if (avatar != null && avatar.isNotEmpty) {
        if (!_isValidUrl(avatar)) {
          errors['avatar'] = ['Please enter a valid URL for avatar'];
        }
      }
    }

    if (errors.isNotEmpty) {
      throw ValidationException(
        message: 'Profile validation failed',
        fieldErrors: errors,
      );
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
}