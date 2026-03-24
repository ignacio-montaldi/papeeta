import 'package:papeeta/core/domain/entities/category.dart';
import 'package:papeeta/core/domain/entities/category_group.dart';
abstract class CategoryRepository {
  Future<List<Category>> getCategories();
  Future<List<CategoryGroup>> getCategoryGroups();
}
