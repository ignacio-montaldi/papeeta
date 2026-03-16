import 'package:papeeta/global/enviroment.dart';

import '../../../../core/domain/entities/category.dart';
import '../models/category_dto.dart';
import 'category_group_mapper.dart';

class CategoryMapper {
  static Category toEntity(CategoryDto dto) {
    return Category(
      id: dto.id,
      name: dto.name,
      groupId: dto.groupId ?? dto.group?.id,
      imageUrl: (dto.imageUrl != null && dto.imageUrl!.isNotEmpty)
          ? (dto.imageUrl!.startsWith('http')
                ? dto.imageUrl
                : '${Enviroment.baseUrl}${dto.imageUrl}')
          : dto.imageUrl,
      group: dto.group != null
          ? CategoryGroupMapper.toEntity(dto.group!)
          : null,
    );
  }
}
