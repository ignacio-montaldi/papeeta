import 'package:papeeta/features/recipes/domain/entities/ingredient_unit.dart';

abstract class IngredientRepository {
  Future<List<IngredientUnit>> getUnits();
}
