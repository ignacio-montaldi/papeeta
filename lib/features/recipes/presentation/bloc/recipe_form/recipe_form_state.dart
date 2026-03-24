part of 'recipe_form_cubit.dart';

class RecipeFormState {
  final String title;
  final String description;
  final String? sourceLink;

  final List<Ingredient> ingredients;
  final List<PreparationStep> steps;
  final List<Category> categories;
  final List<RecipeImageUpload> images;
  final List<int> ingredientUiKeys;
  final List<int> stepUiKeys;

  final Map<String, String> errors;
  final bool isValid;

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
    this.ingredientUiKeys = const [],
    this.stepUiKeys = const [],

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
    List<Ingredient>? ingredients,
    List<PreparationStep>? steps,
    List<Category>? categories,
    List<RecipeImageUpload>? images,
    List<int>? ingredientUiKeys,
    List<int>? stepUiKeys,

    Map<String, String>? errors,
    bool? isValid,

    bool? isSubmitting,
    bool? submitSuccess,
    String? submitError,
    bool clearSubmitError = false,
  }) {
    return RecipeFormState(
      title: title ?? this.title,
      description: description ?? this.description,
      sourceLink: sourceLink ?? this.sourceLink,
      ingredients: ingredients ?? this.ingredients,
      steps: steps ?? this.steps,
      categories: categories ?? this.categories,
      images: images ?? this.images,
      ingredientUiKeys: ingredientUiKeys ?? this.ingredientUiKeys,
      stepUiKeys: stepUiKeys ?? this.stepUiKeys,

      errors: errors ?? this.errors,
      isValid: isValid ?? this.isValid,

      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
    );
  }
}
