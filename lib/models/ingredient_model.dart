class IngredientModel {
  int? tempId; // ID SOLO para Flutter
  double? ammount;
  String? measure;
  String name;

  IngredientModel({
    this.tempId,
    required this.ammount,
    required this.measure,
    required this.name,
  });
}
