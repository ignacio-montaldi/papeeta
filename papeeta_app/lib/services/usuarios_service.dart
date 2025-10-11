import 'package:papeeta/global/enviroment.dart';
import 'package:papeeta/models/usuarios_response.dart';
import 'package:papeeta/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:papeeta/models/usuario.dart';

class UsuariosService {
  Future<List<Usuario>> getUsuarios() async {
    try {
      final uri = Uri.parse('${Enviroment.apiUrl}/usuarios');
      final resp = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'x-token': await AuthService.getToken() ?? ''
        },
      );

      final usuariosResponse = usuariosResponseFromJson(resp.body);

      return usuariosResponse.usuarios;
    } catch (e) {
      return [];
    }
  }
}
