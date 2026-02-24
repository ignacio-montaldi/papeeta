import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';
import 'package:papeeta/features/recipes/domain/repositories/recipes_repository.dart';

part 'recipe_event.dart';
part 'recipe_state.dart';

class RecipeBloc extends Bloc<RecipeEvent, RecipeState> {
  final RecipesRepository repository;

  RecipeBloc(this.repository) : super(const RecipeInitial()) {
    on<LoadRecipes>(_onLoadRecipes);
    on<LoadRecipeDetail>(_onLoadRecipeDetail);
    on<LoadRecipesByCategory>(_onLoadByCategory);
    on<SelectRecipe>(_onSelectRecipe);
  }

  Future<void> _onLoadRecipes(
    LoadRecipes event,
    Emitter<RecipeState> emit,
  ) async {
    final currentSelectedRecipe = state is RecipeListLoaded
        ? (state as RecipeListLoaded).selectedRecipe
        : state is RecipeDetailLoaded
        ? (state as RecipeDetailLoaded).recipe
        : null;

    emit(RecipeLoading(recipes: state.currentRecipes));
    try {
      final recipes = await repository.getRecipes();
      emit(RecipeListLoaded(recipes, selectedRecipe: currentSelectedRecipe));
    } catch (e) {
      emit(
        RecipeError('Error al cargar recetas', recipes: state.currentRecipes),
      );
    }
  }

  Future<void> _onLoadRecipeDetail(
    LoadRecipeDetail event,
    Emitter<RecipeState> emit,
  ) async {
    emit(RecipeLoading(recipes: state.currentRecipes));
    try {
      final recipe = await repository.getRecipeById(event.id);
      emit(RecipeDetailLoaded(recipe, recipes: state.currentRecipes));
    } catch (e, stackTrace) {
      print('=== ERROR EN _onLoadRecipeDetail ===');
      print(e);
      print(stackTrace);
      emit(
        RecipeError('Error al cargar la receta', recipes: state.currentRecipes),
      );
    }
  }

  Future<void> _onLoadByCategory(
    LoadRecipesByCategory event,
    Emitter<RecipeState> emit,
  ) async {
    final currentSelectedRecipe = state is RecipeListLoaded
        ? (state as RecipeListLoaded).selectedRecipe
        : state is RecipeDetailLoaded
        ? (state as RecipeDetailLoaded).recipe
        : null;

    emit(RecipeLoading(recipes: state.currentRecipes));
    try {
      final recipes = await repository.getRecipesByCategory(event.categoryId);
      emit(RecipeListLoaded(recipes, selectedRecipe: currentSelectedRecipe));
    } catch (e) {
      emit(
        RecipeError(
          'Error al cargar recetas por categoría',
          recipes: state.currentRecipes,
        ),
      );
    }
  }

  void _onSelectRecipe(SelectRecipe event, Emitter<RecipeState> emit) {
    emit(RecipeDetailLoaded(event.recipe, recipes: state.currentRecipes));
  }
}
