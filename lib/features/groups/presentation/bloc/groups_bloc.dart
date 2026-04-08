import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/features/groups/data/models/recipe_share_group_dto.dart';
import 'package:papeeta/features/groups/domain/repositories/groups_repository.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_event.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_state.dart';

class GroupsBloc extends Bloc<GroupsEvent, GroupsState> {
  final GroupsRepository repository;

  GroupsBloc({required this.repository}) : super(GroupsInitial()) {
    on<LoadMyGroups>(_onLoadMyGroups);
    on<LoadGroupDetail>(_onLoadGroupDetail);
    on<CreateGroup>(_onCreateGroup);
    on<AddMemberToGroup>(_onAddMember);
    on<RemoveMemberFromGroup>(_onRemoveMember);
    on<ShareRecipeToGroup>(_onShareRecipe);
    on<LoadUserRecipes>(_onLoadUserRecipes);
    on<RecipeShared>(_onRecipeShared);
    on<RemoveRecipeFromGroup>(_onRemoveRecipe);
    on<UpdateGroupImage>(_onUpdateGroupImage);
  }

  Future<void> _onLoadMyGroups(
    LoadMyGroups event,
    Emitter<GroupsState> emit,
  ) async {
    emit(GroupsLoading());
    try {
      final groups = await repository.getMyGroups();
      emit(GroupsLoaded(groups));
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }

  Future<void> _onLoadGroupDetail(
    LoadGroupDetail event,
    Emitter<GroupsState> emit,
  ) async {
    emit(GroupsLoading());
    try {
      final group = await repository.getGroupById(event.groupId);
      emit(GroupDetailLoaded(group));
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }

  Future<void> _onCreateGroup(
    CreateGroup event,
    Emitter<GroupsState> emit,
  ) async {
    emit(GroupsLoading());
    try {
      final dto = CreateRecipeShareGroupDto(
        name: event.name,
        description: event.description,
      );
      final group = await repository.createGroup(dto);
      emit(GroupCreated(group));
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }

  Future<void> _onAddMember(
    AddMemberToGroup event,
    Emitter<GroupsState> emit,
  ) async {
    try {
      await repository.addMember(event.groupId, event.nombreUsuario);
      add(LoadGroupDetail(event.groupId));
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }

  Future<void> _onRemoveMember(
    RemoveMemberFromGroup event,
    Emitter<GroupsState> emit,
  ) async {
    try {
      await repository.removeMember(event.groupId, event.userId);
      add(LoadGroupDetail(event.groupId));
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }

  Future<void> _onShareRecipe(
    ShareRecipeToGroup event,
    Emitter<GroupsState> emit,
  ) async {
    try {
      await repository.shareRecipe(event.groupId, event.recipeId);
      add(LoadGroupDetail(event.groupId));
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }

  Future<void> _onLoadUserRecipes(
    LoadUserRecipes event,
    Emitter<GroupsState> emit,
  ) async {
    try {
      final recipes = await repository.getUserRecipes();
      emit(UserRecipesLoaded(recipes));
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }

  Future<void> _onRecipeShared(
    RecipeShared event,
    Emitter<GroupsState> emit,
  ) async {
    add(LoadGroupDetail(event.groupId));
  }

  Future<void> _onRemoveRecipe(
    RemoveRecipeFromGroup event,
    Emitter<GroupsState> emit,
  ) async {
    try {
      await repository.removeRecipe(event.groupId, event.recipeId);
      add(LoadGroupDetail(event.groupId));
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }

  Future<void> _onUpdateGroupImage(
    UpdateGroupImage event,
    Emitter<GroupsState> emit,
  ) async {
    try {
      final group = await repository.updateGroupImage(event.groupId, event.imagePath);
      emit(GroupDetailLoaded(group));
    } catch (e) {
      emit(GroupsError(e.toString()));
    }
  }
}
