import 'dart:convert';

import 'package:papeeta/models/response/category_group_response_model.dart';

class CategoriesListResponse {
  final bool ok;
  final List<Category> categories;

  CategoriesListResponse({required this.ok, required this.categories});

  factory CategoriesListResponse.fromRawJson(String str) =>
      CategoriesListResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory CategoriesListResponse.fromJson(Map<String, dynamic> json) =>
      CategoriesListResponse(
        ok: json["ok"],
        categories: List<Category>.from(
          json["categories"].map((x) => Category.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "ok": ok,
    "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
  };
}

class Category {
  final int id;
  final String name;
  final String? imageUrl;
  final int groupId;
  final Group group;

  Category({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.groupId,
    required this.group,
  });

  factory Category.fromRawJson(String str) =>
      Category.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    name: json["name"],
    imageUrl: json["image_url"],
    groupId: json["group_id"],
    group: Group.fromJson(json["group"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image_url": imageUrl,
    "group_id": groupId,
    "group": group.toJson(),
  };
}
