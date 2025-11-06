part of 'category_bloc.dart';

class CategoryState extends Equatable {
  final List<CategoryModel>? categories;
  final CategoryModel? selectedCategory;
  final List<GroupModel>? groups;
  final int? groupId;

  const CategoryState({
    this.categories,
    this.selectedCategory,
    this.groups,
    this.groupId,
  });

  CategoryState copyWith({
    List<CategoryModel>? categories,
    CategoryModel? selectedCategory,
    List<GroupModel>? groups,
    int? groupId,
  }) => CategoryState(
    categories: categories ?? this.categories,
    selectedCategory: selectedCategory ?? this.selectedCategory,
    groups: groups ?? this.groups,
    groupId: groupId ?? this.groupId,
  );

  @override
  List<Object?> get props => [categories, selectedCategory, groups, groupId];
}
