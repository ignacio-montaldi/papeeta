import 'dart:convert';

class RecipeListResponse {
  final bool ok;
  final List<Recipe> recipe;

  RecipeListResponse({required this.ok, required this.recipe});

  factory RecipeListResponse.fromRawJson(String str) =>
      RecipeListResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RecipeListResponse.fromJson(Map<String, dynamic> json) =>
      RecipeListResponse(
        ok: json["ok"],
        recipe: List<Recipe>.from(
          json["recipes"].map((x) => Recipe.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "ok": ok,
    "recipes": List<dynamic>.from(recipe.map((x) => x.toJson())),
  };
}

class Recipe {
  final int id;
  final String title;
  final String subtitle;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Image> images;
  final List<Ingredient>? ingredients;
  final List<PreparationStep>? preparationSteps;
  final List<RecipeCategory> categories;
  final String? link;
  final Author? author;

  Recipe({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.createdAt,
    required this.updatedAt,
    required this.images,
    this.ingredients,
    this.preparationSteps,
    required this.categories,
    this.link,
    required this.author,
  });

  factory Recipe.fromRawJson(String str) => Recipe.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    id: json["id"],
    title: json["title"],
    subtitle: json["subtitle"],
    createdAt: DateTime.parse(json["createdAt"]),
    updatedAt: DateTime.parse(json["updatedAt"]),
    images: List<Image>.from(json["images"].map((x) => Image.fromJson(x))),
    ingredients: json["ingredients"] == null
        ? []
        : List<Ingredient>.from(
            json["ingredients"]!.map((x) => Ingredient.fromJson(x)),
          ),
    preparationSteps: json["preparationSteps"] == null
        ? []
        : List<PreparationStep>.from(
            json["preparationSteps"]!.map((x) => PreparationStep.fromJson(x)),
          ),
    categories: List<RecipeCategory>.from(
      json["categories"].map((x) => RecipeCategory.fromJson(x)),
    ),
    link: json["link"],
    author: json["author"] != null ? Author.fromJson(json["author"]) : null,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "subtitle": subtitle,
    "createdAt": createdAt.toIso8601String(),
    "updatedAt": updatedAt.toIso8601String(),
    "images": List<dynamic>.from(images.map((x) => x.toJson())),
    "ingredients": ingredients == null
        ? []
        : List<dynamic>.from(ingredients!.map((x) => x.toJson())),
    "preparationSteps": preparationSteps == null
        ? []
        : List<dynamic>.from(preparationSteps!.map((x) => x.toJson())),
    "categories": List<dynamic>.from(categories.map((x) => x.toJson())),
    "link": link,
  };
}

class Author {
  final String id;
  final String nombre;

  Author({required this.id, required this.nombre});

  factory Author.fromRawJson(String str) => Author.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Author.fromJson(Map<String, dynamic> json) =>
      Author(id: json["id"], nombre: json["nombre"]);

  Map<String, dynamic> toJson() => {"id": id, "nombre": nombre};
}

class RecipeCategory {
  final int id;
  final String name;

  RecipeCategory({required this.id, required this.name});

  factory RecipeCategory.fromRawJson(String str) =>
      RecipeCategory.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory RecipeCategory.fromJson(Map<String, dynamic> json) =>
      RecipeCategory(id: json["id"], name: json["name"]);

  Map<String, dynamic> toJson() => {"id": id, "name": name};
}

class Image {
  final String url;
  final int position;

  Image({required this.url, required this.position});

  factory Image.fromRawJson(String str) => Image.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Image.fromJson(Map<String, dynamic> json) =>
      Image(url: json["url"], position: json["position"]);

  Map<String, dynamic> toJson() => {"url": url, "position": position};
}

class Ingredient {
  final double? amount;
  final String? measure;
  final String name;
  final int position;

  Ingredient({
    required this.amount,
    required this.measure,
    required this.name,
    required this.position,
  });

  factory Ingredient.fromRawJson(String str) =>
      Ingredient.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
    amount: json["amount"]?.toDouble(),
    measure: json["measure"],
    name: json["name"],
    position: json["position"],
  );

  Map<String, dynamic> toJson() => {
    "amount": amount,
    "measure": measure,
    "name": name,
    "position": position,
  };
}

class PreparationStep {
  final int stepNumber;
  final String description;

  PreparationStep({required this.stepNumber, required this.description});

  factory PreparationStep.fromRawJson(String str) =>
      PreparationStep.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory PreparationStep.fromJson(Map<String, dynamic> json) =>
      PreparationStep(
        stepNumber: json["step_number"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
    "step_number": stepNumber,
    "description": description,
  };
}
