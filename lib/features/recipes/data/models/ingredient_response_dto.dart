import 'package:papeeta/features/recipes/data/models/ingredient_unit_dto.dart';

class IngredientResponseDto {
  final int id;
  final double? amount;
  final String name;
  final int position;
  final int? measureUnitId;
  final IngredientUnitDto? measureUnit;

  IngredientResponseDto({
    required this.id,
    required this.amount,
    required this.name,
    required this.position,
    required this.measureUnitId,
    required this.measureUnit,
  });

  factory IngredientResponseDto.fromJson(Map<String, dynamic> json) {
    return IngredientResponseDto(
      id: json['id'],
      amount: (json['amount'] as num?)?.toDouble(),
      name: json['name'],
      position: json['position'],
      measureUnitId: json['measure_unit_id'],
      measureUnit: json['measureUnit'] != null
          ? IngredientUnitDto.fromJson(json['measureUnit'])
          : null,
    );
  }
}
