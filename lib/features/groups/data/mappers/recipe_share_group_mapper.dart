import 'package:papeeta/core/domain/entities/recipe_share_group.dart';
import 'package:papeeta/features/auth/data/mappers/user_mapper.dart';
import 'package:papeeta/features/recipes/data/mappers/recipe_mapper.dart';
import 'package:papeeta/features/groups/data/models/recipe_share_group_dto.dart';

class RecipeShareGroupMapper {
  static RecipeShareGroup toEntity(RecipeShareGroupDto dto) {
    return RecipeShareGroup(
      id: dto.id,
      name: dto.name,
      description: dto.description,
      imageUrl: dto.imageUrl,
      owner: dto.owner != null ? UserMapper.toEntity(dto.owner!) : null,
      members: dto.members.map((e) => UserMapper.toEntity(e)).toList(),
      recipes: dto.recipes.map((e) => RecipeMapper.toEntity(e)).toList(),
      createdAt: dto.createdAt != null ? DateTime.parse(dto.createdAt!) : null,
    );
  }
}
