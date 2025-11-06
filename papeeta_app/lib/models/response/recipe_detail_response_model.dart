import 'dart:convert';

import 'package:papeeta/models/response/response_models.dart';

class RecipeDetailResponse {
  final bool ok;
  final Recipe recipe;

  RecipeDetailResponse({required this.ok, required this.recipe});

  factory RecipeDetailResponse.fromRawJson(String str) =>
      RecipeDetailResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RecipeDetailResponse.fromJson(Map<String, dynamic> json) =>
      RecipeDetailResponse(
        ok: json["ok"],
        recipe: Recipe.fromJson(json["recipe"]),
      );

  Map<String, dynamic> toJson() => {"ok": ok, "recipe": recipe.toJson()};
}
