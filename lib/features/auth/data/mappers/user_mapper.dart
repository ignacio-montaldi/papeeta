import 'package:papeeta/features/auth/domain/entities/user.dart';
import 'package:papeeta/features/auth/data/models/user_dto.dart';

class UserMapper {
  static User toEntity(UserDto dto) {
    return User(
      id: dto.id,
      nombreUsuario: dto.nombreUsuario,
      alias: dto.alias,
      email: dto.email,
    );
  }
}
