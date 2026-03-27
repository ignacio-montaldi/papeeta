import 'package:papeeta/features/auth/data/models/user_dto.dart';

class AuthResponseDto {
  final bool ok;
  final UserDto user;
  final String token;

  AuthResponseDto({
    required this.ok,
    required this.user,
    required this.token,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      ok: json["ok"] ?? false,
      user: UserDto.fromJson(json["usuario"]),
      token: json["token"],
    );
  }
}
