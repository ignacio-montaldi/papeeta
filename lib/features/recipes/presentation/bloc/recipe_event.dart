part of 'recipe_bloc.dart';

abstract class RecipeEvent {}

class LoadRecipes extends RecipeEvent {}

class LoadRecipeDetail extends RecipeEvent {
  final int id;
  LoadRecipeDetail(this.id);
}

class LoadRecipesByCategory extends RecipeEvent {
  final int categoryId;
  LoadRecipesByCategory(this.categoryId);
}
