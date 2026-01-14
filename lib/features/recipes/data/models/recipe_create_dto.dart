import 'package:papeeta/features/recipes/data/models/ingredient_create_dto.dart';
import 'package:papeeta/features/recipes/data/models/preparation_step_dto.dart';

class RecipeCreateDto {
  final String title;
  final String subtitle;
  final String? link;
  final List<int> categories;
  final List<IngredientCreateDto> ingredients;
  final List<PreparationStepDto> preparationSteps;

  RecipeCreateDto({
    required this.title,
    required this.subtitle,
    required this.categories,
    required this.ingredients,
    required this.preparationSteps,
    this.link,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'subtitle': subtitle,
      'link': link,
      'categories': categories,
      'ingredients': ingredients.map((e) => e.toJson()).toList(),
      'preparationSteps': preparationSteps.map((e) => e.toJson()).toList(),
    };
  }
}
