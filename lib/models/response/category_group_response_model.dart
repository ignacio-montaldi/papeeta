import 'dart:convert';

class CategoryGroupResponse {
  final bool? ok;
  final List<Group> groups;

  CategoryGroupResponse({this.ok, required this.groups});

  factory CategoryGroupResponse.fromRawJson(String str) =>
      CategoryGroupResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CategoryGroupResponse.fromJson(Map<String, dynamic> json) =>
      CategoryGroupResponse(
        ok: json["ok"],
        groups: json["groups"] == null
            ? []
            : List<Group>.from(json["groups"]!.map((x) => Group.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "ok": ok,
    "groups": List<dynamic>.from(groups.map((x) => x.toJson())),
  };
}

class Group {
  final int id;
  final String name;
  final String imageUrl;

  Group({required this.id, required this.name, required this.imageUrl});

  factory Group.fromRawJson(String str) => Group.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Group.fromJson(Map<String, dynamic> json) =>
      Group(id: json["id"], name: json["name"], imageUrl: json["image_url"]);

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image_url": imageUrl,
  };
}
