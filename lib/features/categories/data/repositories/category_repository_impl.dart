import 'package:papeeta/core/domain/entities/category.dart';
import 'package:papeeta/core/domain/entities/category_group.dart';
import 'package:papeeta/features/categories/data/datasources/categories_remote_datasource.dart';
import 'package:papeeta/features/categories/domain/repositories/category_repository.dart';
import 'package:papeeta/features/recipes/data/mappers/category_mapper.dart';
import 'package:papeeta/features/recipes/data/mappers/category_group_mapper.dart';

class CategoryRepositoryImpl implements CategoryRepository {
  final CategoriesRemoteDataSource remote;

  CategoryRepositoryImpl(this.remote);

  @override
  Future<List<Category>> getCategories() async {
    final dtos = await remote.getCategories();
    return dtos.map(CategoryMapper.toEntity).toList();
  }

  @override
  Future<List<CategoryGroup>> getCategoryGroups() async {
    final dtos = await remote.getCategoryGroups();
    return dtos.map(CategoryGroupMapper.toEntity).toList();
  }
}
