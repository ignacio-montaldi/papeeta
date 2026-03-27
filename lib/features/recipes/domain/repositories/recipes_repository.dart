import 'package:papeeta/features/recipes/domain/entities/recipe_image_upload.dart';

import '../entities/recipe.dart';

abstract class RecipesRepository {
  Future<List<Recipe>> getRecipes();
  Future<Recipe> getRecipeById(int id);

  Future<int> createRecipe(Recipe recipe);

  Future<void> uploadRecipeImages({
    required int recipeId,
    required List<RecipeImageUpload> images,
  });

  Future<List<Recipe>> getRecipesByCategory(int categoryId);

  Future<List<Recipe>> getHomeRecipeList();
}
