import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:papeeta/global/enviroment.dart';

import 'package:papeeta/models/models.dart';
import 'package:papeeta/models/response/response_models.dart';
import 'package:papeeta/services/categories_service.dart';

part 'category_event.dart';
part 'category_state.dart';

class CategoryBloc extends Bloc<CategoryEvent, CategoryState> {
  final CategoriesService _categoriesService;

  CategoryBloc({required CategoriesService categoriesService})
    : _categoriesService = categoriesService,
      super(CategoryState(categories: null)) {
    on<LoadedHomeCategoryList>(
      (event, emit) => emit(state.copyWith(categories: event.categories)),
    );

    on<LoadedCategoryList>(
      (event, emit) => emit(state.copyWith(categories: event.categories)),
    );

    on<SelectedCategory>(
      (event, emit) => emit(state.copyWith(selectedCategory: event.category)),
    );

    on<LoadedGroupList>(
      (event, emit) => emit(state.copyWith(groups: event.groups)),
    );

    on<FilterByGroup>(
      (event, emit) => emit(state.copyWith(groupId: event.groupId)),
    );

    on<LoadHomeCategoriesList>((event, emit) async {
      final categoriesListResponse = await _categoriesService
          .getCategoriesList();

      final List<CategoryModel> categories = categoriesListResponse.categories
          .map(
            (Category category) => CategoryModel(
              id: category.id,
              name: category.name,
              imageUrl: '${Enviroment.uploadsUrl}${category.imageUrl}',
              groupId: category.groupId,
              group: GroupModel(
                id: category.group.id,
                name: category.group.name,
                imageUrl: category.group.imageUrl,
              ),
            ),
          )
          .toList();

      emit(state.copyWith(categories: categories, isLoading: false));
    });
  }

  Future<void> getCategoriesList() async {
    final categoriesListResponse = await _categoriesService.getCategoriesList();

    final List<CategoryModel> categories = categoriesListResponse.categories
        .map(
          (Category category) => CategoryModel(
            id: category.id,
            name: category.name,
            imageUrl: '${Enviroment.uploadsUrl}${category.imageUrl}',
            groupId: category.groupId,
            group: GroupModel(
              id: category.group.id,
              name: category.group.name,
              imageUrl: category.group.imageUrl,
            ),
          ),
        )
        .toList();

    add(LoadedCategoryList(categories: categories));
  }

  Future<void> getCategoriesGroupList() async {
    final groupsListResponse = await _categoriesService
        .getCategoriesGroupList();

    final List<GroupModel> groups = groupsListResponse.groups
        .map(
          (Group groups) => GroupModel(
            id: groups.id,
            name: groups.name,
            imageUrl: '${Enviroment.uploadsUrl}${groups.imageUrl}',
          ),
        )
        .toList();

    add(LoadedGroupList(groups: groups));
  }
}
