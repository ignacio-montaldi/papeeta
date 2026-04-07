import 'package:papeeta/core/domain/entities/recipe_share_group.dart';
import 'package:papeeta/features/groups/data/datasources/groups_remote_datasource.dart';
import 'package:papeeta/features/groups/data/mappers/recipe_share_group_mapper.dart';
import 'package:papeeta/features/groups/data/models/recipe_share_group_dto.dart';
import 'package:papeeta/features/groups/domain/repositories/groups_repository.dart';
import 'package:papeeta/features/recipes/data/mappers/recipe_mapper.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';

class GroupsRepositoryImpl implements GroupsRepository {
  final GroupsRemoteDataSource remoteDataSource;

  GroupsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<RecipeShareGroup>> getMyGroups() async {
    final dtos = await remoteDataSource.getMyGroups();
    return dtos.map((e) => RecipeShareGroupMapper.toEntity(e)).toList();
  }

  @override
  Future<RecipeShareGroup> getGroupById(int id) async {
    final dto = await remoteDataSource.getGroupById(id);
    return RecipeShareGroupMapper.toEntity(dto);
  }

  @override
  Future<RecipeShareGroup> createGroup(CreateRecipeShareGroupDto dto) async {
    final result = await remoteDataSource.createGroup(dto);
    return RecipeShareGroupMapper.toEntity(result);
  }

  @override
  Future<void> addMember(int groupId, String email) async {
    await remoteDataSource.addMember(groupId, email);
  }

  @override
  Future<void> removeMember(int groupId, String userId) async {
    await remoteDataSource.removeMember(groupId, userId);
  }

  @override
  Future<void> shareRecipe(int groupId, int recipeId) async {
    await remoteDataSource.shareRecipe(groupId, recipeId);
  }

  @override
  Future<List<Recipe>> getUserRecipes() async {
    final dtos = await remoteDataSource.getUserRecipes();
    return dtos.map((e) => RecipeMapper.toEntity(e)).toList();
  }
}
