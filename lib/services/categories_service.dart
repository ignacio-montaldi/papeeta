import 'package:dio/dio.dart';

import 'package:papeeta/global/enviroment.dart';
import 'package:papeeta/models/response/response_models.dart';
import 'package:papeeta/services/services.dart';

class CategoriesService {
  final Dio _dio;

  final String _baseCategoriesUrl = '${Enviroment.apiUrl}/categories';

  CategoriesService() : _dio = Dio()..interceptors.add(PapeetaInterceptor());

  Future<CategoriesListResponse> getCategoriesList() async {
    final url = "$_baseCategoriesUrl/";

    final resp = await _dio.get(url);

    final data = CategoriesListResponse.fromJson(resp.data);

    return data;
  }

  Future<CategoryGroupResponse> getCategoriesGroupList() async {
    final url = "$_baseCategoriesUrl/groups/";

    final resp = await _dio.get(url);

    final data = CategoryGroupResponse.fromJson(resp.data);

    return data;
  }

  // Future<RecipeDetailResponse> getRecipeDetail(int recipeId) async {
  //   final url = "$_baseRecipesUrl/$recipeId";

  //   final resp = await _dio.get(url);

  //   final data = RecipeDetailResponse.fromJson(resp.data);

  //   return data;
  // }
}
