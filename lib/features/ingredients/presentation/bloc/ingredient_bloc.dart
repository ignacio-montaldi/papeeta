import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/features/ingredients/domain/repositories/ingredient_repository.dart';
import 'package:papeeta/features/recipes/domain/entities/ingredient_unit.dart';

part 'ingredient_event.dart';
part 'ingredient_state.dart';

class IngredientBloc extends Bloc<IngredientEvent, IngredientState> {
  final IngredientRepository repository;

  IngredientBloc({required this.repository}) : super(const IngredientInitial()) {
    on<LoadUnitsEvent>(_onLoadUnits);
  }

  Future<void> _onLoadUnits(
    LoadUnitsEvent event,
    Emitter<IngredientState> emit,
  ) async {
    emit(const IngredientLoading());

    try {
      final units = await repository.getUnits();
      emit(IngredientUnitsLoaded(units));
    } catch (e) {
      emit(IngredientError(e.toString()));
    }
  }
}
