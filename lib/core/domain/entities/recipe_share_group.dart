import 'package:papeeta/features/auth/domain/entities/user.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';

class RecipeShareGroup {
  final int? id;
  final String name;
  final String? description;
  final String? imageUrl;
  final User? owner;
  final List<User> members;
  final List<Recipe> recipes;
  final DateTime? createdAt;

  const RecipeShareGroup({
    this.id,
    required this.name,
    this.description,
    this.imageUrl,
    this.owner,
    required this.members,
    required this.recipes,
    this.createdAt,
  });
}
