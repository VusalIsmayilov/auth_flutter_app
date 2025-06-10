import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../core/errors/exceptions.dart';
import '../../data/models/login_request_model.dart';
import '../../data/models/user_model.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../domain/usecases/auth/refresh_token_usecase.dart';
import '../../domain/usecases/user/get_user_profile_usecase.dart';
import '../../domain/usecases/auth/forgot_password_usecase.dart';
import '../../services/biometric_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? errorMessage;
  final Map<String, List<String>>? fieldErrors;

  const AuthState({
    required this.status,
    this.user,
    this.errorMessage,
    this.fieldErrors,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? errorMessage,
    Map<String, List<String>>? fieldErrors,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      fieldErrors: fieldErrors ?? this.fieldErrors,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthState &&
        other.status == status &&
        other.user == user &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode {
    return status.hashCode ^ user.hashCode ^ errorMessage.hashCode;
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LoginUseCase _loginUseCase;
  final RegisterUseCase _registerUseCase;
  final LogoutUseCase _logoutUseCase;
  final RefreshTokenUseCase _refreshTokenUseCase;
  final GetUserProfileUseCase _getUserProfileUseCase;
  final ForgotPasswordUseCase _forgotPasswordUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final BiometricService _biometricService;
  final Logger _logger;

  // Store last login credentials for biometric setup
  String? _lastLoginEmail;
  String? _lastLoginPassword;

  AuthNotifier({
    required LoginUseCase loginUseCase,
    required RegisterUseCase registerUseCase,
    required LogoutUseCase logoutUseCase,
    required RefreshTokenUseCase refreshTokenUseCase,
    required GetUserProfileUseCase getUserProfileUseCase,
    required ForgotPasswordUseCase forgotPasswordUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required BiometricService biometricService,
    Logger? logger,
  }) : _loginUseCase = loginUseCase,
       _registerUseCase = registerUseCase,
       _logoutUseCase = logoutUseCase,
       _refreshTokenUseCase = refreshTokenUseCase,
       _getUserProfileUseCase = getUserProfileUseCase,
       _forgotPasswordUseCase = forgotPasswordUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
       _biometricService = biometricService,
       _logger = logger ?? Logger(),
       super(const AuthState(status: AuthStatus.initial));

  Future<void> checkAuthenticationStatus() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      final isTokenValid = await _refreshTokenUseCase.isTokenValid();

      if (isTokenValid) {
        // Try to get cached user profile first
        final cachedUser = await _getUserProfileUseCase.getCachedProfile();

        if (cachedUser != null) {
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: cachedUser,
            errorMessage: null,
            fieldErrors: null,
          );
        } else {
          // Fetch fresh user profile
          await _loadUserProfile();
        }
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          user: null,
          errorMessage: null,
          fieldErrors: null,
        );
      }
    } catch (e) {
      _logger.e('Error checking auth status: $e');
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: 'Failed to check authentication status',
        fieldErrors: null,
      );
    }
  }

  Future<void> login(LoginRequestModel request) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      final authResponse = await _loginUseCase(request);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: authResponse.user,
        errorMessage: null,
        fieldErrors: null,
      );

      _logger.d('User logged in successfully: ${authResponse.user?.email}');

      // Store login credentials for potential biometric setup
      _lastLoginEmail = request.email;
      _lastLoginPassword = request.password;
    } on ValidationException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
        fieldErrors: e.fieldErrors,
      );
      _logger.w('Login validation error: ${e.message}');
    } on AuthenticationException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
        fieldErrors: null,
      );
      _logger.w('Login authentication error: ${e.message}');
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Login failed. Please try again.',
        fieldErrors: null,
      );
      _logger.e('Login error: $e');
    }
  }

  Future<void> register(RegisterRequestModel request) async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      final authResponse = await _registerUseCase(request);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: authResponse.user,
        errorMessage: null,
        fieldErrors: null,
      );

      _logger.d('User registered successfully: ${authResponse.user?.email}');
    } on ValidationException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
        fieldErrors: e.fieldErrors,
      );
      _logger.w('Registration validation error: ${e.message}');
    } on ServerException catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.message,
        fieldErrors: null,
      );
      _logger.w('Registration server error: ${e.message}');
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: 'Registration failed. Please try again.',
        fieldErrors: null,
      );
      _logger.e('Registration error: $e');
    }
  }

  Future<void> logout() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      await _logoutUseCase();

      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: null,
        fieldErrors: null,
      );

      _logger.d('User logged out successfully');
    } catch (e) {
      // Even if logout fails, clear the local state
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: null,
        fieldErrors: null,
      );
      _logger.w('Logout error (cleared local state): $e');
    }
  }

  Future<void> _loadUserProfile() async {
    try {
      final user = await _getUserProfileUseCase();

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
        errorMessage: null,
        fieldErrors: null,
      );
    } catch (e) {
      _logger.e('Failed to load user profile: $e');
      // Don't change auth status, just log the error
    }
  }

  Future<void> refreshUserProfile() async {
    if (state.status != AuthStatus.authenticated) return;

    try {
      await _loadUserProfile();
    } catch (e) {
      _logger.e('Failed to refresh user profile: $e');
    }
  }

  void clearError() {
    state = state.copyWith(errorMessage: null, fieldErrors: null);
  }


  /// Login with biometric authentication
  Future<void> loginWithBiometric() async {
    try {
      state = state.copyWith(status: AuthStatus.loading);

      // Check if biometric authentication is available and enabled
      final isAvailable = await _biometricService.isBiometricAvailable();
      if (!isAvailable) {
        throw Exception('Biometric authentication is not available');
      }

      final isEnabled = await _biometricService.isBiometricEnabled();
      if (!isEnabled) {
        throw Exception('Biometric authentication is not enabled');
      }

      // Authenticate with biometrics
      final didAuthenticate = await _biometricService.authenticateWithBiometrics();
      if (!didAuthenticate) {
        throw Exception('Biometric authentication failed');
      }

      // Get stored credentials
      final credentials = await _biometricService.getBiometricCredentials();
      if (credentials == null) {
        throw Exception('No biometric credentials found');
      }

      // Login with stored credentials (stored password is original, not hashed)
      final loginRequest = LoginRequestModel(
        email: credentials['email']!,
        password: credentials['password']!,
      );

      final authResponse = await _loginUseCase(loginRequest);

      state = state.copyWith(
        status: AuthStatus.authenticated,
        user: authResponse.user,
        errorMessage: null,
        fieldErrors: null,
      );

      _logger.d('Biometric login successful: ${authResponse.user?.email}');
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
        fieldErrors: null,
      );
      _logger.e('Biometric login error: $e');
    }
  }

  /// Setup biometric authentication after successful login
  Future<bool> setupBiometricAuthentication(String email, String password) async {
    try {
      // Store the original password (encrypted by secure storage)
      return await _biometricService.setupBiometricAuthentication(
        email: email,
        hashedPassword: password, // Store original password for API login
      );
    } catch (e) {
      _logger.e('Biometric setup error: $e');
      return false;
    }
  }

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      return await _biometricService.isBiometricAvailable();
    } catch (e) {
      _logger.e('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Check if biometric authentication is enabled
  Future<bool> isBiometricEnabled() async {
    try {
      return await _biometricService.isBiometricEnabled();
    } catch (e) {
      _logger.e('Error checking biometric enabled status: $e');
      return false;
    }
  }

  /// Check if user has biometric credentials stored
  Future<bool> hasBiometricCredentials() async {
    try {
      return await _biometricService.hasBiometricCredentials();
    } catch (e) {
      _logger.e('Error checking biometric credentials: $e');
      return false;
    }
  }

  /// Disable biometric authentication
  Future<void> disableBiometricAuthentication() async {
    try {
      await _biometricService.disableBiometricAuthentication();
      _logger.d('Biometric authentication disabled');
    } catch (e) {
      _logger.e('Error disabling biometric authentication: $e');
    }
  }

  /// Get biometric capability description
  Future<String> getBiometricCapabilityDescription() async {
    try {
      return await _biometricService.getBiometricCapabilityDescription();
    } catch (e) {
      _logger.e('Error getting biometric capability description: $e');
      return 'Biometric authentication';
    }
  }

  /// Check if biometric setup should be offered
  Future<bool> shouldOfferBiometricSetup() async {
    if (_lastLoginEmail == null || _lastLoginPassword == null) return false;
    
    try {
      final isAvailable = await _biometricService.isBiometricAvailable();
      final isEnabled = await _biometricService.isBiometricEnabled();
      final hasCredentials = await _biometricService.hasBiometricCredentials();
      
      return isAvailable && !isEnabled && !hasCredentials;
    } catch (e) {
      _logger.e('Error checking biometric setup eligibility: $e');
      return false;
    }
  }

  /// Get last login credentials for biometric setup
  Map<String, String>? getLastLoginCredentials() {
    if (_lastLoginEmail != null && _lastLoginPassword != null) {
      return {
        'email': _lastLoginEmail!,
        'password': _lastLoginPassword!,
      };
    }
    return null;
  }

  /// Clear last login credentials
  void clearLastLoginCredentials() {
    _lastLoginEmail = null;
    _lastLoginPassword = null;
  }

  /// Forgot password
  Future<void> forgotPassword(String email) async {
    try {
      await _forgotPasswordUseCase.execute(email);
      _logger.d('Forgot password email sent to: $email');
    } catch (e) {
      _logger.e('Forgot password error: $e');
      rethrow;
    }
  }

  /// Reset password
  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      await _resetPasswordUseCase.execute(
        token: token,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      _logger.d('Password reset successfully');
    } catch (e) {
      _logger.e('Reset password error: $e');
      rethrow;
    }
  }

  bool get isAuthenticated => state.status == AuthStatus.authenticated;
  bool get isLoading => state.status == AuthStatus.loading;
  bool get hasError => state.status == AuthStatus.error;
  UserModel? get currentUser => state.user;
}
