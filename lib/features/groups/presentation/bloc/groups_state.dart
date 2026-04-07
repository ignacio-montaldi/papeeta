import 'package:equatable/equatable.dart';
import 'package:papeeta/core/domain/entities/recipe_share_group.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';

abstract class GroupsState extends Equatable {
  const GroupsState();

  @override
  List<Object?> get props => [];
}

class GroupsInitial extends GroupsState {}

class GroupsLoading extends GroupsState {}

class GroupsLoaded extends GroupsState {
  final List<RecipeShareGroup> groups;

  const GroupsLoaded(this.groups);

  @override
  List<Object?> get props => [groups];
}

class GroupDetailLoaded extends GroupsState {
  final RecipeShareGroup group;

  const GroupDetailLoaded(this.group);

  @override
  List<Object?> get props => [group];
}

class GroupsError extends GroupsState {
  final String message;

  const GroupsError(this.message);

  @override
  List<Object?> get props => [message];
}

class GroupCreated extends GroupsState {
  final RecipeShareGroup group;

  const GroupCreated(this.group);

  @override
  List<Object?> get props => [group];
}

class UserRecipesLoaded extends GroupsState {
  final List<Recipe> recipes;

  const UserRecipesLoaded(this.recipes);

  @override
  List<Object?> get props => [recipes];
}
