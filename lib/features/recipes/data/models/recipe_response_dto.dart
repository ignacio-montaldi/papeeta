import 'package:papeeta/features/recipes/data/models/category_dto.dart';
import 'package:papeeta/features/recipes/data/models/ingredient_response_dto.dart';
import 'package:papeeta/features/recipes/data/models/preparation_step_dto.dart';
import 'package:papeeta/features/recipes/data/models/recipe_image_dto.dart';
import 'package:papeeta/features/recipes/data/models/user_dto.dart';

class RecipeResponseDto {
  final int id;
  final String title;
  final String subtitle;
  final String? link;

  final List<IngredientResponseDto> ingredients;
  final List<PreparationStepDto> preparationSteps;

  final List<CategoryDto> categories;
  final List<RecipeImageDto> images;

  final UserDto? author;

  RecipeResponseDto({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.ingredients,
    required this.preparationSteps,
    required this.categories,
    required this.images,
    this.link,
    this.author,
  });

  factory RecipeResponseDto.fromJson(Map<String, dynamic> json) {
    return RecipeResponseDto(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      link: json['link'],
      ingredients: (json['ingredients'] as List<dynamic>)
          .map((e) => IngredientResponseDto.fromJson(e))
          .toList(),
      preparationSteps: (json['preparationSteps'] as List<dynamic>)
          .map((e) => PreparationStepDto.fromJson(e))
          .toList(),
      categories: (json['categories'] as List<dynamic>)
          .map((e) => CategoryDto.fromJson(e))
          .toList(),
      images: (json['images'] as List<dynamic>)
          .map((e) => RecipeImageDto.fromJson(e))
          .toList(),
      author: json['author'] != null ? UserDto.fromJson(json['author']) : null,
    );
  }
}
