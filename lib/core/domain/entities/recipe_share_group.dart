import 'package:papeeta/features/auth/domain/entities/user.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';
import 'package:papeeta/features/groups/domain/entities/group_image.dart';

class RecipeShareGroup {
  final int? id;
  final String name;
  final String? description;
  final User? owner;
  final List<User> members;
  final List<Recipe> recipes;
  final List<GroupImage> images;
  final DateTime? createdAt;

  const RecipeShareGroup({
    this.id,
    required this.name,
    this.description,
    this.owner,
    required this.members,
    required this.recipes,
    this.images = const [],
    this.createdAt,
  });
}
