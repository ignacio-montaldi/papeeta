import 'package:papeeta/features/recipes/data/models/category_group_dto.dart';

class CategoryDto {
  final int id;
  final String name;
  final String? imageUrl;
  final int? groupId;
  final CategoryGroupDto? group;

  CategoryDto({
    required this.id,
    required this.name,
    this.imageUrl,
    this.groupId,
    this.group,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      groupId: json['group_id'],
      group: json['group'] != null
          ? CategoryGroupDto.fromJson(json['group'])
          : null,
    );
  }
}
