import 'package:papeeta/global/enviroment.dart';

import '../../../../core/domain/entities/category_group.dart';
import '../models/category_group_dto.dart';

class CategoryGroupMapper {
  static CategoryGroup toEntity(CategoryGroupDto dto) {
    String? imageUrl;
    if (dto.imageUrl != null && dto.imageUrl!.isNotEmpty) {
      final raw = dto.imageUrl!;
      imageUrl = raw.startsWith('http')
          ? raw
          : '${Enviroment.baseUrl}/${raw.replaceFirst(RegExp(r'^/'), '')}';
    }
    return CategoryGroup(id: dto.id, name: dto.name, imageUrl: imageUrl);
  }
}
