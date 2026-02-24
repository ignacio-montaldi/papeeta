part of 'recipe_bloc.dart';

abstract class RecipeState {}

class RecipeInitial extends RecipeState {}

class RecipeLoading extends RecipeState {}

class RecipeListLoaded extends RecipeState {
  final List<Recipe> recipes;
  RecipeListLoaded(this.recipes);
}

class RecipeDetailLoaded extends RecipeState {
  final Recipe recipe;
  RecipeDetailLoaded(this.recipe);
}

class RecipeError extends RecipeState {
  final String message;
  RecipeError(this.message);
}
