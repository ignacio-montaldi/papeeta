import 'package:papeeta/models/models.dart';
import 'package:papeeta/models/response/response_models.dart';

class RecipeModel {
  final int id;
  final String title;
  final String subtitle;
  final List<String> imagesUrl;
  final List<IngredientModel> ingredients;
  final List<CategoryModel> categories;
  final List<PreparationStepModel> preparationSteps;

  RecipeModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.imagesUrl,
    required this.ingredients,
    required this.categories,
    required this.preparationSteps,
  });
}
