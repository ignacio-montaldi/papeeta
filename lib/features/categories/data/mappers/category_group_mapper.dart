import 'package:papeeta/core/domain/entities/category_group.dart';

import '../models/category_group_dto.dart';

class CategoryGroupMapper {
  static CategoryGroup toEntity(CategoryGroupDto dto) {
    return CategoryGroup(id: dto.id, name: dto.name);
  }
}
