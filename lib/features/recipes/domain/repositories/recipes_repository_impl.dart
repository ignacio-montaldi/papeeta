import 'package:papeeta/features/recipes/data/datasources/recipes_remote_datasource.dart';
import 'package:papeeta/features/recipes/data/mappers/recipe_image_mapper.dart';
import 'package:papeeta/features/recipes/data/mappers/recipe_mapper.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe_image_upload.dart';
import 'package:papeeta/features/recipes/domain/repositories/recipes_repository.dart';

class RecipesRepositoryImpl implements RecipesRepository {
  final RecipesRemoteDataSource remote;

  RecipesRepositoryImpl(this.remote);

  @override
  Future<List<Recipe>> getRecipes() async {
    final dtos = await remote.getRecipes();
    return dtos.map(RecipeMapper.toEntity).toList();
  }

  @override
  Future<Recipe> getRecipeById(int id) async {
    final dto = await remote.getRecipeById(id);
    return RecipeMapper.toEntity(dto);
  }

  @override
  Future<int> createRecipe(Recipe recipe) async {
    final requestDto = RecipeMapper.toCreateDto(recipe);
    return await remote.createRecipe(requestDto);
  }

  @override
  Future<void> uploadRecipeImages({
    required int recipeId,
    required List<RecipeImageUpload> images,
  }) async {
    final dtos = images.map(RecipeImageMapper.toUploadDto).toList();
    await remote.uploadImages(recipeId, dtos);
  }
}
