import 'package:papeeta/models/models.dart';

class IngredientModel {
  int? tempId; // ID SOLO para Flutter
  double? amount;
  IngredientUnitModel? measure;
  String name;

  IngredientModel({
    this.tempId,
    required this.amount,
    required this.measure,
    required this.name,
  });
}
