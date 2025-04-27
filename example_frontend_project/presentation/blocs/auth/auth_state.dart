import 'package:equatable/equatable.dart';
import 'package:ironiq/core/error/failures.dart';
import 'package:ironiq/domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class AuthAuthenticated extends AuthState {
  final User user;

  const AuthAuthenticated(this.user);

  @override
  List<Object> get props => [user];
}

class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

class AuthFailure extends AuthState {
  final Failure failure;

  const AuthFailure(this.failure);

  @override
  List<Object> get props => [failure];
} 