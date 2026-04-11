import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../core/security/secure_storage.dart';
import '../../../core/error/exceptions.dart';
import '../../../core/utils/error_message.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;
  final SecureStorage _secureStorage;

  AuthBloc(this._authRepository, this._secureStorage)
      : super(const AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthGoogleLoginRequested>(_onGoogleLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onCheckRequested(
      AuthCheckRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      debugPrint('[AuthBloc] checking token...');
      final hasToken = await _secureStorage
          .hasToken()
          .timeout(const Duration(seconds: 5));
      debugPrint('[AuthBloc] hasToken=$hasToken');
      if (!hasToken) {
        emit(const AuthUnauthenticated());
        return;
      }
      debugPrint('[AuthBloc] fetching user...');
      final user =
          await _authRepository.getUser().timeout(const Duration(seconds: 8));
      debugPrint('[AuthBloc] authenticated: ${user.email}');
      emit(AuthAuthenticated(user));
    } catch (e) {
      debugPrint('[AuthBloc] check failed: $e');
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
      AuthLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      debugPrint('[AuthBloc] login start: ${event.email}');
      final user = await _authRepository
          .login(email: event.email, password: event.password)
          .timeout(const Duration(seconds: 15));
      debugPrint('[AuthBloc] login success: ${user.email}');
      emit(AuthAuthenticated(user));
    } catch (e) {
      debugPrint('[AuthBloc] login error: $e');
      emit(AuthError(extractErrorMessage(e)));
    }
  }

  Future<void> _onRegisterRequested(
      AuthRegisterRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.register(
        name: event.name,
        email: event.email,
        password: event.password,
        passwordConfirmation: event.passwordConfirmation,
      );
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(extractErrorMessage(e)));
    }
  }

  Future<void> _onGoogleLoginRequested(
      AuthGoogleLoginRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    try {
      final user = await _authRepository.googleLogin(idToken: event.idToken);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError(extractErrorMessage(e)));
    }
  }

  Future<void> _onLogoutRequested(
      AuthLogoutRequested event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
