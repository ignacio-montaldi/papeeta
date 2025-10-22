part of 'recipe_bloc.dart';

class RecipeState extends Equatable {
  final List<RecipeModel> recipes;

  const RecipeState({required this.recipes});

  RecipeState copyWith({List<RecipeModel>? recipes}) =>
      RecipeState(recipes: recipes ?? this.recipes);

  @override
  List<Object?> get props => [recipes];
}
