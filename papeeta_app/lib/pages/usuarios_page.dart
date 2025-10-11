import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:papeeta/models/usuario.dart';

import 'package:papeeta/services/auth_service.dart';
import 'package:papeeta/services/chat_service.dart';
import 'package:papeeta/services/socket_service.dart';
import 'package:papeeta/services/usuarios_service.dart';

class UsuariosPage extends StatefulWidget {
  const UsuariosPage({super.key});

  @override
  State<UsuariosPage> createState() => _UsuariosPageState();
}

class _UsuariosPageState extends State<UsuariosPage> {
  final usuarioService = UsuariosService();
  final RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  List<Usuario> usuarios = [];

  @override
  void initState() {
    _cargarUsuarios();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final socketService = Provider.of<SocketService>(context);
    final usuario = authService.usuario;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          usuario.nombre,
          style: const TextStyle(color: Colors.black87),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            child: socketService.serverStatus == ServerStatus.online
                ? Icon(Icons.check_circle, color: Colors.blue[400])
                : const Icon(Icons.offline_bolt, color: Colors.red),
          )
        ],
        elevation: 1,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(
            Icons.exit_to_app,
            color: Colors.black87,
          ),
          onPressed: () {
            socketService.disconnect();
            Navigator.pushReplacementNamed(context, 'login');
            AuthService.deleteToken();
          },
        ),
      ),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        onRefresh: () => _cargarUsuarios(),
        header: WaterDropHeader(
          complete: Icon(
            Icons.check,
            color: Colors.blue[400],
          ),
          waterDropColor: Colors.blue[400] ?? Colors.blue,
        ),
        child: _listViewUsuarios(),
      ),
    );
  }

  Widget _listViewUsuarios() {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) => _usuarioListTile(usuarios[index]),
      separatorBuilder: (context, index) => const Divider(),
      itemCount: usuarios.length,
    );
  }

  Widget _usuarioListTile(Usuario usuario) {
    return ListTile(
      title: Text(usuario.nombre),
      subtitle: Text(
        usuario.email,
        style: const TextStyle(color: Colors.black54),
      ),
      leading: CircleAvatar(
        backgroundColor: Colors.blue[100],
        child: Text(usuario.nombre.substring(0, 2)),
      ),
      trailing: Container(
        width: 10,
        height: 10,
        decoration: BoxDecoration(
          color: usuario.online ? Colors.green[300] : Colors.red,
          borderRadius: BorderRadius.circular(100),
        ),
      ),
      onTap: () {
        final chatService = Provider.of<ChatService>(context, listen: false);

        chatService.usuarioPara = usuario;
        Navigator.pushNamed(context, 'chat');
      },
    );
  }

  _cargarUsuarios() async {
    usuarios = await usuarioService.getUsuarios();
    setState(() {});

    // await Future.delayed(const Duration(milliseconds: 1000));
    // if failed,use refreshFailed()
    _refreshController.refreshCompleted();
  }
}
