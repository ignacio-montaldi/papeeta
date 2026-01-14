part of 'recipe_form_cubit.dart';

class RecipeFormState {
  final String title;
  final String description;
  final String? sourceLink;

  final List<IngredientModel> ingredients;
  final List<PreparationStepModel> steps;
  final List<CategoryModel> categories;
  final List<MyImageModel> images;

  final UsuarioModel? author;

  // validation
  final Map<String, String> errors;
  final bool isValid;

  // submit lifecycle
  final bool isSubmitting;
  final bool submitSuccess;
  final String? submitError;

  const RecipeFormState({
    this.title = '',
    this.description = '',
    this.sourceLink,
    this.ingredients = const [],
    this.steps = const [],
    this.categories = const [],
    this.images = const [],
    this.author,

    this.errors = const {},
    this.isValid = false,

    this.isSubmitting = false,
    this.submitSuccess = false,
    this.submitError,
  });

  RecipeFormState copyWith({
    String? title,
    String? description,
    String? sourceLink,
    List<IngredientModel>? ingredients,
    List<PreparationStepModel>? steps,
    List<CategoryModel>? categories,
    List<MyImageModel>? images,
    UsuarioModel? author,

    Map<String, String>? errors,
    bool? isValid,

    bool? isSubmitting,
    bool? submitSuccess,
    String? submitError,
  }) {
    return RecipeFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      sourceLink: sourceLink ?? this.sourceLink,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      categories: categories ?? this.categories,
      images: images ?? this.images,
      author: author ?? this.author,

      errors: errors ?? this.errors,
      isValid: isValid ?? this.isValid,

      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      submitError: submitError,
    );
  }
}
