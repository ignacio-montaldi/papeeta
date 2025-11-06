part of 'recipe_bloc.dart';

sealed class RecipeEvent extends Equatable {
  const RecipeEvent();

  @override
  List<Object> get props => [];
}

class LoadedRecipeList extends RecipeEvent {
  final List<RecipeModel> recipes;

  const LoadedRecipeList({required this.recipes});
}

class SelectedRecipe extends RecipeEvent {
  final RecipeModel recipe;

  const SelectedRecipe({required this.recipe});
}

class SelectedRecipeDetailLoaded extends RecipeEvent {
  final RecipeModel recipe;

  const SelectedRecipeDetailLoaded({required this.recipe});
}

class LoadedRecipesByCategory extends RecipeEvent {
  final List<RecipeModel> recipes;

  const LoadedRecipesByCategory({required this.recipes});
}

class LoadedRecipeByCategoryList extends RecipeEvent {
  final List<RecipeModel> recipesByCategory;

  const LoadedRecipeByCategoryList({required this.recipesByCategory});
}
