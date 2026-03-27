import 'package:papeeta/features/recipes/data/models/recipe_create_dto.dart';
import 'package:papeeta/features/recipes/data/models/recipe_image_upload_dto.dart';
import 'package:papeeta/features/recipes/data/models/recipe_response_dto.dart';

abstract class RecipesRemoteDataSource {
  Future<List<RecipeResponseDto>> getRecipes();

  Future<RecipeResponseDto> getRecipeById(int id);

  Future<int> createRecipe(RecipeCreateDto dto);

  Future<void> uploadImages(int recipeId, List<RecipeImageUploadDto> images);

  Future<List<RecipeResponseDto>> getRecipesByCategory(int categoryId);

  Future<List<RecipeResponseDto>> getHomeRecipeList();
}
