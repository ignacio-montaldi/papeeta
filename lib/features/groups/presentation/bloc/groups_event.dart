import 'package:equatable/equatable.dart';

abstract class GroupsEvent extends Equatable {
  const GroupsEvent();

  @override
  List<Object?> get props => [];
}

class LoadMyGroups extends GroupsEvent {}

class LoadGroupDetail extends GroupsEvent {
  final int groupId;

  const LoadGroupDetail(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class CreateGroup extends GroupsEvent {
  final String name;
  final String? description;
  final String? imageUrl;

  const CreateGroup({required this.name, this.description, this.imageUrl});

  @override
  List<Object?> get props => [name, description, imageUrl];
}

class AddMemberToGroup extends GroupsEvent {
  final int groupId;
  final String nombreUsuario;

  const AddMemberToGroup({required this.groupId, required this.nombreUsuario});

  @override
  List<Object?> get props => [groupId, nombreUsuario];
}

class RemoveMemberFromGroup extends GroupsEvent {
  final int groupId;
  final String userId;

  const RemoveMemberFromGroup({required this.groupId, required this.userId});

  @override
  List<Object?> get props => [groupId, userId];
}

class ShareRecipeToGroup extends GroupsEvent {
  final int groupId;
  final int recipeId;

  const ShareRecipeToGroup({required this.groupId, required this.recipeId});

  @override
  List<Object?> get props => [groupId, recipeId];
}

class LoadUserRecipes extends GroupsEvent {}

class RecipeShared extends GroupsEvent {
  final int groupId;

  const RecipeShared(this.groupId);

  @override
  List<Object?> get props => [groupId];
}

class RemoveRecipeFromGroup extends GroupsEvent {
  final int groupId;
  final int recipeId;

  const RemoveRecipeFromGroup({required this.groupId, required this.recipeId});

  @override
  List<Object?> get props => [groupId, recipeId];
}
