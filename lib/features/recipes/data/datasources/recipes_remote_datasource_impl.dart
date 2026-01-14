import 'package:dio/dio.dart';
import 'package:papeeta/features/recipes/data/datasources/recipes_remote_datasource.dart';
import 'package:papeeta/features/recipes/data/models/recipe_create_dto.dart';
import 'package:papeeta/features/recipes/data/models/recipe_image_upload_dto.dart';
import 'package:papeeta/features/recipes/data/models/recipe_response_dto.dart';

class RecipesRemoteDataSourceImpl implements RecipesRemoteDataSource {
  final Dio dio;

  RecipesRemoteDataSourceImpl(this.dio);

  @override
  Future<List<RecipeResponseDto>> getRecipes() async {
    final res = await dio.get('/api/recipes');
    return (res.data as List)
        .map((e) => RecipeResponseDto.fromJson(e))
        .toList();
  }

  @override
  Future<int> createRecipe(RecipeCreateDto dto) async {
    final res = await dio.post('/api/recipes', data: dto.toJson());
    return res.data['id'];
  }

  @override
  Future<void> uploadImages(
    int recipeId,
    List<RecipeImageUploadDto> images,
  ) async {
    final formData = FormData();

    for (final img in images) {
      formData.files.add(
        MapEntry('images', await MultipartFile.fromFile(img.file.path)),
      );
    }

    await dio.post('/api/recipes/$recipeId/images', data: formData);
  }

  @override
  Future<RecipeResponseDto> getRecipeById(int id) async {
    final res = await dio.get('/api/recipes/$id');

    return RecipeResponseDto.fromJson(res.data);
  }
}
