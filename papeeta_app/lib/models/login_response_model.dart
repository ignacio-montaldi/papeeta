// To parse this JSON data, do
//
//     final loginResponse = loginResponseFromJson(jsonString);

import 'dart:convert';

import 'package:papeeta/models/usuario_model.dart';

LoginResponseModel loginResponseFromJson(String str) =>
    LoginResponseModel.fromJson(json.decode(str));

String loginResponseToJson(LoginResponseModel data) =>
    json.encode(data.toJson());

class LoginResponseModel {
  bool ok;
  UsuarioModel usuario;
  String token;

  LoginResponseModel({
    required this.ok,
    required this.usuario,
    required this.token,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) =>
      LoginResponseModel(
        ok: json["ok"],
        usuario: UsuarioModel.fromJson(json["usuario"]),
        token: json["token"],
      );

  Map<String, dynamic> toJson() => {
    "ok": ok,
    "usuario": usuario.toJson(),
    "token": token,
  };
}
