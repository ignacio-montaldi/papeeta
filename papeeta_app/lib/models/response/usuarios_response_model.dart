// To parse this JSON data, do
//
//     final usuariosResponse = usuariosResponseFromJson(jsonString);

import 'dart:convert';

import 'package:papeeta/models/usuario_model.dart';

UsuariosResponseModel usuariosResponseFromJson(String str) =>
    UsuariosResponseModel.fromJson(json.decode(str));

String usuariosResponseToJson(UsuariosResponseModel data) =>
    json.encode(data.toJson());

class UsuariosResponseModel {
  bool ok;
  List<UsuarioModel> usuarios;

  UsuariosResponseModel({required this.ok, required this.usuarios});

  factory UsuariosResponseModel.fromJson(Map<String, dynamic> json) =>
      UsuariosResponseModel(
        ok: json["ok"],
        usuarios: List<UsuarioModel>.from(
          json["usuarios"].map((x) => UsuarioModel.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "ok": ok,
    "usuarios": List<dynamic>.from(usuarios.map((x) => x.toJson())),
  };
}
