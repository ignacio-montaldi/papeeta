part of 'recipe_bloc.dart';

class RecipeState extends Equatable {
  final List<RecipeModel>? recipes;
  final RecipeModel? selectedRecipe;
  final List<RecipeModel>? recipesByCategory;

  const RecipeState({
    this.recipes,
    this.selectedRecipe,
    this.recipesByCategory,
  });

  RecipeState copyWith({
    List<RecipeModel>? recipes,
    RecipeModel? selectedRecipe,
    List<RecipeModel>? recipesByCategory,
  }) => RecipeState(
    recipes: recipes ?? this.recipes,
    selectedRecipe: selectedRecipe ?? this.selectedRecipe,
    recipesByCategory: recipesByCategory ?? this.recipesByCategory,
  );

  @override
  List<Object?> get props => [recipes, selectedRecipe, recipesByCategory];
}
