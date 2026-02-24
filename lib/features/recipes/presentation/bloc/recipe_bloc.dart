import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';
import 'package:papeeta/features/recipes/domain/repositories/recipes_repository.dart';

part 'recipe_event.dart';
part 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final RecipesRepository repository;

  RecipeBloc(this.repository) : super(RecipeInitial()) {
    on<LoadRecipes>(_onLoadRecipes);
    on<LoadRecipeDetail>(_onLoadRecipeDetail);
    on<LoadRecipesByCategory>(_onLoadByCategory);
  }

  Future<void> _onLoadRecipes(
    LoadRecipes event,
    Emitter<RecipeState> emit,
  ) async {
    emit(RecipeLoading());
    try {
      final recipes = await repository.getRecipes();
      emit(RecipeListLoaded(recipes));
    } catch (e) {
      emit(RecipeError('Error al cargar recetas'));
    }
  }

  Future<void> _onLoadRecipeDetail(
    LoadRecipeDetail event,
    Emitter<RecipeState> emit,
  ) async {
    emit(RecipeLoading());
    try {
      final recipe = await repository.getRecipeById(event.id);
      emit(RecipeDetailLoaded(recipe));
    } catch (e) {
      emit(RecipeError('Error al cargar la receta'));
    }
  }

  Future<void> _onLoadByCategory(
    LoadRecipesByCategory event,
    Emitter<RecipeState> emit,
  ) async {
    emit(RecipeLoading());

    try {
      // Ideal: método dedicado en repo
      final recipes = await repository.getRecipesByCategory(event.categoryId);

      emit(RecipeListLoaded(recipes));
    } catch (e, st) {
      debugPrint('❌ Error loading recipes by category: $e');
      debugPrint('$st');

      emit(RecipeError('Error al cargar recetas por categoría'));
    }
  }
}
