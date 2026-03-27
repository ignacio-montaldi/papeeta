part of 'ingredient_bloc.dart';

sealed class IngredientState extends Equatable {
  const IngredientState();
  
  @override
  List<Object> get props => [];
}

final class IngredientInitial extends IngredientState {
  const IngredientInitial();
}

final class IngredientLoading extends IngredientState {
  const IngredientLoading();
}

final class IngredientUnitsLoaded extends IngredientState {
  final List<IngredientUnit> units;

  const IngredientUnitsLoaded(this.units);

  @override
  List<Object> get props => [units];
}

final class IngredientError extends IngredientState {
  final String message;

  const IngredientError(this.message);

  @override
  List<Object> get props => [message];
}
