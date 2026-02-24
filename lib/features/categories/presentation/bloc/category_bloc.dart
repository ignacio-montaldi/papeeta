import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/core/domain/entities/category.dart';
import 'package:papeeta/features/categories/domain/repositories/category_repository.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoryRepository repository;

  CategoryBloc(this.repository) : super(const CategoryInitial()) {
    on<LoadCategories>(_onLoadCategories);
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoryState> emit,
  ) async {
    emit(const CategoryLoading());

    try {
      final result = await repository.getCategories();

      emit(CategoryLoaded(result));
    } catch (e, st) {
      debugPrint('❌ Error loading recipes by category: $e');
      debugPrint('$st');

      emit(const CategoryError('Error al cargar categorías'));
    }
  }
}
