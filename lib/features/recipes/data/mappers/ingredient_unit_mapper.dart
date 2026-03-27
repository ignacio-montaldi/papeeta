import 'package:papeeta/features/recipes/data/models/ingredient_unit_dto.dart';
import 'package:papeeta/features/recipes/domain/entities/ingredient_unit.dart';

class IngredientUnitMapper {
  static IngredientUnit toEntity(IngredientUnitDto dto) {
    return IngredientUnit(
      id: dto.id,
      key: dto.unitKey,
      name: dto.displayName,
      type: dto.type,
    );
  }

  /// Para requests (POST / PUT)
  /// El backend espera measure_unit_id
  static int toId(IngredientUnit unit) {
    return unit.id;
  }
}
