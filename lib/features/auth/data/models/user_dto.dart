class UserDto {
  final String id;
  final String nombreUsuario;
  final String? alias;
  final String? email;

  UserDto({required this.id, required this.nombreUsuario, this.alias, this.email});

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json["uid"] ?? json["id"] ?? '',
      nombreUsuario: json["nombre_usuario"] ?? '',
      alias: json["alias"],
      email: json["email"],
    );
  }
}
