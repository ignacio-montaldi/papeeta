import 'dart:convert';

class IngredientsUnitsResponseModel {
  final bool ok;
  final List<UnitModel> units;

  IngredientsUnitsResponseModel({required this.ok, required this.units});

  factory IngredientsUnitsResponseModel.fromRawJson(String str) =>
      IngredientsUnitsResponseModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory IngredientsUnitsResponseModel.fromJson(Map<String, dynamic> json) =>
      IngredientsUnitsResponseModel(
        ok: json["ok"],
        units: List<UnitModel>.from(
          json["units"].map((x) => UnitModel.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "ok": ok,
    "units": List<dynamic>.from(units.map((x) => x.toJson())),
  };
}

class UnitModel {
  final int id;
  final String unitKey;
  final String displayName;
  final String type;

  UnitModel({
    required this.id,
    required this.unitKey,
    required this.displayName,
    required this.type,
  });

  factory UnitModel.fromRawJson(String str) =>
      UnitModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory UnitModel.fromJson(Map<String, dynamic> json) => UnitModel(
    id: json["id"],
    unitKey: json["unit_key"],
    displayName: json["display_name"],
    type: json["type"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "unit_key": unitKey,
    "display_name": displayName,
    "type": type,
  };
}
