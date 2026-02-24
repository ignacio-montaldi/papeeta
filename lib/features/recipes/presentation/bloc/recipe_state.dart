part of 'recipe_bloc.dart';

sealed class RecipeState extends Equatable {
  const RecipeState();

  @override
  List<Object?> get props => [];
}

final class RecipeInitial extends RecipeState {
  const RecipeInitial();
}

final class RecipeLoading extends RecipeState {
  const RecipeLoading();
}

final class RecipeListLoaded extends RecipeState {
  final List<Recipe> recipes;
  const RecipeListLoaded(this.recipes);

  @override
  List<Object?> get props => [recipes];
}

final class RecipeDetailLoaded extends RecipeState {
  final Recipe recipe;

  const RecipeDetailLoaded(this.recipe);

  @override
  List<Object?> get props => [recipe];
}

final class RecipeError extends RecipeState {
  final String message;
  const RecipeError(this.message);

  @override
  List<Object?> get props => [message];
}
