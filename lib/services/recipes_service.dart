import 'package:dio/dio.dart';

import 'package:papeeta/global/enviroment.dart';
import 'package:papeeta/models/models.dart';
import 'package:papeeta/models/response/response_models.dart';
import 'package:papeeta/services/services.dart';

class RecipesService {
  final Dio _dio;

  final String _baseRecipesUrl = '${Enviroment.apiUrl}/recipes';

  RecipesService() : _dio = Dio()..interceptors.add(PapeetaInterceptor());

  Future<RecipeListResponse> getHomeRecipeList() async {
    final url = "$_baseRecipesUrl/random";

    final resp = await _dio.get(url, queryParameters: {'limit': 20, 'page': 1});

    final data = RecipeListResponse.fromJson(resp.data);

    return data;
  }

  Future<RecipeDetailResponse> getRecipeDetail(int recipeId) async {
    final url = "$_baseRecipesUrl/$recipeId";

    final resp = await _dio.get(url);

    final data = RecipeDetailResponse.fromJson(resp.data);

    return data;
  }

  Future<RecipeListResponse> getRecipesByCategory(int categoryId) async {
    final url = "$_baseRecipesUrl/category/$categoryId";

    final resp = await _dio.get(url);

    final data = RecipeListResponse.fromJson(resp.data);

    return data;
  }

  Future<int> createRecipe(Map<String, dynamic> body) async {
    final url = _baseRecipesUrl;
    final response = await _dio.post(url, data: body);

    return response.data['recipeId'] as int;
  }

  Future<void> uploadRecipeImages({
    required int recipeId,
    required List<MyImageModel> images,
  }) async {
    final url = "$_baseRecipesUrl/$recipeId/images";

    final formData = FormData();

    for (int i = 0; i < images.length; i++) {
      final image = images[i];

      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(
            image.file!.path,
            filename: (i + 1).toString(), //image.file!.path.split('/').last,
          ),
        ),
      );
    }

    await _dio.post(url, data: formData);
  }
}
