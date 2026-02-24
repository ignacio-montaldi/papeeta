import 'package:papeeta/core/domain/entities/category.dart';

abstract class CategoryRepository {
  Future<List<Category>> getCategories();
}
