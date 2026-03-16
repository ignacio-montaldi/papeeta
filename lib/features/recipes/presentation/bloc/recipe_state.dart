part of 'recipe_bloc.dart';

sealed class RecipeState extends Equatable {
  const RecipeState();

  @override
  List<Object?> get props => [];
}

final class RecipeInitial extends RecipeState {
  const RecipeInitial();
}

final class RecipeListLoading extends RecipeState {
  const RecipeListLoading();
}

final class RecipeListLoaded extends RecipeState {
  final List<Recipe> recipes;
  const RecipeListLoaded(this.recipes);

  @override
  List<Object?> get props => [recipes];
}

final class RecipeDetailLoading extends RecipeState {
  final int? recipeId;
  const RecipeDetailLoading({this.recipeId});

  @override
  List<Object?> get props => [recipeId];
}

final class RecipeDetailLoaded extends RecipeState {
  final Recipe recipe;
  final List<Recipe> recipes;
  const RecipeDetailLoaded(this.recipe, this.recipes);

  @override
  List<Object?> get props => [recipe, recipes];
}

final class RecipeError extends RecipeState {
  final String message;
  const RecipeError(this.message);

  @override
  List<Object?> get props => [message];
}
