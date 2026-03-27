import 'package:papeeta/features/ingredients/data/datasources/ingredients_remote_datasource.dart';
import 'package:papeeta/features/ingredients/domain/repositories/ingredient_repository.dart';
import 'package:papeeta/features/recipes/data/mappers/ingredient_unit_mapper.dart';
import 'package:papeeta/features/recipes/domain/entities/ingredient_unit.dart';

class IngredientRepositoryImpl implements IngredientRepository {
  final IngredientsRemoteDataSource remote;

  IngredientRepositoryImpl(this.remote);

  @override
  Future<List<IngredientUnit>> getUnits() async {
    final dtos = await remote.getUnits();
    return dtos.map(IngredientUnitMapper.toEntity).toList();
  }
}
