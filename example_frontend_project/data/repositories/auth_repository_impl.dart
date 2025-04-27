import 'package:dartz/dartz.dart';
import 'package:ironiq/core/error/failures.dart';
import 'package:ironiq/data/datasources/remote/auth_remote_data_source.dart';
import 'package:ironiq/domain/entities/user.dart';
import 'package:ironiq/domain/repositories/auth_repository.dart';
import 'package:ironiq/core/storage/secure_storage.dart';
import 'package:ironiq/core/error/authentication_failure.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;
  final SecureStorage _secureStorage;

  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _secureStorage = SecureStorage();

  @override
  Future<Either<Failure, User>> register({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      final response = await _remoteDataSource.register(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      await _secureStorage.storeTokens(
        accessToken: response.tokens.accessToken,
        refreshToken: response.tokens.refreshToken,
        expiresIn: response.tokens.expiresIn,
        rememberMe: false, // Default to false for registration
      );

      return Right(response.user);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    try {
      final response = await _remoteDataSource.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      await _secureStorage.storeTokens(
        accessToken: response.tokens.accessToken,
        refreshToken: response.tokens.refreshToken,
        expiresIn: response.tokens.expiresIn,
        rememberMe: rememberMe,
      );

      return Right(response.user);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken != null) {
        await _remoteDataSource.logout(refreshToken: refreshToken);
      }
      await _secureStorage.clearTokens();
      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, User>> getCurrentUser() async {
    try {
      if (!await _secureStorage.hasValidToken()) {
        return Left(AuthenticationFailure(message: 'Session expired'));
      }
      final user = await _remoteDataSource.getCurrentUser();
      return Right(user);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> isAuthenticated() async {
    try {
      final hasValidToken = await _secureStorage.hasValidToken();
      return Right(hasValidToken);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> refreshToken() async {
    try {
      final refreshToken = await _secureStorage.getRefreshToken();
      if (refreshToken == null) {
        return Left(AuthenticationFailure(message: 'No refresh token found'));
      }

      final response = await _remoteDataSource.refreshToken(
        refreshToken: refreshToken,
      );

      await _secureStorage.storeTokens(
        accessToken: response.accessToken,
        refreshToken: response.refreshToken,
        expiresIn: response.expiresIn,
        rememberMe: await _secureStorage.isRememberMeEnabled(),
      );

      return const Right(null);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
} 