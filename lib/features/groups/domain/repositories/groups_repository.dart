import 'package:papeeta/core/domain/entities/recipe_share_group.dart';
import 'package:papeeta/features/groups/data/models/recipe_share_group_dto.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';

abstract class GroupsRepository {
  Future<List<RecipeShareGroup>> getMyGroups();
  Future<RecipeShareGroup> getGroupById(int id);
  Future<RecipeShareGroup> createGroup(CreateRecipeShareGroupDto dto);
  Future<void> addMember(int groupId, String nombreUsuario);
  Future<void> removeMember(int groupId, String userId);
  Future<void> shareRecipe(int groupId, int recipeId);
  Future<List<Recipe>> getUserRecipes();
}
