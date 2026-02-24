class CategoryGroupDto {
  final int id;
  final String name;

  CategoryGroupDto({required this.id, required this.name});

  factory CategoryGroupDto.fromJson(Map<String, dynamic> json) {
    return CategoryGroupDto(id: json['id'], name: json['name']);
  }
}
