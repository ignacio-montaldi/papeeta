import 'package:papeeta/features/recipes/data/models/category_group_dto.dart';

class CategoryDto {
  final int id;
  final String name;
  final String? imageUrl;
  final CategoryGroupDto? group;

  CategoryDto({
    required this.id,
    required this.name,
    this.imageUrl,
    this.group,
  });

  factory CategoryDto.fromJson(Map<String, dynamic> json) {
    return CategoryDto(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'],
      group: json['group'] != null
          ? CategoryGroupDto.fromJson(json['group'])
          : null,
    );
  }
}
