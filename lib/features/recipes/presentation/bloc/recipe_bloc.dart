import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';
import 'package:papeeta/features/recipes/domain/repositories/recipes_repository.dart';

part 'recipe_event.dart';
part 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final RecipesRepository repository;

  List<Recipe>? _cachedHomeRecipes;

  RecipeBloc(this.repository) : super(const RecipeInitial()) {
    on<LoadRecipes>(_onLoadRecipes);
    on<LoadRecipeDetail>(_onLoadRecipeDetail);
    on<LoadRecipesByCategory>(_onLoadByCategory);
    on<SelectRecipe>(_onSelectRecipe);
    on<RestoreHomeRecipes>(_onRestoreHomeRecipes);
  }

  List<Recipe> _currentRecipesList(RecipeState state) {
    return switch (state) {
      RecipeListLoaded(:final recipes) => recipes,
      RecipeDetailLoaded(:final recipes) => recipes,
      _ => [],
    };
  }

  Future<void> _onLoadRecipes(
    LoadRecipes event,
    Emitter<RecipeState> emit,
  ) async {
    emit(const RecipeListLoading());
    try {
      final recipes = await repository.getRecipes();
      _cachedHomeRecipes = recipes;
      emit(RecipeListLoaded(recipes));
    } catch (e) {
      emit(RecipeError('Error al cargar recetas'));
    }
  }

  void _onRestoreHomeRecipes(
    RestoreHomeRecipes event,
    Emitter<RecipeState> emit,
  ) {
    if (_cachedHomeRecipes != null) {
      emit(RecipeListLoaded(_cachedHomeRecipes!));
    }
  }

  Future<void> _onLoadRecipeDetail(
    LoadRecipeDetail event,
    Emitter<RecipeState> emit,
  ) async {
    final previousRecipes = _currentRecipesList(state);
    emit(RecipeDetailLoading(recipeId: event.id));
    try {
      final recipe = await repository.getRecipeById(event.id);
      emit(RecipeDetailLoaded(recipe, previousRecipes));
    } catch (e, stackTrace) {
      debugPrint('Error en LoadRecipeDetail: $e');
      debugPrint('$stackTrace');
      emit(RecipeError('Error al cargar la receta'));
    }
  }

  Future<void> _onLoadByCategory(
    LoadRecipesByCategory event,
    Emitter<RecipeState> emit,
  ) async {
    emit(const RecipeListLoading());
    try {
      final recipes = await repository.getRecipesByCategory(event.categoryId);
      emit(RecipeListLoaded(recipes));
    } catch (e) {
      emit(RecipeError('Error al cargar recetas por categoría'));
    }
  }

  void _onSelectRecipe(SelectRecipe event, Emitter<RecipeState> emit) {
    final recipes = _currentRecipesList(state);
    emit(RecipeDetailLoaded(event.recipe, recipes));
  }
}
