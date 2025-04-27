import 'package:dartz/dartz.dart';
import 'package:ironiq/core/error/failures.dart';
import 'package:ironiq/domain/entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  });

  Future<Either<Failure, User>> login({
    required String email,
    required String password,
    required bool rememberMe,
  });

  Future<Either<Failure, void>> logout();

  Future<Either<Failure, User>> getCurrentUser();

  Future<Either<Failure, bool>> isAuthenticated();

  Future<Either<Failure, void>> refreshToken();
} 