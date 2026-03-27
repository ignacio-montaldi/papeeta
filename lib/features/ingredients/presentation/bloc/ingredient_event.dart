part of 'ingredient_bloc.dart';

sealed class IngredientEvent extends Equatable {
  const IngredientEvent();

  @override
  List<Object> get props => [];
}

final class LoadUnitsEvent extends IngredientEvent {
  const LoadUnitsEvent();
}
