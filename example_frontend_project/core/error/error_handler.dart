import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart';
import '../utils/ui_utils.dart';
import 'exceptions.dart';
import 'failures.dart';
import 'authentication_failure.dart';

/// Handles errors and exceptions in a consistent way across the application
class ErrorHandler {
  /// Handles any error and returns a Failure
  static Failure handleError(Object error, [StackTrace? stackTrace]) {
    // Log error in debug mode
    if (kDebugMode) {
      print('Error: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }

    if (error is Failure) return error;
    if (error is AppException) return _mapExceptionToFailure(error);

    return ServerFailure(
      message: error.toString(),
      code: 'unknown_error',
    );
  }

  /// Maps exceptions to failures
  static Failure _mapExceptionToFailure(AppException exception) {
    if (exception is AuthenticationException) {
      return AuthenticationFailure(
        message: exception.message,
        code: exception.code,
      );
    }

    if (exception is NetworkException) {
      return NetworkFailure(
        message: exception.message,
        code: exception.code,
      );
    }

    if (exception is ValidationException) {
      return ValidationFailure(
        message: exception.message,
        code: exception.code,
        errors: exception.errors,
      );
    }

    if (exception is ApiException) {
      return ServerFailure(
        message: exception.message,
        code: exception.code ?? exception.statusCode?.toString(),
      );
    }

    return ServerFailure(
      message: exception.message,
      code: exception.code,
    );
  }

  /// Wraps a Future and returns Either<Failure, T>
  static Future<Either<Failure, T>> handleFuture<T>(
    Future<T> Function() future,
  ) async {
    try {
      final result = await future();
      return Right(result);
    } catch (error, stackTrace) {
      return Left(handleError(error, stackTrace));
    }
  }

  /// Shows error UI feedback
  static void showError(BuildContext context, Failure failure) {
    String message = failure.message;

    if (failure is ValidationFailure && failure.errors != null) {
      message = failure.errors!.values.expand((errors) => errors).join('\n');
    }

    UiUtils.showSnackBar(
      context,
      message,
      isError: true,
    );
  }

  /// Logs error details
  static void logError(Object error, [StackTrace? stackTrace]) {
    if (!kDebugMode) return; // Only log in debug mode for now

    print('----------------------------------------');
    print('Error: $error');
    if (stackTrace != null) {
      print('StackTrace:');
      print(stackTrace);
    }
    print('----------------------------------------');
  }
}
