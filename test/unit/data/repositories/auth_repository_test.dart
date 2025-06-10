import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:auth_flutter_app/data/repositories/auth_repository_impl.dart';
import 'package:auth_flutter_app/data/datasources/remote/auth_api_service.dart';
import 'package:auth_flutter_app/data/datasources/local/secure_storage_service.dart';
import 'package:auth_flutter_app/data/models/login_request_model.dart';
import 'package:auth_flutter_app/data/models/auth_response_model.dart';
import 'package:auth_flutter_app/data/models/user_model.dart';
import 'package:auth_flutter_app/core/errors/exceptions.dart';
import 'package:dio/dio.dart';

import 'auth_repository_test.mocks.dart';

@GenerateMocks([
  AuthApiService,
  SecureStorageService,
])
void main() {
  late AuthRepositoryImpl repository;
  late MockAuthApiService mockApiService;
  late MockSecureStorageService mockStorageService;

  setUp(() {
    mockApiService = MockAuthApiService();
    mockStorageService = MockSecureStorageService();
    repository = AuthRepositoryImpl(
      apiService: mockApiService,
      storageService: mockStorageService,
    );
  });

  group('AuthRepositoryImpl', () {
    group('login', () {
      const tLoginRequest = LoginRequestModel(
        email: 'test@example.com',
        password: 'password123',
        rememberMe: false,
      );

      final tUser = UserModel(
        id: '1',
        email: 'test@example.com',
        firstName: 'Test',
        lastName: 'User',
        roles: ['user'],
        createdAt: DateTime.now(),
        isActive: true,
      );

      final tAuthResponse = AuthResponseModel(
        accessToken: 'access_token',
        refreshToken: 'refresh_token',
        user: tUser,
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      test('should return AuthResponseModel when login is successful', () async {
        // arrange
        when(mockApiService.login(any))
            .thenAnswer((_) async => tAuthResponse);
        when(mockStorageService.storeAuthResponse(any))
            .thenAnswer((_) async {});

        // act
        final result = await repository.login(tLoginRequest);

        // assert
        expect(result, equals(tAuthResponse));
        verify(mockApiService.login(tLoginRequest));
        verify(mockStorageService.storeAuthResponse(tAuthResponse));
      });

      test('should throw AuthenticationException when API returns 401', () async {
        // arrange
        when(mockApiService.login(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/login'),
            response: Response(
              requestOptions: RequestOptions(path: '/login'),
              statusCode: 401,
              data: {'message': 'Invalid credentials'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        // act & assert
        expect(
          () async => await repository.login(tLoginRequest),
          throwsA(isA<AuthenticationException>()),
        );
        verify(mockApiService.login(tLoginRequest));
        verifyNever(mockStorageService.storeAuthResponse(any));
      });

      test('should throw ValidationException when API returns 422', () async {
        // arrange
        when(mockApiService.login(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/login'),
            response: Response(
              requestOptions: RequestOptions(path: '/login'),
              statusCode: 422,
              data: {
                'message': 'Validation failed',
                'errors': {
                  'email': ['The email field is required.'],
                  'password': ['The password field is required.'],
                }
              },
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        // act & assert
        expect(
          () async => await repository.login(tLoginRequest),
          throwsA(isA<ValidationException>()),
        );
      });

      test('should throw ServerException when API returns 500', () async {
        // arrange
        when(mockApiService.login(any)).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/login'),
            response: Response(
              requestOptions: RequestOptions(path: '/login'),
              statusCode: 500,
              data: {'message': 'Internal server error'},
            ),
            type: DioExceptionType.badResponse,
          ),
        );

        // act & assert
        expect(
          () async => await repository.login(tLoginRequest),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('logout', () {
      test('should call API logout and clear storage when successful', () async {
        // arrange
        when(mockApiService.logout()).thenAnswer((_) async {});
        when(mockStorageService.clearTokens()).thenAnswer((_) async {});

        // act
        await repository.logout();

        // assert
        verify(mockApiService.logout());
        verify(mockStorageService.clearTokens());
      });

      test('should clear storage even when API logout fails', () async {
        // arrange
        when(mockApiService.logout()).thenThrow(
          DioException(
            requestOptions: RequestOptions(path: '/logout'),
            type: DioExceptionType.connectionTimeout,
          ),
        );
        when(mockStorageService.clearTokens()).thenAnswer((_) async {});

        // act
        await repository.logout();

        // assert
        verify(mockApiService.logout());
        verify(mockStorageService.clearTokens());
      });
    });

    group('refreshToken', () {
      const tRefreshToken = 'refresh_token';
      final tTokenModel = TokenModel(
        accessToken: 'new_access_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      test('should return new TokenModel when refresh is successful', () async {
        // arrange
        when(mockStorageService.getRefreshToken())
            .thenAnswer((_) async => tRefreshToken);
        when(mockApiService.refreshToken(any))
            .thenAnswer((_) async => tTokenModel);
        when(mockStorageService.storeToken(any))
            .thenAnswer((_) async {});

        // act
        final result = await repository.refreshToken();

        // assert
        expect(result, equals(tTokenModel));
        verify(mockStorageService.getRefreshToken());
        verify(mockApiService.refreshToken(any));
        verify(mockStorageService.storeToken(tTokenModel));
      });

      test('should throw AuthenticationException when no refresh token stored', () async {
        // arrange
        when(mockStorageService.getRefreshToken())
            .thenAnswer((_) async => null);

        // act & assert
        expect(
          () async => await repository.refreshToken(),
          throwsA(isA<AuthenticationException>()),
        );
        verify(mockStorageService.getRefreshToken());
        verifyNever(mockApiService.refreshToken(any));
      });
    });

    group('isTokenValid', () {
      test('should return true when token exists and is not expired', () async {
        // arrange
        final validToken = TokenModel(
          accessToken: 'access_token',
          refreshToken: 'refresh_token',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );
        when(mockStorageService.getToken())
            .thenAnswer((_) async => validToken);

        // act
        final result = await repository.isTokenValid();

        // assert
        expect(result, true);
        verify(mockStorageService.getToken());
      });

      test('should return false when token does not exist', () async {
        // arrange
        when(mockStorageService.getToken())
            .thenAnswer((_) async => null);

        // act
        final result = await repository.isTokenValid();

        // assert
        expect(result, false);
        verify(mockStorageService.getToken());
      });

      test('should return false when token is expired', () async {
        // arrange
        final expiredToken = TokenModel(
          accessToken: 'access_token',
          refreshToken: 'refresh_token',
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
        );
        when(mockStorageService.getToken())
            .thenAnswer((_) async => expiredToken);

        // act
        final result = await repository.isTokenValid();

        // assert
        expect(result, false);
        verify(mockStorageService.getToken());
      });
    });
  });
}