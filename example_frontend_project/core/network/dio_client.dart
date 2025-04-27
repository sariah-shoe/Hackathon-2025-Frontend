import 'package:dio/dio.dart';
import 'package:ironiq/config/app_config.dart';
import 'package:ironiq/core/storage/secure_storage.dart';
import 'package:ironiq/core/error/exceptions.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  late final Dio dio;
  late final SecureStorage _secureStorage;
  bool _isRefreshing = false;

  factory DioClient() => _instance;

  DioClient._internal() {
    _secureStorage = SecureStorage();
    final options = BaseOptions(
      baseUrl: AppConfig().apiBaseUrl,
      connectTimeout: AppConfig().timeoutDuration,
      receiveTimeout: AppConfig().timeoutDuration,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      validateStatus: (status) {
        return status != null && status < 500;
      },
      followRedirects: false,
      receiveDataWhenStatusError: true,
    );

    dio = Dio(options);

    if (AppConfig().enableLogging) {
      dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        logPrint: (obj) {
          print('Dio Log: $obj');
        },
        error: true,
      ));
    }

    // Add cookie management
    dio.interceptors.add(
      InterceptorsWrapper(
        onResponse: (response, handler) {
          // Store cookies from response
          final cookies = response.headers['set-cookie'];
          if (cookies != null && cookies.isNotEmpty) {
            _secureStorage.storeCookie(cookies.first);
          }
          return handler.next(response);
        },
        onRequest: (options, handler) async {
          // Add stored cookie to request
          final cookie = await _secureStorage.getCookie();
          if (cookie != null) {
            options.headers['cookie'] = cookie;
          }
          return handler.next(options);
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _handleRequest,
        onError: _handleError,
      ),
    );
  }

  Future<void> _handleRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    print('Making request to: ${options.uri}');
    print('Request data: ${options.data}');
    print('Request headers: ${options.headers}');

    if (!options.path.contains('/auth/login') &&
        !options.path.contains('/auth/refresh')) {
      final token = await _secureStorage.getAccessToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    return handler.next(options);
  }

  Future<void> _handleError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    print('DioClient error handler:');
    print('Error type: ${error.type}');
    print('Error message: ${error.message}');
    print('Error response: ${error.response?.data}');
    print('Status code: ${error.response?.statusCode}');

    if (error.response?.statusCode == 401) {
      if (!_isRefreshing &&
          !error.requestOptions.path.contains('/auth/refresh')) {
        try {
          final newTokens = await _refreshToken();
          if (newTokens) {
            return handler.resolve(await _retryRequest(error.requestOptions));
          }
        } catch (e) {
          print('Token refresh failed: $e');
          await _secureStorage.clearTokens();
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: AuthenticationException('Session expired'),
            ),
          );
        }
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return handler.reject(
        DioException(
          requestOptions: error.requestOptions,
          error: NetworkException('Connection timeout'),
        ),
      );
    }

    return handler.next(error);
  }

  Future<bool> _refreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;

    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        throw AuthenticationException('No refresh token found');
      }

      print('Attempting to refresh token');
      final response = await dio.post(
        '/auth/refresh',
        data: {'refresh_token': refreshToken},
      );

      print('Refresh token response: ${response.data}');
      if (response.statusCode == 200) {
        final data = response.data;
        await _secureStorage.storeTokens(
          accessToken: data['access_token'],
          refreshToken: data['refresh_token'],
          expiresIn: data['expires_in'],
          rememberMe: await _secureStorage.isRememberMeEnabled(),
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error refreshing token: $e');
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final options = Options(
      method: requestOptions.method,
      headers: requestOptions.headers,
    );

    return dio.request<dynamic>(
      requestOptions.path,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
      options: options,
    );
  }

  void updateAuthToken(String token) {
    dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    dio.options.headers.remove('Authorization');
  }
}
