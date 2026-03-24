import 'package:dio/dio.dart';
import 'package:papeeta/features/recipes/data/models/category_dto.dart';
import 'package:papeeta/features/recipes/data/models/category_group_dto.dart';
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
  @override
  Future<List<CategoryGroupDto>> getCategoryGroups() async {
    final res = await dio.get('/categories/groups/');

    // Looking at the old service it was CategoryGroupResponse.fromJson(resp.data) which had a `.groups` field
    // But this might be a list directly, let's assume it has 'groups' mapped.
    // If it's like categories, it's res.data['groups'] as List.
    return (res.data['groups'] as List)
        .map((e) => CategoryGroupDto.fromJson(e))
        .toList();
  }
}
