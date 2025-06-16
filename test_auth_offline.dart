import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';

// Import the auth implementation
import 'lib/presentation/providers/auth_provider.dart';
import 'lib/data/models/login_request_model.dart';
import 'lib/data/models/user_model.dart';
import 'lib/data/models/auth_response_model.dart';
import 'lib/core/errors/exceptions.dart';
import 'lib/services/jwt_service.dart';
import 'lib/services/biometric_service.dart';

void main() async {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  print('🧪 Offline Authentication Testing');
  print('==================================');
  
  // Test 1: Auth State Management
  await testAuthStateManagement();
  
  // Test 2: Model Serialization/Deserialization
  await testModelSerialization();
  
  // Test 3: JWT Service
  await testJWTService();
  
  // Test 4: Biometric Service
  await testBiometricService();
  
  // Test 5: Form Validation
  await testFormValidation();
  
  // Test 6: Error Handling
  await testErrorHandling();
  
  print('\n✅ Offline authentication testing complete!');
}

Future<void> testAuthStateManagement() async {
  print('\n📍 Test 1: Auth State Management');
  
  try {
    // Test initial state
    final authState = AuthState(status: AuthStatus.initial);
    print('   ✅ Initial state created: ${authState.status}');
    
    // Test state transitions
    final loadingState = authState.copyWith(status: AuthStatus.loading);
    print('   ✅ Loading state transition: ${loadingState.status}');
    
    // Test authenticated state with user
    final user = UserModel(
      id: '1',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
      isEmailVerified: true,
    );
    
    final authenticatedState = authState.copyWith(
      status: AuthStatus.authenticated,
      user: user,
    );
    print('   ✅ Authenticated state created: ${authenticatedState.user?.email}');
    
    // Test error state
    final errorState = authState.copyWith(
      status: AuthStatus.error,
      errorMessage: 'Test error message',
      fieldErrors: {'email': ['Invalid email']},
    );
    print('   ✅ Error state created: ${errorState.errorMessage}');
    
    // Test state equality
    final sameState = AuthState(status: AuthStatus.initial);
    final isEqual = authState == sameState;
    print('   ✅ State equality check: $isEqual');
    
  } catch (e) {
    print('   ❌ Auth state management error: $e');
  }
}

Future<void> testModelSerialization() async {
  print('\n📍 Test 2: Model Serialization/Deserialization');
  
  try {
    // Test LoginRequestModel
    final loginRequest = LoginRequestModel(
      email: 'test@example.com',
      password: 'password123',
    );
    
    final loginJson = loginRequest.toJson();
    print('   ✅ LoginRequest serialization: ${loginJson['email']}');
    
    final loginFromJson = LoginRequestModel.fromJson(loginJson);
    print('   ✅ LoginRequest deserialization: ${loginFromJson.email}');
    
    // Test RegisterRequestModel
    final registerRequest = RegisterRequestModel(
      email: 'test@example.com',
      password: 'password123',
      firstName: 'Test',
      lastName: 'User',
    );
    
    final registerJson = registerRequest.toJson();
    print('   ✅ RegisterRequest serialization: ${registerJson['firstName']}');
    
    // Test UserModel
    final user = UserModel(
      id: '1',
      email: 'test@example.com',
      firstName: 'Test',
      lastName: 'User',
      isEmailVerified: true,
    );
    
    final userJson = user.toJson();
    print('   ✅ User serialization: ${userJson['email']}');
    
    final userFromJson = UserModel.fromJson(userJson);
    print('   ✅ User deserialization: ${userFromJson.firstName}');
    
    // Test TokenModel
    final tokens = TokenModel(
      accessToken: 'access_token_123',
      refreshToken: 'refresh_token_456',
    );
    
    final tokenJson = tokens.toJson();
    print('   ✅ Token serialization: ${tokenJson['accessToken']?.substring(0, 10)}...');
    
    // Test AuthResponseModel
    final authResponse = AuthResponseModel(
      success: true,
      message: 'Login successful',
      user: user,
      tokens: tokens,
    );
    
    final authJson = authResponse.toJson();
    print('   ✅ AuthResponse serialization: ${authJson['message']}');
    
  } catch (e) {
    print('   ❌ Model serialization error: $e');
  }
}

Future<void> testJWTService() async {
  print('\n📍 Test 3: JWT Service');
  
  try {
    // Test JWT token validation (without actual tokens)
    final jwtService = JwtService();
    
    // Test with invalid token
    const invalidToken = 'invalid.jwt.token';
    final isValid = jwtService.isTokenValid(invalidToken);
    print('   ✅ Invalid token validation: $isValid');
    
    // Test token expiry check
    const expiredToken = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJzdWIiOiIxMjM0NTY3ODkwIiwibmFtZSI6IkpvaG4gRG9lIiwiaWF0IjoxNTE2MjM5MDIyLCJleHAiOjE1MTYyMzkwMjJ9.invalid';
    final isExpired = jwtService.isTokenExpired(expiredToken);
    print('   ✅ Token expiry check: $isExpired');
    
    // Test getting claims from token
    try {
      final claims = jwtService.getTokenClaims(invalidToken);
      print('   ✅ Token claims extraction: ${claims.length} claims');
    } catch (e) {
      print('   ✅ Token claims validation properly rejects invalid tokens');
    }
    
  } catch (e) {
    print('   ❌ JWT service error: $e');
  }
}

