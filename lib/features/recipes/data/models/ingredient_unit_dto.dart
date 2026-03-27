class IngredientUnitDto {
  final int id;
  final String unitKey;
  final String displayName;
  final String type;

  IngredientUnitDto({
    required this.id,
    required this.unitKey,
    required this.displayName,
    required this.type,
  });

  factory IngredientUnitDto.fromJson(Map<String, dynamic> json) {
    return IngredientUnitDto(
      id: json['id'],
      unitKey: json['unit_key'],
      displayName: json['display_name'],
      type: json['type'],
    );
  }
}
