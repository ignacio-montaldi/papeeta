import 'package:papeeta/features/recipes/data/models/category_dto.dart';

abstract class CategoriesRemoteDataSource {
  Future<List<CategoryDto>> getCategories();
}
