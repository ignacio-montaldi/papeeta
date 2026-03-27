import 'package:papeeta/features/auth/domain/entities/user.dart';
import 'package:papeeta/features/auth/data/models/user_dto.dart';

class UserMapper {
  static User toEntity(UserDto dto) {
    return User(
      id: dto.id,
      name: dto.name,
      email: dto.email,
    );
  }
}
