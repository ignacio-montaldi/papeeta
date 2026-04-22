part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  bool get isLoading => false;

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthChecking extends AuthState {}

class AuthLoading extends AuthState {
  const AuthLoading();

  @override
  bool get isLoading => true;
}

class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

class ProfileUpdateSuccess extends AuthState {
  final User user;

  const ProfileUpdateSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class ProfileUpdateError extends AuthState {
  final String message;
  final User user;

  const ProfileUpdateError(this.message, this.user);

  @override
  List<Object?> get props => [message, user];
}

class ProfileUpdating extends Authenticated {
  const ProfileUpdating(super.user);

  @override
  bool get isLoading => true;
}
