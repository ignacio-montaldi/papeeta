part of 'ingredient_bloc.dart';

sealed class IngredientState {
  const IngredientState();
}

class IngredientInitial extends IngredientState {}

class IngredientLoading extends IngredientState {}

class IngredientUnitsLoaded extends IngredientState {
  final List<IngredientUnit> units;
  const IngredientUnitsLoaded(this.units);
}

class IngredientError extends IngredientState {
  final String message;
  const IngredientError(this.message);
}
