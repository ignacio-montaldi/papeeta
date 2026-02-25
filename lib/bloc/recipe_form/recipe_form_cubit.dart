import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:papeeta/helpers/helpers.dart';
import 'package:papeeta/core/domain/entities/category.dart';
import 'package:papeeta/features/recipes/domain/entities/ingredient.dart';
import 'package:papeeta/features/recipes/domain/entities/ingredient_unit.dart';
import 'package:papeeta/features/recipes/domain/entities/preparation_step.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe_image_upload.dart';
import 'package:papeeta/features/recipes/domain/repositories/recipes_repository.dart';

part 'recipe_form_state.dart';

class RecipeFormCubit extends Cubit<RecipeFormState> {
  final RecipesRepository recipesRepository;

  RecipeFormCubit(this.recipesRepository) : super(const RecipeFormState());

  int _nextIngredientUiKey = 0;
  int _nextStepUiKey = 0;

  void setTitle(String value) => emit(state.copyWith(title: value));

  void setDescription(String value) => emit(state.copyWith(description: value));

  void setSourceLink(String? value) => emit(state.copyWith(sourceLink: value));

  void addIngredient() {
    final list = List<Ingredient>.from(state.ingredients)
      ..add(const Ingredient(amount: null, unit: null, name: ''));
    final keys = List<int>.from(state.ingredientUiKeys)
      ..add(_nextIngredientUiKey++);

    emit(state.copyWith(ingredients: list, ingredientUiKeys: keys));
  }

  void removeIngredient(int index) {
    final list = List<Ingredient>.from(state.ingredients)..removeAt(index);
    final keys = List<int>.from(state.ingredientUiKeys)..removeAt(index);

    emit(state.copyWith(ingredients: list, ingredientUiKeys: keys));
  }

  void updateIngredient(
    int ingredientIndex, {
    Object? amount = _noChange,
    Object? unit = _noChange,
    String? name,
  }) {
    final current = state.ingredients[ingredientIndex];
    final updated = Ingredient(
      amount: identical(amount, _noChange)
          ? current.amount
          : amount as double?,
      unit: identical(unit, _noChange) ? current.unit : unit as IngredientUnit?,
      name: name ?? current.name,
    );
    final list = List<Ingredient>.from(state.ingredients)
      ..[ingredientIndex] = updated;

    emit(state.copyWith(ingredients: list));
  }

  void addStep() {
    final list = List<PreparationStep>.from(state.steps)
      ..add(PreparationStep(order: state.steps.length + 1, description: ''));
    final keys = List<int>.from(state.stepUiKeys)..add(_nextStepUiKey++);

    emit(state.copyWith(steps: list, stepUiKeys: keys));
  }

  void updateStep(int index, String description) {
    final current = state.steps[index];
    final steps = List<PreparationStep>.from(state.steps)
      ..[index] = PreparationStep(order: current.order, description: description);

    emit(state.copyWith(steps: steps));
  }

  void removeStep(int index) {
    final steps = List<PreparationStep>.from(state.steps)..removeAt(index);
    final keys = List<int>.from(state.stepUiKeys)..removeAt(index);
    for (int i = 0; i < steps.length; i++) {
      steps[i] = PreparationStep(order: i + 1, description: steps[i].description);
    }

    emit(state.copyWith(steps: steps, stepUiKeys: keys));
  }

