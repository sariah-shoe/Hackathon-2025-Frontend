import 'package:ironiq/core/error/failures.dart';

class AuthenticationFailure extends Failure {
  const AuthenticationFailure({
    required super.message,
    super.code,
  });
} 