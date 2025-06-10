import '../../../data/models/user_model.dart';
import '../../repositories/auth_repository.dart';

class GetUserProfileUseCase {
  final AuthRepository _authRepository;

  GetUserProfileUseCase({
    required AuthRepository authRepository,
  }) : _authRepository = authRepository;

  Future<UserModel> call() async {
    try {
      return await _authRepository.getUserProfile();
    } catch (e) {
      rethrow;
    }
  }

  Future<UserModel?> getCachedProfile() async {
    try {
      final authResponse = await _authRepository.getCachedAuthResponse();
      return authResponse?.user;
    } catch (e) {
      return null;
    }
  }
}