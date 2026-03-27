import 'package:papeeta/features/recipes/domain/entities/ingredient_unit.dart';

class Ingredient {
  final double? amount;
  final IngredientUnit? unit;
  final String name;

  const Ingredient({
    required this.amount,
    required this.unit,
    required this.name,
  });
}
