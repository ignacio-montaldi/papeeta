class GroupImageDto {
  final int? id;
  final String url;
  final int? position;

  GroupImageDto({this.id, required this.url, this.position});

  factory GroupImageDto.fromJson(Map<String, dynamic> json) {
    return GroupImageDto(
      id: json['id'],
      url: json['url'],
      position: json['position'],
    );
  }
}