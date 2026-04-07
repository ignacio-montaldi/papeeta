import 'package:dio/dio.dart';
import 'package:papeeta/features/groups/data/models/recipe_share_group_dto.dart';
import 'package:papeeta/features/recipes/data/models/recipe_response_dto.dart';

abstract class GroupsRemoteDataSource {
  Future<List<RecipeShareGroupDto>> getMyGroups();
  Future<RecipeShareGroupDto> getGroupById(int id);
  Future<RecipeShareGroupDto> createGroup(CreateRecipeShareGroupDto dto);
  Future<void> addMember(int groupId, String email);
  Future<void> removeMember(int groupId, String userId);
  Future<void> shareRecipe(int groupId, int recipeId);
  Future<List<RecipeResponseDto>> getUserRecipes();
}

class GroupsRemoteDataSourceImpl implements GroupsRemoteDataSource {
  final Dio dio;

  GroupsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<RecipeShareGroupDto>> getMyGroups() async {
    final res = await dio.get('/groups/');
    return (res.data['groups'] as List)
        .map((e) => RecipeShareGroupDto.fromJson(e))
        .toList();
  }

  @override
  Future<RecipeShareGroupDto> getGroupById(int id) async {
    final res = await dio.get('/groups/$id/');
    return RecipeShareGroupDto.fromJson(res.data['group']);
  }

  @override
  Future<RecipeShareGroupDto> createGroup(CreateRecipeShareGroupDto dto) async {
    final res = await dio.post('/groups/', data: dto.toJson());
    return RecipeShareGroupDto.fromJson(res.data['group']);
  }

  @override
  Future<void> addMember(int groupId, String email) async {
    await dio.post('/groups/$groupId/members/', data: {'email': email});
  }

  @override
  Future<void> removeMember(int groupId, String userId) async {
    await dio.delete('/groups/$groupId/members/$userId/');
  }

  @override
  Future<void> shareRecipe(int groupId, int recipeId) async {
    await dio.post('/groups/$groupId/recipes/', data: {'recipe_id': recipeId});
  }

  @override
  Future<List<RecipeResponseDto>> getUserRecipes() async {
    final res = await dio.get('/recipes/my-recipes/');
    return (res.data['recipes'] as List)
        .map((e) => RecipeResponseDto.fromJson(e))
        .toList();
  }
}
