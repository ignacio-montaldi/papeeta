import '../../../../core/domain/entities/user.dart';
import '../models/user_dto.dart';

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
