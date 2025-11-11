part of 'recipe_bloc.dart';

class RecipeState extends Equatable {
  final List<RecipeModel>? recipes;
  final RecipeModel? selectedRecipe;
  final List<RecipeModel>? recipesByCategory;
  final bool isLoading;

  const RecipeState({
    this.recipes,
    this.selectedRecipe,
    this.recipesByCategory,
    this.isLoading = false,
  });

  RecipeState copyWith({
    List<RecipeModel>? recipes,
    RecipeModel? selectedRecipe,
    List<RecipeModel>? recipesByCategory,
    bool? isLoading,
  }) => RecipeState(
    recipes: recipes ?? this.recipes,
    selectedRecipe: selectedRecipe ?? this.selectedRecipe,
    recipesByCategory: recipesByCategory ?? this.recipesByCategory,
    isLoading: isLoading ?? this.isLoading,
  );

  @override
  List<Object?> get props => [
    recipes,
    selectedRecipe,
    recipesByCategory,
    isLoading,
  ];
}
