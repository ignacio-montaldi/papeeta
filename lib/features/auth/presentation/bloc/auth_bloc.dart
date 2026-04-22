import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/features/auth/domain/entities/user.dart';
import 'package:papeeta/features/auth/domain/repositories/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository repository;

  AuthBloc({required this.repository}) : super(AuthChecking()) {
    on<CheckAuthStatus>(_onCheckStatus);
    on<LoginRequested>(_onLogin);
    on<RegisterRequested>(_onRegister);
    on<LogoutRequested>(_onLogout);
    on<UpdateProfileRequested>(_onUpdateProfile);
  }

  Future<void> _onCheckStatus(
    CheckAuthStatus event,
    Emitter<AuthState> emit,
  ) async {
    final user = await repository.checkAuthStatus();
    if (user != null) {
      emit(Authenticated(user));
    } else {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogin(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await repository.login(event.email, event.password);
      emit(Authenticated(user));
    } catch (e) {
      emit(const AuthError('No se pudo iniciar sesión. Verificá tus datos.'));
      emit(Unauthenticated());
    }
  }

  Future<void> _onRegister(
    RegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await repository.register(
        event.alias,
        event.nombreUsuario,
        event.email,
        event.password,
      );
      emit(Authenticated(user));
    } catch (e) {
      emit(const AuthError('Error en el registro. Verificá tus datos.'));
      emit(Unauthenticated());
    }
  }

  Future<void> _onLogout(LogoutRequested event, Emitter<AuthState> emit) async {
    await repository.logout();
    emit(Unauthenticated());
  }

  Future<void> _onUpdateProfile(
    UpdateProfileRequested event,
    Emitter<AuthState> emit,
  ) async {
    final currentUser = state is Authenticated ? (state as Authenticated).user : null;
    if (currentUser == null) return;

    emit(ProfileUpdating(currentUser));
    try {
      final updatedUser = await repository.updateProfile(
        alias: event.alias,
        email: event.email,
        passwordNueva: event.passwordNueva,
        passwordActual: event.passwordActual,
        imagen: event.imagen as dynamic,
      );
      emit(Authenticated(updatedUser));
    } catch (e) {
      emit(ProfileUpdateError(e.toString(), currentUser));
      emit(Authenticated(currentUser));
    }
  }
}
