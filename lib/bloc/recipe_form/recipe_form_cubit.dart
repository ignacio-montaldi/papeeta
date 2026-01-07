import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:papeeta/models/models.dart';

part 'recipe_form_state.dart';

class RecipeFormCubit extends Cubit<RecipeFormState> {
  RecipeFormCubit() : super(const RecipeFormState());

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
          ammount: null,
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
    int index, {
    double? ammount,
    String? measure,
    String? name,
  }) {
    final ingredient = state.ingredients[index];
    ingredient
      ..ammount = ammount ?? ingredient.ammount
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

    // 🥕 Ingredientes
    if (state.ingredients.isEmpty) {
      errors['ingredients'] = 'Debe agregar al menos un ingrediente';
    } else {
      for (int i = 0; i < state.ingredients.length; i++) {
        final ing = state.ingredients[i];

        if (ing.name.trim().isEmpty) {
          errors['ingredient_$i'] = 'El ingrediente ${i + 1} no tiene nombre';
        }

        if (ing.ammount == null || ing.ammount! <= 0) {
          errors['ingredient_amount_$i'] =
              'Cantidad inválida en ingrediente ${i + 1}';
        }

        if (ing.measure == null || ing.measure!.isEmpty) {
          errors['ingredient_unit_$i'] =
              'Unidad no seleccionada en ingrediente ${i + 1}';
        }
      }
    }

    // 🍳 Pasos
    if (state.steps.isEmpty) {
      errors['steps'] = 'Debe agregar al menos un paso';
    } else {
      for (int i = 0; i < state.steps.length; i++) {
        if (state.steps[i].description.trim().isEmpty) {
          errors['step_$i'] = 'El paso ${i + 1} no puede estar vacío';
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

    final updated = List<File>.from(state.images)..add(File(pickedFile.path));

    emit(state.copyWith(images: updated));
  }

  void removeImage(int index) {
    final updated = List<File>.from(state.images)..removeAt(index);
    emit(state.copyWith(images: updated));
  }
}
