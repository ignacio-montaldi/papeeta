part of 'recipe_bloc.dart';

sealed class RecipeEvent extends Equatable {
  const RecipeEvent();

  @override
  List<Object?> get props => [];
}

final class LoadRecipeDetail extends RecipeEvent {
  final int id;
  const LoadRecipeDetail(this.id);

  @override
  List<Object?> get props => [id];
}

final class LoadRecipesByCategory extends RecipeEvent {
  final int categoryId;
  const LoadRecipesByCategory(this.categoryId);

  @override
  List<Object?> get props => [categoryId];
}

final class SelectRecipe extends RecipeEvent {
  final Recipe recipe;
  const SelectRecipe(this.recipe);

  @override
  List<Object?> get props => [recipe.id];
}

final class RestoreHomeRecipes extends RecipeEvent {
  const RestoreHomeRecipes();
}

final class LoadHomeRecipes extends RecipeEvent {
  const LoadHomeRecipes();
}
