part of 'category_bloc.dart';

class CategoryState extends Equatable {
  final List<CategoryModel>? categories;
  final CategoryModel? selectedCategory;
  final List<GroupModel>? groups;
  final int? groupId;
  final bool isLoading;

  const CategoryState({
    this.categories,
    this.selectedCategory,
    this.groups,
    this.groupId,
    this.isLoading = false,
  });

  CategoryState copyWith({
    List<CategoryModel>? categories,
    CategoryModel? selectedCategory,
    List<GroupModel>? groups,
    int? groupId,
    bool? isLoading,
  }) => CategoryState(
    categories: categories ?? this.categories,
    selectedCategory: selectedCategory ?? this.selectedCategory,
    groups: groups ?? this.groups,
    groupId: groupId ?? this.groupId,
    isLoading: isLoading ?? this.isLoading,
  );

  @override
  List<Object?> get props => [
    categories,
    selectedCategory,
    groups,
    groupId,
    isLoading,
  ];
}
