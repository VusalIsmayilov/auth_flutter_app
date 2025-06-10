import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../core/network/dio_client.dart';
import '../../config/environment_config.dart';
import '../../data/datasources/local/secure_storage_service.dart';
import '../../data/datasources/remote/auth_api_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/refresh_token_usecase.dart';
import '../../domain/usecases/user/get_user_profile_usecase.dart';
import '../../domain/usecases/user/update_profile_usecase.dart';
import '../../domain/usecases/auth/forgot_password_usecase.dart';
import '../../services/jwt_service.dart';
import '../../services/biometric_service.dart';
import '../../data/models/user_model.dart';
import 'auth_provider.dart';

// Core services
final loggerProvider = Provider<Logger>((ref) => Logger());

final secureStorageProvider = Provider<SecureStorageService>((ref) => SecureStorageService());

final biometricServiceProvider = Provider<BiometricService>((ref) {
  final storageService = ref.watch(secureStorageProvider);
  final logger = ref.watch(loggerProvider);
  
  return BiometricService(
    storageService: storageService,
    logger: logger,
  );
});

// Environment configuration provider
final environmentConfigProvider = Provider<EnvironmentConfig>((ref) {
  return EnvironmentService.config;
});

// Repository (defined early to break circular dependency)
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  final storageService = ref.watch(secureStorageProvider);
  final config = ref.watch(environmentConfigProvider);
  
  final dio = DioClient.createDio(
    baseUrl: config.apiUrl,
    connectTimeout: config.connectTimeout.inMilliseconds,
    receiveTimeout: config.receiveTimeout.inMilliseconds,
    sendTimeout: config.sendTimeout.inMilliseconds,
    enableCertificatePinning: config.enableCertificatePinning,
  );
  
  final apiService = AuthApiService(dio);
  
  return AuthRepositoryImpl(
    apiService: apiService,
    storageService: storageService,
  );
});

// JWT Service
final jwtServiceProvider = Provider<JwtService>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final storageService = ref.watch(secureStorageProvider);
  final logger = ref.watch(loggerProvider);
  
  final jwtService = JwtService(
    authRepository: authRepository,
    storageService: storageService,
    logger: logger,
  );
  
  // Update Dio client with JWT service
  DioClient.updateJwtService(jwtService);
  
  return jwtService;
});

// Network layer (updated with JWT service)
final authApiServiceProvider = Provider<AuthApiService>((ref) {
  final jwtService = ref.watch(jwtServiceProvider);
  final config = ref.watch(environmentConfigProvider);
  
  final dio = DioClient.createDio(
    jwtService: jwtService,
    baseUrl: config.apiUrl,
    connectTimeout: config.connectTimeout.inMilliseconds,
    receiveTimeout: config.receiveTimeout.inMilliseconds,
    sendTimeout: config.sendTimeout.inMilliseconds,
    enableCertificatePinning: config.enableCertificatePinning,
  );
  
  return AuthApiService(dio);
});

// Use cases
final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final jwtService = ref.watch(jwtServiceProvider);
  
  return LoginUseCase(
    authRepository: authRepository,
    jwtService: jwtService,
  );
});

final registerUseCaseProvider = Provider<RegisterUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final jwtService = ref.watch(jwtServiceProvider);
  
  return RegisterUseCase(
    authRepository: authRepository,
    jwtService: jwtService,
  );
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final jwtService = ref.watch(jwtServiceProvider);
  
  return LogoutUseCase(
    authRepository: authRepository,
    jwtService: jwtService,
  );
});

final refreshTokenUseCaseProvider = Provider<RefreshTokenUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final jwtService = ref.watch(jwtServiceProvider);
  
  return RefreshTokenUseCase(
    authRepository: authRepository,
    jwtService: jwtService,
  );
});

final getUserProfileUseCaseProvider = Provider<GetUserProfileUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  
  return GetUserProfileUseCase(
    authRepository: authRepository,
  );
});

final updateProfileUseCaseProvider = Provider<UpdateProfileUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  
  return UpdateProfileUseCase(
    authRepository: authRepository,
  );
});

final forgotPasswordUseCaseProvider = Provider<ForgotPasswordUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  
  return ForgotPasswordUseCase(authRepository);
});

final resetPasswordUseCaseProvider = Provider<ResetPasswordUseCase>((ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  
  return ResetPasswordUseCase(authRepository);
});

// Auth state notifier
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final loginUseCase = ref.watch(loginUseCaseProvider);
  final registerUseCase = ref.watch(registerUseCaseProvider);
  final logoutUseCase = ref.watch(logoutUseCaseProvider);
  final refreshTokenUseCase = ref.watch(refreshTokenUseCaseProvider);
  final getUserProfileUseCase = ref.watch(getUserProfileUseCaseProvider);
  final updateProfileUseCase = ref.watch(updateProfileUseCaseProvider);
  final forgotPasswordUseCase = ref.watch(forgotPasswordUseCaseProvider);
  final resetPasswordUseCase = ref.watch(resetPasswordUseCaseProvider);
  final biometricService = ref.watch(biometricServiceProvider);
  final logger = ref.watch(loggerProvider);
  
  return AuthNotifier(
    loginUseCase: loginUseCase,
    registerUseCase: registerUseCase,
    logoutUseCase: logoutUseCase,
    refreshTokenUseCase: refreshTokenUseCase,
    getUserProfileUseCase: getUserProfileUseCase,
    updateProfileUseCase: updateProfileUseCase,
    forgotPasswordUseCase: forgotPasswordUseCase,
    resetPasswordUseCase: resetPasswordUseCase,
    biometricService: biometricService,
    logger: logger,
  );
});

// Convenience providers for UI
final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.status == AuthStatus.authenticated;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.user;
});

final authErrorProvider = Provider<String?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.errorMessage;
});

final authFieldErrorsProvider = Provider<Map<String, List<String>>?>((ref) {
  final authState = ref.watch(authProvider);
  return authState.fieldErrors;
});

final isLoadingProvider = Provider<bool>((ref) {
  final authState = ref.watch(authProvider);
  return authState.status == AuthStatus.loading;
});

// Biometric providers for UI
final biometricAvailableProvider = FutureProvider<bool>((ref) async {
  final authNotifier = ref.watch(authProvider.notifier);
  return await authNotifier.isBiometricAvailable();
});

final biometricEnabledProvider = FutureProvider<bool>((ref) async {
  final authNotifier = ref.watch(authProvider.notifier);
  return await authNotifier.isBiometricEnabled();
});

final hasBiometricCredentialsProvider = FutureProvider<bool>((ref) async {
  final authNotifier = ref.watch(authProvider.notifier);
  return await authNotifier.hasBiometricCredentials();
});

final biometricCapabilityProvider = FutureProvider<String>((ref) async {
  final authNotifier = ref.watch(authProvider.notifier);
  return await authNotifier.getBiometricCapabilityDescription();
});