import 'package:dio/dio.dart';
import 'package:papeeta/features/ingredients/data/datasources/ingredients_remote_datasource.dart';
import 'package:papeeta/features/recipes/data/models/ingredient_unit_dto.dart';

class IngredientsRemoteDataSourceImpl implements IngredientsRemoteDataSource {
  final Dio dio;

  IngredientsRemoteDataSourceImpl(this.dio);

  @override
  Future<List<IngredientUnitDto>> getUnits() async {
    final res = await dio.get('/ingredients/units');

    return (res.data['units'] as List)
        .map((e) => IngredientUnitDto.fromJson(e))
        .toList();
  }
}
