import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ironiq/domain/repositories/auth_repository.dart';
import 'package:ironiq/core/storage/secure_storage.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SecureStorage _secureStorage;
  Timer? _refreshTimer;

  AuthBloc({required AuthRepository authRepository})
      : _authRepository = authRepository,
        _secureStorage = SecureStorage(),
        super(const AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthRegisterRequested>(_onAuthRegisterRequested);
    on<AuthLoginRequested>(_onAuthLoginRequested);
    on<AuthLogoutRequested>(_onAuthLogoutRequested);
    on<AuthTokenRefreshRequested>(_onAuthTokenRefreshRequested);
  }

  void _scheduleTokenRefresh() async {
    _refreshTimer?.cancel();
    if (!await _secureStorage.hasValidToken()) return;

    final expiryStr = await _secureStorage.read('token_expiry');
    if (expiryStr == null) return;

    final expiry = int.parse(expiryStr);
    final now = DateTime.now().millisecondsSinceEpoch;
    final timeToExpiry = expiry - now;

    // Refresh 5 minutes before expiry
    final refreshDelay = Duration(milliseconds: timeToExpiry - (5 * 60 * 1000));
    if (refreshDelay.isNegative) {
      // Token is already expired or about to expire, refresh now
      add(AuthTokenRefreshRequested());
    } else {
      _refreshTimer = Timer(refreshDelay, () {
        add(AuthTokenRefreshRequested());
      });
    }
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    // First check if we have valid tokens
    final hasValidToken = await _secureStorage.hasValidToken();
    if (!hasValidToken) {
      emit(const AuthUnauthenticated());
      return;
    }

    // Only try to get the current user if we have valid tokens
    final userResult = await _authRepository.getCurrentUser();
    emit(
      userResult.fold(
        (failure) => const AuthUnauthenticated(),
        (user) {
          _scheduleTokenRefresh();
          return AuthAuthenticated(user);
        },
      ),
    );
  }

  Future<void> _onAuthRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _authRepository.register(
      email: event.email,
      password: event.password,
      firstName: event.firstName,
      lastName: event.lastName,
    );
    emit(result.fold(
      (failure) => AuthFailure(failure),
      (user) {
        _scheduleTokenRefresh();
        return AuthAuthenticated(user);
      },
    ));
  }

  Future<void> _onAuthLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    final result = await _authRepository.login(
      email: event.email,
      password: event.password,
      rememberMe: event.rememberMe,
    );
    emit(result.fold(
      (failure) => AuthFailure(failure),
      (user) {
        _scheduleTokenRefresh();
        return AuthAuthenticated(user);
      },
    ));
  }

  Future<void> _onAuthLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    _refreshTimer?.cancel();
    final result = await _authRepository.logout();
    emit(result.fold(
      (failure) => AuthFailure(failure),
      (_) => const AuthUnauthenticated(),
    ));
  }

  Future<void> _onAuthTokenRefreshRequested(
    AuthTokenRefreshRequested event,
    Emitter<AuthState> emit,
  ) async {
    final result = await _authRepository.refreshToken();
    result.fold(
      (failure) {
        emit(AuthFailure(failure));
        emit(const AuthUnauthenticated());
      },
      (_) {
        _scheduleTokenRefresh();
        // Don't emit a new state as this is a background operation
      },
    );
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    return super.close();
  }
}
