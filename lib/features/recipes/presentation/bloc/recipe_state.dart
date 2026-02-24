part of 'recipe_bloc.dart';

sealed class RecipeState extends Equatable {
  const RecipeState();

  List<Recipe>? get currentRecipes {
    if (this is RecipeListLoaded) return (this as RecipeListLoaded).recipes;
    if (this is RecipeDetailLoaded) return (this as RecipeDetailLoaded).recipes;
    if (this is RecipeLoading) return (this as RecipeLoading).recipes;
    if (this is RecipeError) return (this as RecipeError).recipes;
    return null;
  }

  @override
  List<Object?> get props => [];
}

final class RecipeInitial extends RecipeState {
  const RecipeInitial();
}

final class RecipeLoading extends RecipeState {
  final List<Recipe>? recipes;
  const RecipeLoading({this.recipes});

  @override
  List<Object?> get props => [recipes];
}

final class RecipeListLoaded extends RecipeState {
  final List<Recipe> recipes;
  final Recipe? selectedRecipe;
  const RecipeListLoaded(this.recipes, {this.selectedRecipe});

  @override
  List<Object?> get props => [recipes, selectedRecipe];
}

final class RecipeDetailLoaded extends RecipeState {
  final Recipe recipe;
  final List<Recipe>? recipes;

  const RecipeDetailLoaded(this.recipe, {this.recipes});

  @override
  List<Object?> get props => [recipe, recipes];
}

final class RecipeError extends RecipeState {
  final String message;
  final List<Recipe>? recipes;
  const RecipeError(this.message, {this.recipes});

  @override
  List<Object?> get props => [message, recipes];
}
