part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested(this.email, this.password);

  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String alias;
  final String nombreUsuario;
  final String email;
  final String password;

  const RegisterRequested(this.alias, this.nombreUsuario, this.email, this.password);

  @override
  List<Object> get props => [alias, nombreUsuario, email, password];
}

class LogoutRequested extends AuthEvent {}
