class RecipeImageDto {
  final int id;
  final String url;

  RecipeImageDto({required this.id, required this.url});

  factory RecipeImageDto.fromJson(Map<String, dynamic> json) {
    return RecipeImageDto(id: json['id'], url: json['url']);
  }
}
