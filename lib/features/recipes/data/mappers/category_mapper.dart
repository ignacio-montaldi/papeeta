import '../../domain/entities/category.dart';
import '../models/category_dto.dart';
import 'category_group_mapper.dart';

class CategoryMapper {
  static Category toEntity(CategoryDto dto) {
    return Category(
      id: dto.id,
      name: dto.name,
      imageUrl: dto.imageUrl,
      group: dto.group != null
          ? CategoryGroupMapper.toEntity(dto.group!)
          : null,
    );
  }
}
