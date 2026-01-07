part of 'recipe_form_cubit.dart';

class RecipeFormState {
  final String title;
  final String description;
  final String? sourceLink;
  final List<IngredientModel> ingredients;
  final List<PreparationStepModel> steps;

  final Map<String, String> errors;
  final bool isValid;

  final List<File> images;

  const RecipeFormState({
    this.title = '',
    this.description = '',
    this.sourceLink,
    this.ingredients = const [],
    this.steps = const [],
    this.errors = const {},
    this.isValid = false,
    this.images = const [],
  });

  RecipeFormState copyWith({
    String? title,
    String? description,
    String? sourceLink,
    List<IngredientModel>? ingredients,
    List<PreparationStepModel>? steps,
    Map<String, String>? errors,
    bool? isValid,
    List<File>? images,
  }) {
    return RecipeFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      sourceLink: sourceLink ?? this.sourceLink,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      errors: errors ?? this.errors,
      isValid: isValid ?? this.isValid,
      images: images ?? this.images,
    );
  }
}
