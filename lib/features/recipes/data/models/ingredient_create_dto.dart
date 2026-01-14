class IngredientCreateDto {
  final double? amount;
  final int? measureUnitId;
  final String name;

  IngredientCreateDto({
    required this.amount,
    required this.measureUnitId,
    required this.name,
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'measure_unit_id': measureUnitId,
    'name': name,
  };
}
