part of 'category_bloc.dart';

sealed class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

final class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

final class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

final class CategoryLoaded extends CategoryState {
  final List<Category> categories;
  final List<CategoryGroup> groups;

  const CategoryLoaded(this.categories, this.groups);

  @override
  List<Object?> get props => [categories, groups];
}

final class CategoryError extends CategoryState {
  final String message;
  const CategoryError(this.message);

  @override
  List<Object?> get props => [message];
}
