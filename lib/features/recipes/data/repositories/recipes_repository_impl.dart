import 'package:papeeta/features/recipes/data/datasources/recipes_remote_datasource.dart';
import 'package:papeeta/features/recipes/data/mappers/recipe_mapper.dart';
import 'package:papeeta/features/recipes/data/models/recipe_image_upload_dto.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe_image_upload.dart';
import 'package:papeeta/features/recipes/domain/repositories/recipes_repository.dart';

class RecipesRepositoryImpl implements RecipesRepository {
  final RecipesRemoteDataSource _dataSource;

  RecipesRepositoryImpl(this._dataSource);

  @override
  Future<List<Recipe>> getRecipes() async {
    final dtos = await _dataSource.getRecipes();
    return dtos.map(RecipeMapper.toEntity).toList();
  }

  @override
  Future<Recipe> getRecipeById(int id) async {
    final dto = await _dataSource.getRecipeById(id);
    return RecipeMapper.toEntity(dto);
  }

  @override
  Future<int> createRecipe(Recipe recipe) async {
    final dto = RecipeMapper.toCreateDto(recipe);
    return _dataSource.createRecipe(dto);
  }

  @override
  Future<void> uploadRecipeImages({
    required int recipeId,
    required List<RecipeImageUpload> images,
  }) async {
    final dtos = images
        .map((img) => RecipeImageUploadDto(file: img.file))
        .toList();
    await _dataSource.uploadImages(recipeId, dtos);
  }

  @override
  Future<List<Recipe>> getRecipesByCategory(int categoryId) async {
    final dtos = await _dataSource.getRecipesByCategory(categoryId);
    return dtos.map(RecipeMapper.toEntity).toList();
  }
}
