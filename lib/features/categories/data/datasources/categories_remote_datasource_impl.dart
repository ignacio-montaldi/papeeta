import 'package:dio/dio.dart';
import 'package:papeeta/features/recipes/data/models/category_dto.dart';
import 'categories_remote_datasource.dart';

class CategoriesRemoteDataSourceImpl implements CategoriesRemoteDataSource {
  final Dio dio;

  CategoriesRemoteDataSourceImpl(this.dio);

  @override
  Future<List<CategoryDto>> getCategories() async {
    final res = await dio.get('/categories');

    return (res.data['categories'] as List)
        .map((e) => CategoryDto.fromJson(e))
        .toList();
  }
}
