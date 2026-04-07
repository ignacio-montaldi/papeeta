class User {
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
}
