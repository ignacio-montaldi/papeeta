import 'package:papeeta/core/domain/entities/category.dart';
import 'package:papeeta/features/recipes/data/mappers/category_group_mapper.dart';
import 'package:papeeta/features/recipes/data/models/category_dto.dart';

class CategoryMapper {
  static Category toEntity(CategoryDto dto) {
    return Category(
      id: dto.id,
      name: dto.name,
      imageUrl: dto.imageUrl,
      groupId: dto.groupId,
      group: dto.group != null
          ? CategoryGroupMapper.toEntity(dto.group!)
          : null,
    );
  }
}
