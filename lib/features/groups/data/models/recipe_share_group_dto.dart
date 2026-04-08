import 'package:papeeta/features/auth/data/models/user_dto.dart';
import 'package:papeeta/features/groups/data/models/group_image_dto.dart';
import 'package:papeeta/features/recipes/data/models/recipe_response_dto.dart';

class RecipeShareGroupDto {
  final int? id;
  final String name;
  final String? description;
  final UserDto? owner;
  final List<UserDto> members;
  final List<RecipeResponseDto> recipes;
  final List<GroupImageDto> images;
  final String? createdAt;

  RecipeShareGroupDto({
    this.id,
    required this.name,
    this.description,
    this.owner,
    required this.members,
    required this.recipes,
    this.images = const [],
    this.createdAt,
  });

  factory RecipeShareGroupDto.fromJson(Map<String, dynamic> json) {
    return RecipeShareGroupDto(
      id: json['id'],
      name: json['name'] ?? '',
      description: json['description'],
      owner: json['owner'] != null ? UserDto.fromJson(json['owner']) : null,
      members:
          (json['members'] as List?)
              ?.map((e) => UserDto.fromJson(e))
              .toList() ??
          [],
      recipes:
          (json['recipes'] as List?)
              ?.map((e) => RecipeResponseDto.fromJson(e))
              .toList() ??
          [],
      images: (json['images'] as List?)
              ?.map((e) => GroupImageDto.fromJson(e))
              .toList() ??
          [],
      createdAt: json['created_at'],
    );
  }
}

class CreateRecipeShareGroupDto {
  final String name;
  final String? description;

  CreateRecipeShareGroupDto({
    required this.name,
    this.description,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'description': description};
  }
}
