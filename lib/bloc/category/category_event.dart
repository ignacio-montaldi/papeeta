part of 'category_bloc.dart';

sealed class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class LoadedHomeCategoryList extends CategoryEvent {
  final List<CategoryModel> categories;

  const LoadedHomeCategoryList({required this.categories});
}

class LoadHomeCategoriesList extends CategoryEvent {
  const LoadHomeCategoriesList();
}

class LoadedCategoryList extends CategoryEvent {
  final List<CategoryModel> categories;

  const LoadedCategoryList({required this.categories});
}

class SelectedCategory extends CategoryEvent {
  final CategoryModel category;

  const SelectedCategory({required this.category});
}

class LoadedGroupList extends CategoryEvent {
  final List<GroupModel> groups;

  const LoadedGroupList({required this.groups});
}

class FilterByGroup extends CategoryEvent {
  final int groupId;

  const FilterByGroup({required this.groupId});
}
