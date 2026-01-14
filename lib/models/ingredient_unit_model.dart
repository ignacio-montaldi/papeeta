class IngredientUnitModel {
  final int? id;
  final String unitKey;
  final String displayName;
  final String type;

  IngredientUnitModel({
    required this.id,
    required this.unitKey,
    required this.displayName,
    required this.type,
  });

  factory IngredientUnitModel.fromJson(Map<String, dynamic> json) {
    return IngredientUnitModel(
      id: json['id'],
      unitKey: json['unit_key'],
      displayName: json['display_name'],
      type: json['type'],
    );
  }
}
