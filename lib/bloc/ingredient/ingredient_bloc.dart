import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:papeeta/features/recipes/domain/entities/ingredient_unit.dart';
import 'package:papeeta/services/services.dart';

part 'ingredient_event.dart';
part 'ingredient_state.dart';

class IngredientBloc extends Bloc<IngredientEvent, IngredientState> {
  final IngredientService _ingredientService;
  IngredientBloc({required IngredientService ingredientService})
    : _ingredientService = ingredientService,
      super(IngredientInitial()) {
    on<LoadUnitsEvent>(_onLoadUnits);
  }
  Future<void> _onLoadUnits(
    LoadUnitsEvent event,
    Emitter<IngredientState> emit,
  ) async {
    emit(IngredientLoading());

    try {
      final units = (await _ingredientService.getUnits()).units
          .map(
            (unit) => IngredientUnit(
              id: unit.id,
              name: unit.displayName,
              type: unit.type,
              key: unit.unitKey,
            ),
          )
          .toList();

      emit(IngredientUnitsLoaded(units));
    } catch (e) {
      emit(IngredientError(e.toString()));
    }
  }
}
