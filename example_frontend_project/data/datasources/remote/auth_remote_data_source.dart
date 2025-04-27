import 'package:dio/dio.dart';
import 'package:ironiq/core/error/failures.dart';
import 'package:ironiq/core/network/dio_client.dart';
import 'package:ironiq/data/models/user_model.dart';
import 'package:ironiq/data/models/auth_response.dart';
import 'package:ironiq/data/models/token_pair.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<AuthResponse> login({
    required String email,
    required String password,
    required bool rememberMe,
  });

  Future<void> logout({required String refreshToken});

  Future<UserModel> getCurrentUser();

  Future<TokenPair> refreshToken({required String refreshToken});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final DioClient _dioClient;

  AuthRemoteDataSourceImpl({required DioClient dioClient})
      : _dioClient = dioClient;

  @override
  Future<AuthResponse> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/register',
        data: {
          'email': email,
          'password': password,
          'first_name': firstName,
          'last_name': lastName,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return AuthResponse(
          user: UserModel.fromRegistrationResponse(
            response.data,
            email: email,
            firstName: firstName,
            lastName: lastName,
          ),
          tokens: TokenPair(
            accessToken: response.data['access_token'],
            refreshToken: response.data['refresh_token'],
            expiresIn: response.data['expires_in'],
          ),
        );
      } else {
        throw ServerFailure(
          message: response.data['message'] ?? 'Registration failed',
          code: response.statusCode.toString(),
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        final errorData = e.response?.data;
        final errorMessage = (errorData is Map<String, dynamic>)
            ? (errorData['error'] as Map<String, dynamic>)['message'] ??
                'Email is already registered'
            : 'Email is already registered';
        throw ServerFailure(
          message: errorMessage,
          code: '409',
        );
      } else if (e.response != null) {
        final errorData = e.response?.data;
        final errorMessage = (errorData is Map<String, dynamic>)
            ? (errorData['error'] as Map<String, dynamic>)['message'] ??
                'Registration failed'
            : 'Registration failed';
        throw ServerFailure(
          message: errorMessage,
          code: e.response?.statusCode.toString() ?? 'unknown',
        );
      } else {
        throw const ServerFailure(
          message: 'Connection failed. Please check your internet connection.',
          code: 'network_error',
        );
      }
    } catch (e) {
      throw ServerFailure(
        message: 'Registration failed: ${e.toString()}',
        code: 'unknown',
      );
    }
  }

  @override
  Future<AuthResponse> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      print('Attempting login with email: $email, rememberMe: $rememberMe');
      final response = await _dioClient.dio.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
          'remember_me': rememberMe,
        },
        options: Options(
          followRedirects: false,
          validateStatus: (status) => status != null && status < 500,
          headers: {
            'Accept': 'application/json',
          },
        ),
      );

      print('Login response status: ${response.statusCode}');
      print('Login response data: ${response.data}');

      if (response.statusCode == 200) {
        final data = response.data;

        // Fetch user details - cookie will be sent automatically
        final userResponse = await _dioClient.dio.get('/auth/me');

        if (userResponse.statusCode != 200) {
          throw ServerFailure(
            message: 'Failed to fetch user details',
            code: userResponse.statusCode.toString(),
          );
        }

        final userData = userResponse.data;

        return AuthResponse(
          user: UserModel(
            id: data['user_id'],
            email: email,
            firstName: userData['first_name'] ?? '',
            lastName: userData['last_name'] ?? '',
            role: userData['role'] ?? 'client',
            createdAt: userData['created_at'] != null
                ? DateTime.parse(userData['created_at'])
                : DateTime.now(),
            updatedAt: userData['updated_at'] != null
                ? DateTime.parse(userData['updated_at'])
                : DateTime.now(),
          ),
          tokens: TokenPair(
            accessToken: '', // Not using tokens, using cookies instead
            refreshToken: '',
            expiresIn: data['expires_in'] ?? 3600,
          ),
        );
      } else {
        print('Non-200 response: ${response.data}');
        throw ServerFailure(
          message: response.data['message'] ?? 'Login failed',
          code: response.statusCode.toString(),
        );
      }
    } on DioException catch (e) {
      print('DioException during login:');
      print('Status code: ${e.response?.statusCode}');
      print('Response data: ${e.response?.data}');
      print('Error message: ${e.message}');
      print('Error type: ${e.type}');
      print('Stack trace: ${e.stackTrace}');

      if (e.response?.statusCode == 401) {
        throw const ServerFailure(
          message: 'Invalid email or password',
          code: '401',
        );
      } else if (e.response?.statusCode == 400) {
        final errorData = e.response?.data;
        print('Validation error details: ${errorData?['error']?['details']}');
        final errorMessage = (errorData is Map<String, dynamic>)
            ? (errorData['error']?['message'] ?? 'Validation failed') +
                (errorData['error']?['details'] != null
                    ? ': ${errorData['error']['details']}'
                    : '')
            : 'Validation failed';
        throw ServerFailure(
          message: errorMessage,
          code: '400',
        );
      } else if (e.response != null) {
        final errorData = e.response?.data;
        final errorMessage = (errorData is Map<String, dynamic>)
            ? (errorData['error'] as Map<String, dynamic>)['message'] ??
                'Login failed'
            : 'Login failed';
        throw ServerFailure(
          message: errorMessage,
          code: e.response?.statusCode.toString() ?? 'unknown',
        );
      } else {
        throw const ServerFailure(
          message: 'Connection failed. Please check your internet connection.',
          code: 'network_error',
        );
      }
    } catch (e, stackTrace) {
      print('Unexpected error during login:');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      throw ServerFailure(
        message: 'Login failed: ${e.toString()}',
        code: 'unknown',
      );
    }
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    try {
      await _dioClient.dio.post(
        '/auth/logout',
        data: {'refresh_token': refreshToken},
      );
      _dioClient.clearAuthToken();
    } on DioException catch (e) {
      if (e.response != null) {
        throw ServerFailure(
          message: e.response?.data['error']?['message'] ?? 'Logout failed',
          code: e.response?.statusCode.toString() ?? 'unknown',
        );
      } else {
        throw const ServerFailure(
          message: 'Connection failed. Please check your internet connection.',
          code: 'network_error',
        );
      }
    } catch (e) {
      throw ServerFailure(
        message: 'Logout failed: ${e.toString()}',
        code: 'unknown',
      );
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await _dioClient.dio.get('/auth/me');

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['user']);
      } else {
        throw ServerFailure(
          message: response.data['message'] ?? 'Failed to get current user',
          code: response.statusCode.toString(),
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const ServerFailure(
          message: 'Session expired. Please login again.',
          code: '401',
        );
      } else if (e.response != null) {
        throw ServerFailure(
          message: e.response?.data['error']?['message'] ??
              'Failed to get current user',
          code: e.response?.statusCode.toString() ?? 'unknown',
        );
      } else {
        throw const ServerFailure(
          message: 'Connection failed. Please check your internet connection.',
          code: 'network_error',
        );
      }
    } catch (e) {
      throw ServerFailure(
        message: 'Failed to get current user: ${e.toString()}',
        code: 'unknown',
      );
    }
  }

  @override
  Future<TokenPair> refreshToken({required String refreshToken}) async {
    try {
      final response = await _dioClient.dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        return TokenPair(
          accessToken: response.data['access_token'],
          refreshToken: response.data['refresh_token'],
          expiresIn: response.data['expires_in'],
        );
      } else {
        throw ServerFailure(
          message: response.data['message'] ?? 'Token refresh failed',
          code: response.statusCode.toString(),
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const ServerFailure(
          message: 'Invalid refresh token',
          code: '401',
        );
      } else if (e.response != null) {
        throw ServerFailure(
          message:
              e.response?.data['error']?['message'] ?? 'Token refresh failed',
          code: e.response?.statusCode.toString() ?? 'unknown',
        );
      } else {
        throw const ServerFailure(
          message: 'Connection failed. Please check your internet connection.',
          code: 'network_error',
        );
      }
    } catch (e) {
      throw ServerFailure(
        message: 'Token refresh failed: ${e.toString()}',
        code: 'unknown',
      );
    }
  }
}
