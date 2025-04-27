import 'package:dio/dio.dart';
import 'package:dartz/dartz.dart';
import '../error/error_handler.dart';
import '../error/error_mapper.dart';
import '../error/failures.dart';
import 'api_response.dart';
import 'dio_client.dart';
import 'network_info.dart';

/// Base class for API services with common functionality
abstract class ApiService {
  final DioClient _client;
  final NetworkInfo _networkInfo;
  final ErrorHandler _errorHandler;

  ApiService()
      : _client = DioClient(),
        _networkInfo = NetworkInfo(),
        _errorHandler = ErrorHandler();

  /// Makes a GET request with error handling
  Future<Either<Failure, T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
    bool requiresAuth = true,
  }) async {
    return _handleRequest(() async {
      final response = await _client.dio.get(
        path,
        queryParameters: queryParameters,
      );
      return _parseResponse(response, parser);
    });
  }

  /// Makes a POST request with error handling
  Future<Either<Failure, T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
    bool requiresAuth = true,
  }) async {
    return _handleRequest(() async {
      final response = await _client.dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _parseResponse(response, parser);
    });
  }

  /// Makes a PUT request with error handling
  Future<Either<Failure, T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
    bool requiresAuth = true,
  }) async {
    return _handleRequest(() async {
      final response = await _client.dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _parseResponse(response, parser);
    });
  }

  /// Makes a DELETE request with error handling
  Future<Either<Failure, T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    T Function(dynamic)? parser,
    bool requiresAuth = true,
  }) async {
    return _handleRequest(() async {
      final response = await _client.dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return _parseResponse(response, parser);
    });
  }

  /// Handles API requests with error handling and network checks
  Future<Either<Failure, T>> _handleRequest<T>(
    Future<T> Function() request,
  ) async {
    if (!_networkInfo.hasConnection) {
      return Left(NetworkFailure(
        message: 'No internet connection',
        code: 'no_connection',
      ));
    }

    try {
      final result = await request();
      return Right(result);
    } on DioException catch (e) {
      final exception = ErrorMapper.mapDioError(e);
      return Left(ErrorHandler.handleError(exception));
    } catch (e, stackTrace) {
      return Left(ErrorHandler.handleError(e, stackTrace));
    }
  }

  /// Parses API response with optional custom parser
  T _parseResponse<T>(
    Response response,
    T Function(dynamic)? parser,
  ) {
    final apiResponse = ApiResponse<dynamic>.fromJson(
      response.data,
      (json) => json,
    );

    if (!apiResponse.success) {
      throw ErrorMapper.mapDioError(
        DioException(
          response: response,
          requestOptions: response.requestOptions,
        ),
      );
    }

    if (parser != null) {
      return parser(apiResponse.data);
    }

    return apiResponse.data as T;
  }

  /// Downloads a file with progress tracking
  Future<Either<Failure, String>> downloadFile(
    String url,
    String savePath, {
    ProgressCallback? onReceiveProgress,
  }) async {
    return _handleRequest(() async {
      await _client.dio.download(
        url,
        savePath,
        onReceiveProgress: onReceiveProgress,
      );
      return savePath;
    });
  }

  /// Uploads a file with progress tracking
  Future<Either<Failure, T>> uploadFile<T>(
    String path,
    String filePath, {
    String? fileName,
    T Function(dynamic)? parser,
    ProgressCallback? onSendProgress,
  }) async {
    return _handleRequest(() async {
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: fileName,
        ),
      });

      final response = await _client.dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
      );

      return _parseResponse(response, parser);
    });
  }
}
