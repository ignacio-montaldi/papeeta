import 'package:papeeta/features/recipes/data/models/recipe_image_upload_dto.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe_image_upload.dart';
import 'package:papeeta/global/enviroment.dart';

import '../../domain/entities/recipe_image.dart';
import '../models/recipe_image_dto.dart';

class RecipeImageMapper {
  static RecipeImage toEntity(RecipeImageDto dto) {
    return RecipeImage(
      id: dto.id,
      url: (dto.url.isNotEmpty)
          ? (dto.url.startsWith('http')
              ? dto.url
              : '${Enviroment.baseUrl}${dto.url}')
          : dto.url,
    );
  }

  static RecipeImageUploadDto toUploadDto(RecipeImageUpload entity) {
    return RecipeImageUploadDto(file: entity.file);
  }
}
