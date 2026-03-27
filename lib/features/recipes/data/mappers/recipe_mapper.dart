import 'package:papeeta/features/recipes/data/mappers/category_mapper.dart';
import 'package:papeeta/features/recipes/data/mappers/ingredient_mapper.dart';

import 'package:papeeta/features/recipes/data/mappers/preparation_step_mapper.dart';
import 'package:papeeta/features/recipes/data/mappers/recipe_image_mapper.dart';
import 'package:papeeta/features/recipes/data/mappers/user_mapper.dart';
import 'package:papeeta/features/recipes/data/models/recipe_create_dto.dart';
import 'package:papeeta/features/recipes/data/models/recipe_response_dto.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';

class RecipeMapper {
  static Recipe toEntity(RecipeResponseDto dto) {
    return Recipe(
      id: dto.id,
      title: dto.title,
      subtitle: dto.subtitle,
      link: dto.link,
      ingredients: dto.ingredients
          .map(IngredientMapper.fromResponseDto)
          .toList(),
      steps: dto.preparationSteps.map(PreparationStepMapper.toEntity).toList(),
      categories: dto.categories.map(CategoryMapper.toEntity).toList(),
      images: dto.images.map(RecipeImageMapper.toEntity).toList(),
      author: dto.author != null ? UserMapper.toEntity(dto.author!) : null,
    );
  }

  static RecipeCreateDto toCreateDto(Recipe recipe) {
    return RecipeCreateDto(
      title: recipe.title,
      subtitle: recipe.subtitle,
      link: recipe.link,
      categories: recipe.categories.map((c) => c.id).toList(),
      ingredients: recipe.ingredients
          .map(IngredientMapper.toCreateDto)
          .toList(),
      preparationSteps: recipe.steps.map(PreparationStepMapper.toDto).toList(),
    );
  }
}