  void validateForm() {
    final errors = <String, String>{};

    if (state.title.trim().isEmpty) {
      errors['title'] = 'El nombre es obligatorio';
    }

    if (state.sourceLink != null &&
        state.sourceLink!.isNotEmpty &&
        !isValidUrl(state.sourceLink!.trim())) {
      errors['link'] = 'Ingrese una URL válida';
    }

    if (state.categories.isEmpty) {
      errors['categories'] = 'Debe seleccionar al menos una categoría';
    }

    if (state.ingredients.isEmpty) {
      errors['ingredients'] = 'Debe agregar al menos un ingrediente';
    } else {
      for (int i = 0; i < state.ingredients.length; i++) {
        final ing = state.ingredients[i];

        if (ing.name.trim().isEmpty) {
          errors['ingredient_$i'] = 'El ingrediente no tiene nombre';
        }

        if (ing.amount == null || ing.amount! <= 0) {
          errors['ingredient_amount_$i'] = 'Cantidad inválida';
        }

        if (ing.unit == null || ing.unit!.name.trim().isEmpty) {
          errors['ingredient_unit_$i'] = 'Unidad no seleccionada';
        }
      }
    }

    if (state.steps.isEmpty) {
      errors['steps'] = 'Debe agregar al menos un paso';
    } else {
      for (int i = 0; i < state.steps.length; i++) {
        if (state.steps[i].description.trim().isEmpty) {
          errors['step_$i'] = 'El paso no puede estar vacío';
        }
      }
    }

    if (state.images.isEmpty) {
      errors['images'] = 'Debe agregar al menos una imagen';
    }

    emit(state.copyWith(errors: errors, isValid: errors.isEmpty));
  }

  void reorderSteps(int oldIndex, int newIndex) {
    final steps = List<PreparationStep>.from(state.steps);

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final step = steps.removeAt(oldIndex);
    steps.insert(newIndex, step);
    final keys = List<int>.from(state.stepUiKeys);
    final movedKey = keys.removeAt(oldIndex);
    keys.insert(newIndex, movedKey);

    for (int i = 0; i < steps.length; i++) {
      steps[i] = PreparationStep(order: i + 1, description: steps[i].description);
    }

    emit(state.copyWith(steps: steps, stepUiKeys: keys));
  }

  void reorderIngredients(int oldIndex, int newIndex) {
    final ingredients = List<Ingredient>.from(state.ingredients);
    final keys = List<int>.from(state.ingredientUiKeys);
    if (newIndex > oldIndex) {
      newIndex--;
    }

    final movedIngredient = ingredients.removeAt(oldIndex);
    ingredients.insert(newIndex, movedIngredient);
    final movedKey = keys.removeAt(oldIndex);
    keys.insert(newIndex, movedKey);

    emit(state.copyWith(ingredients: ingredients, ingredientUiKeys: keys));
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1280,
    );

    if (pickedFile == null) return;

    final updated = List<RecipeImageUpload>.from(state.images)
      ..add(RecipeImageUpload(file: File(pickedFile.path)));

    emit(state.copyWith(images: updated));
  }

  void removeImage(int index) {
    final updated = List<RecipeImageUpload>.from(state.images)
      ..removeAt(index);
    emit(state.copyWith(images: updated));
  }

  void toggleCategory(Category category) {
    final updated = List<Category>.from(state.categories);

    if (updated.any((c) => c.id == category.id)) {
      updated.removeWhere((c) => c.id == category.id);
    } else {
      updated.add(category);
    }

    emit(state.copyWith(categories: updated));
  }

  bool isCategorySelected(Category category) {
    return state.categories.any((c) => c.id == category.id);
  }

  Recipe buildRecipe() {
    return Recipe(
      id: 0,
      title: state.title,
      subtitle: state.description,
      images: const [],
      ingredients: state.ingredients,
      categories: state.categories,
      steps: state.steps,
      link: state.sourceLink,
      author: null,
    );
  }

  Future<void> submit() async {
    validateForm();

    if (!state.isValid) return;

    emit(
      state.copyWith(
        isSubmitting: true,
        submitSuccess: false,
        clearSubmitError: true,
      ),
    );

    try {
      final recipe = buildRecipe();
      final recipeId = await recipesRepository.createRecipe(recipe);
      await recipesRepository.uploadRecipeImages(
        recipeId: recipeId,
        images: state.images,
      );

      emit(state.copyWith(isSubmitting: false, submitSuccess: true));
    } catch (e) {
      emit(
        state.copyWith(
          isSubmitting: false,
          submitError: 'Error al guardar la receta',
        ),
      );
    }
  }
}

const Object _noChange = Object();
