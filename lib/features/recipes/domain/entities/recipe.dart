import 'package:papeeta/core/domain/entities/category.dart';
import 'package:papeeta/features/recipes/domain/entities/ingredient.dart';
import 'package:papeeta/features/recipes/domain/entities/preparation_step.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe_image.dart';
import 'package:papeeta/core/domain/entities/user.dart';

class Recipe {
  final int id;
  final String title;
  final String subtitle;
  final List<RecipeImage> images;
  final List<Ingredient> ingredients;
  final List<Category> categories;
  final List<PreparationStep> steps;
  final String? link;
  final User? author;

  const Recipe({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.images,
    required this.ingredients,
    required this.categories,
    required this.steps,
    this.link,
    this.author,
  });
}
