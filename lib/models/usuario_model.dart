// To parse this JSON data, do
//
//     final usuario = usuarioFromJson(jsonString);

import 'dart:convert';

UsuarioModel usuarioFromJson(String str) =>
    UsuarioModel.fromJson(json.decode(str));

String usuarioToJson(UsuarioModel data) => json.encode(data.toJson());

class UsuarioModel {
  String nombre;
  String email;
  String uid;

  UsuarioModel({required this.nombre, required this.email, required this.uid});

  factory UsuarioModel.fromJson(Map<String, dynamic> json) => UsuarioModel(
    nombre: json["nombre"],
    email: json["email"],
    uid: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "nombre": nombre,
    "email": email,
    "id": uid,
  };
}
