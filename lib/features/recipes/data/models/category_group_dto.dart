class CategoryGroupDto {
  final int id;
  final String name;
  final String? imageUrl;

  CategoryGroupDto({required this.id, required this.name, this.imageUrl});

  factory CategoryGroupDto.fromJson(Map<String, dynamic> json) {
    return CategoryGroupDto(
      id: json['id'],
      name: json['name'],
      imageUrl: json['image_url'] ?? json['image'],
    );
  }
}
