import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String nombreUsuario;
  final String? alias;
  final String? email;

  const User({
    required this.id,
    required this.nombreUsuario,
    this.alias,
    this.email,
  });

  @override
  List<Object?> get props => [id, nombreUsuario, alias, email];
}
