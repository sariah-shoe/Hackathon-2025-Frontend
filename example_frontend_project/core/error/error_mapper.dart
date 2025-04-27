import 'package:dio/dio.dart';
import 'exceptions.dart';

/// Maps various error types to our custom exceptions
class ErrorMapper {
  /// Maps Dio errors to our custom exceptions
  static AppException mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException(
          'Connection timeout. Please check your internet connection.',
          'timeout',
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          'No internet connection.',
          'no_connection',
        );

      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response);

      case DioExceptionType.cancel:
        return ApiException(
          'Request cancelled',
          code: 'request_cancelled',
        );

      case DioExceptionType.unknown:
      default:
        return ApiException(
          'An unexpected error occurred',
          code: 'unknown_error',
        );
    }
  }

  /// Maps HTTP response errors to our custom exceptions
  static AppException _handleBadResponse(Response? response) {
    final statusCode = response?.statusCode ?? 500;
    final data = response?.data;

    switch (statusCode) {
      case 400:
        return _handleValidationError(data);

      case 401:
        return AuthenticationException(
          'Authentication failed. Please log in again.',
          'unauthorized',
        );

      case 403:
        return AuthenticationException(
          'You do not have permission to perform this action.',
          'forbidden',
        );

      case 404:
        return ApiException(
          'The requested resource was not found.',
          statusCode: statusCode,
          code: 'not_found',
        );

      case 409:
        return ApiException(
          'The request conflicts with the current state.',
          statusCode: statusCode,
          code: 'conflict',
        );

      case 422:
        return _handleValidationError(data);

      case 429:
        return ApiException(
          'Too many requests. Please try again later.',
          statusCode: statusCode,
          code: 'rate_limit',
        );

      case 500:
      case 502:
      case 503:
      case 504:
        return ApiException(
          'A server error occurred. Please try again later.',
          statusCode: statusCode,
          code: 'server_error',
        );

      default:
        return ApiException(
          'An unexpected error occurred.',
          statusCode: statusCode,
          code: 'unknown_error',
        );
    }
  }

  /// Handles validation errors from the API
  static ValidationException _handleValidationError(dynamic data) {
    if (data == null) {
      return ValidationException(
        'Validation failed.',
        code: 'validation_error',
      );
    }

    try {
      final Map<String, List<String>> errors = {};

      if (data is Map) {
        data.forEach((key, value) {
          if (value is List) {
            errors[key] = value.map((e) => e.toString()).toList();
          } else if (value is String) {
            errors[key] = [value];
          }
        });
      }

      return ValidationException(
        'Please check your input.',
        errors: errors,
        code: 'validation_error',
      );
    } catch (e) {
      return ValidationException(
        'Validation failed.',
        code: 'validation_error',
      );
    }
  }

  /// Maps network connectivity errors
  static NetworkException mapConnectivityError(String message) {
    return NetworkException(
      message,
      'connectivity_error',
    );
  }

  /// Maps cache errors
  static AppException mapCacheError(String message) {
    return ApiException(
      message,
      code: 'cache_error',
    );
  }
}
