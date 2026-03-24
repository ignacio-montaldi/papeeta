import 'package:papeeta/features/recipes/data/models/category_dto.dart';
import 'package:papeeta/features/recipes/data/models/category_group_dto.dart';

abstract class CategoriesRemoteDataSource {
  Future<List<CategoryDto>> getCategories();
  Future<List<CategoryGroupDto>> getCategoryGroups();
}
