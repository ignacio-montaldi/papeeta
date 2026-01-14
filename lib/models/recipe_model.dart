import 'package:papeeta/models/models.dart';

class RecipeModel {
  final int id;
  final String title;
  final String subtitle;
  final List<MyImageModel> images;
  final List<IngredientModel> ingredients;
  final List<CategoryModel> categories;
  final List<PreparationStepModel> preparationSteps;
  final String? link;
  final UsuarioModel? author;

  RecipeModel({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.images,
    required this.ingredients,
    required this.categories,
    required this.preparationSteps,
    this.link,
    this.author,
  });
}