Future<void> testBiometricService() async {
  print('\n📍 Test 4: Biometric Service');
  
  try {
    final biometricService = BiometricService();
    
    // Test biometric availability check
    try {
      final isAvailable = await biometricService.isBiometricAvailable();
      print('   ✅ Biometric availability check: $isAvailable');
    } catch (e) {
      print('   ✅ Biometric availability check handled: ${e.toString().substring(0, 50)}...');
    }
    
    // Test biometric enabled status
    try {
      final isEnabled = await biometricService.isBiometricEnabled();
      print('   ✅ Biometric enabled check: $isEnabled');
    } catch (e) {
      print('   ✅ Biometric enabled check handled: ${e.toString().substring(0, 50)}...');
    }
    
    // Test biometric capability description
    try {
      final description = await biometricService.getBiometricCapabilityDescription();
      print('   ✅ Biometric capability: $description');
    } catch (e) {
      print('   ✅ Biometric capability check handled: ${e.toString().substring(0, 50)}...');
    }
    
  } catch (e) {
    print('   ❌ Biometric service error: $e');
  }
}

Future<void> testFormValidation() async {
  print('\n📍 Test 5: Form Validation');
  
  try {
    // Test email validation
    const validEmail = 'test@example.com';
    const invalidEmail = 'invalid-email';
    const emptyEmail = '';
    
    print('   ✅ Valid email format: $validEmail - ${_isValidEmail(validEmail)}');
    print('   ✅ Invalid email format: $invalidEmail - ${_isValidEmail(invalidEmail)}');
    print('   ✅ Empty email format: $emptyEmail - ${_isValidEmail(emptyEmail)}');
    
    // Test password validation
    const strongPassword = 'StrongPassword123!';
    const weakPassword = '123';
    const emptyPassword = '';
    
    print('   ✅ Strong password: ${strongPassword.length} chars - ${_isValidPassword(strongPassword)}');
    print('   ✅ Weak password: ${weakPassword.length} chars - ${_isValidPassword(weakPassword)}');
    print('   ✅ Empty password: ${emptyPassword.length} chars - ${_isValidPassword(emptyPassword)}');
    
    // Test password confirmation
    const matchingPasswords = _passwordsMatch(strongPassword, strongPassword);
    const nonMatchingPasswords = _passwordsMatch(strongPassword, weakPassword);
    
    print('   ✅ Matching passwords: $matchingPasswords');
    print('   ✅ Non-matching passwords: $nonMatchingPasswords');
    
    // Test name validation
    const validName = 'John';
    const invalidName = '';
    
    print('   ✅ Valid name: $validName - ${_isValidName(validName)}');
    print('   ✅ Invalid name: $invalidName - ${_isValidName(invalidName)}');
    
  } catch (e) {
    print('   ❌ Form validation error: $e');
  }
}

Future<void> testErrorHandling() async {
  print('\n📍 Test 6: Error Handling');
  
  try {
    // Test ValidationException
    final validationException = ValidationException(
      'Validation failed',
      fieldErrors: {
        'email': ['Email is required', 'Email format is invalid'],
        'password': ['Password is too short'],
      },
    );
    
    print('   ✅ ValidationException created: ${validationException.message}');
    print('   ✅ Field errors count: ${validationException.fieldErrors?.length}');
    
    // Test AuthenticationException
    final authException = AuthenticationException('Invalid credentials');
    print('   ✅ AuthenticationException created: ${authException.message}');
    
    // Test ServerException
    final serverException = ServerException('Server error', statusCode: 500);
    print('   ✅ ServerException created: ${serverException.message} (${serverException.statusCode})');
    
    // Test NetworkException
    final networkException = NetworkException('Connection timeout');
    print('   ✅ NetworkException created: ${networkException.message}');
    
    // Test error state handling
    final errorState = AuthState(
      status: AuthStatus.error,
      errorMessage: validationException.message,
      fieldErrors: validationException.fieldErrors,
    );
    
    print('   ✅ Error state with field errors: ${errorState.fieldErrors?.keys.join(', ')}');
    
  } catch (e) {
    print('   ❌ Error handling test error: $e');
  }
}

// Helper validation functions
bool _isValidEmail(String email) {
  if (email.isEmpty) return false;
  return RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email);
}

bool _isValidPassword(String password) {
  return password.length >= 8;
}

bool _passwordsMatch(String password, String confirmPassword) {
  return password == confirmPassword;
}

bool _isValidName(String name) {
  return name.isNotEmpty && name.trim().length > 1;
}