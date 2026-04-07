class UserDto {
  final String id;
  final String nombreUsuario;
  final String? alias;
  final String? email;

  UserDto({required this.id, required this.nombreUsuario, this.alias, this.email});

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'].toString(),
      nombreUsuario: json['nombre_usuario'] ?? json['name'] ?? '',
      alias: json['alias'],
      email: json['email'],
    );
  }
}
