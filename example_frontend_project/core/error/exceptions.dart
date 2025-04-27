/// Base exception class for the application
abstract class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, [this.code]);

  @override
  String toString() => message;
}

/// Exception thrown when authentication fails
class AuthenticationException extends AppException {
  AuthenticationException(super.message, [super.code]);
}

/// Exception thrown when network operations fail
class NetworkException extends AppException {
  NetworkException(super.message, [super.code]);
}

/// Exception thrown when API requests fail
class ApiException extends AppException {
  final int? statusCode;
  final Map<String, dynamic>? data;

  ApiException(String message, {
    this.statusCode,
    this.data,
    String? code,
  }) : super(message, code);
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  final Map<String, List<String>>? errors;

  ValidationException(String message, {
    this.errors,
    String? code,
  }) : super(message, code);
} 