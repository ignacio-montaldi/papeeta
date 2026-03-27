class UserDto {
  final String id;
  final String name;
  final String? email;

  UserDto({required this.id, required this.name, this.email});

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json["uid"] ?? json["id"] ?? '',
      name: json["nombre"],
      email: json["email"],
    );
  }
}
