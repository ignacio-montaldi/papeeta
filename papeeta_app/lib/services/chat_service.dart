import 'package:papeeta/global/enviroment.dart';
import 'package:papeeta/models/mensajes_response.dart';
import 'package:papeeta/services/auth_service.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:papeeta/models/usuario.dart';

class ChatService with ChangeNotifier {
  late Usuario usuarioPara;

  Future<List<Mensaje>> getChat(String usuarioID) async {
    final uri = Uri.parse('${Enviroment.apiUrl}/mensajes/$usuarioID');
    final resp = await http.get(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'x-token': await AuthService.getToken() ?? ''
      },
    );
    final mensajesResp = mensajesResponseFromJson(resp.body);
    return mensajesResp.mensajes;
  }
}
