import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:papeeta/helpers/helpers.dart';
import 'package:papeeta/models/models.dart';
import 'package:papeeta/repositories/repositories.dart';

part 'recipe_form_state.dart';

class RecipeFormCubit extends Cubit<RecipeFormState> {
  final RecipesRepository recipesRepository;

  RecipeFormCubit(this.recipesRepository) : super(const RecipeFormState());

  int _tempIngredientId = -1;
  int _tempStepId = -1;

  // TEXTOS
  void setTitle(String value) => emit(state.copyWith(title: value));

  void setDescription(String value) => emit(state.copyWith(description: value));

  void setSourceLink(String? value) => emit(state.copyWith(sourceLink: value));

  // INGREDIENTES
  void addIngredient() {
    final list = List<IngredientModel>.from(state.ingredients)
      ..add(
        IngredientModel(
          tempId: _tempIngredientId--,
          amount: null,
          measure: null,
          name: '',
        ),
      );

    emit(state.copyWith(ingredients: list));
  }

  void removeIngredient(int index) {
    final list = List<IngredientModel>.from(state.ingredients)..removeAt(index);

    emit(state.copyWith(ingredients: list));
  }

  void updateIngredient(
    int ingredientIndex, {
    double? amount,
    IngredientUnitModel? measure,
    String? name,
  }) {
    final ingredient = state.ingredients[ingredientIndex];
    ingredient
      ..amount = amount ?? ingredient.amount
      ..measure = measure ?? ingredient.measure
      ..name = name ?? ingredient.name;

    emit(state.copyWith(ingredients: List.from(state.ingredients)));
  }

  // PASOS
  void addStep() {
    final list = List<PreparationStepModel>.from(state.steps)
      ..add(
        PreparationStepModel(
          tempId: _tempStepId--,
          stepNumber: state.steps.length + 1,
          description: '',
        ),
      );

    emit(state.copyWith(steps: list));
  }

  void updateStepById(int id, String description) {
    final steps = state.steps.map((s) {
      if (s.tempId == id) {
        return s.copyWith(description: description);
      }
      return s;
    }).toList();

    emit(state.copyWith(steps: steps));
  }

  void removeStepById(int id) {
    final steps = state.steps.where((s) => s.tempId != id).toList();

    for (int i = 0; i < steps.length; i++) {
      steps[i] = steps[i].copyWith(stepNumber: i + 1);
    }

    emit(state.copyWith(steps: steps));
  }

  void validateForm() {
    final errors = <String, String>{};

    // 🧾 Nombre
    if (state.title.trim().isEmpty) {
      errors['title'] = 'El nombre es obligatorio';
    }

    // ⛓️‍💥 Link
    if (state.sourceLink != null &&
        state.sourceLink!.isNotEmpty &&
        !isValidUrl(state.sourceLink!.trim())) {
      errors['link'] = 'Ingrese una URL válida';
    }

    // 🥕 Ingredientes
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

        if (ing.measure == null || ing.measure!.displayName.isEmpty) {
          errors['ingredient_unit_$i'] = 'Unidad no seleccionada';
        }
      }
    }

    // 🍳 Pasos
    if (state.steps.isEmpty) {
      errors['steps'] = 'Debe agregar al menos un paso';
    } else {
      for (int i = 0; i < state.steps.length; i++) {
        if (state.steps[i].description.trim().isEmpty) {
          errors['step_$i'] = 'El paso no puede estar vacío';
        }
      }
    }

    //  📷 Imágenes
    if (state.images.isEmpty) {
      errors['images'] = 'Debe agregar al menos una imagen';
    }

    emit(state.copyWith(errors: errors, isValid: errors.isEmpty));
  }

  void reorderSteps(int oldIndex, int newIndex) {
    final steps = List<PreparationStepModel>.from(state.steps);

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final step = steps.removeAt(oldIndex);
    steps.insert(newIndex, step);

    // Recalcular stepNumber
    for (int i = 0; i < steps.length; i++) {
      steps[i] = steps[i].copyWith(stepNumber: i + 1);
    }

    emit(state.copyWith(steps: steps));
  }

  void reorderIngredients(int oldIndex, int newIndex) {
    final ingredients = List<IngredientModel>.from(state.ingredients);

    // Ajuste requerido por ReorderableListView
    if (newIndex > oldIndex) {
      newIndex--;
    }

    final movedIngredient = ingredients.removeAt(oldIndex);
    ingredients.insert(newIndex, movedIngredient);

    emit(state.copyWith(ingredients: ingredients));
  }

  Future<void> pickImage(ImageSource source) async {
    final picker = ImagePicker();

    final pickedFile = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1280,
    );

    if (pickedFile == null) return;

    final updated = List<MyImageModel>.from(state.images)
      ..add(MyImageModel(file: File(pickedFile.path)));

    emit(state.copyWith(images: updated));
  }

  void removeImage(int index) {
    final updated = List<MyImageModel>.from(state.images)..removeAt(index);
    emit(state.copyWith(images: updated));
  }

  void toggleCategory(CategoryModel category) {
    final updated = List<CategoryModel>.from(state.categories);

    if (updated.any((c) => c.id == category.id)) {
      updated.removeWhere((c) => c.id == category.id);
    } else {
      updated.add(category);
    }

    emit(state.copyWith(categories: updated));
  }

  bool isCategorySelected(CategoryModel category) {
    return state.categories.any((c) => c.id == category.id);
  }

  RecipeModel buildPreviewRecipe() {
    return RecipeModel(
      id: -1, // dummy
      title: state.title,
      subtitle: state.description,
      images: state.images,
      ingredients: state.ingredients,
      categories: state.categories,
      preparationSteps: state.steps,
      link: state.sourceLink,
      author: state.author,
    );
  }

  void setAuthor(UsuarioModel user) {
    emit(state.copyWith(author: user));
  }

  Future<void> submit() async {
    validateForm();

    if (!state.isValid) return;

    emit(state.copyWith(isSubmitting: true, submitError: null));

    try {
      final payload = _buildRequest();

      await recipesRepository.createRecipe(
        payload: payload,
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

  Map<String, dynamic> _buildRequest() {
    return {
      "title": state.title,
      "subtitle": state.description,
      "link": state.sourceLink,
      "categories": state.categories.map((c) => c.id).toList(),
      "ingredients": state.ingredients
          .map(
            (i) => {
              "amount": i.amount,
              "measure_unit_id": i.measure?.id,
              "name": i.name,
            },
          )
          .toList(),

      "preparationSteps": state.steps
          .asMap()
          .entries
          .map(
            (entry) => {
              "step_number": entry.key + 1,
              "description": entry.value.description,
            },
          )
          .toList(),
    };
  }
}
