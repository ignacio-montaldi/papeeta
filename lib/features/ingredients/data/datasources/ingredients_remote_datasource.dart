import 'package:papeeta/features/recipes/data/models/ingredient_unit_dto.dart';

abstract class IngredientsRemoteDataSource {
  Future<List<IngredientUnitDto>> getUnits();
}
