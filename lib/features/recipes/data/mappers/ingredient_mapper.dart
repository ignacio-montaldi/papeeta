import 'package:papeeta/features/recipes/data/mappers/ingredient_unit_mapper.dart';
import 'package:papeeta/features/recipes/data/models/ingredient_create_dto.dart';
import 'package:papeeta/features/recipes/data/models/ingredient_response_dto.dart';
import 'package:papeeta/features/recipes/domain/entities/ingredient.dart';

class IngredientMapper {
  /// API → DOMAIN
  static Ingredient fromResponseDto(IngredientResponseDto dto) {
    return Ingredient(
      amount: dto.amount,
      unit: dto.measureUnit != null
          ? IngredientUnitMapper.toEntity(dto.measureUnit!)
          : null,
      name: dto.name,
    );
  }

  /// DOMAIN → API (POST)
  static IngredientCreateDto toCreateDto(Ingredient entity) {
    return IngredientCreateDto(
      amount: entity.amount,
      measureUnitId: entity.unit?.id,
      name: entity.name,
    );
  }
}
