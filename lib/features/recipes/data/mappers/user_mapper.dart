import '../../../../core/domain/entities/user.dart';
import '../models/user_dto.dart';

class UserMapper {
  static User toEntity(UserDto dto) {
    return User(id: dto.id, name: dto.name, email: dto.email);
  }
}
