import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:papeeta/services/auth_service.dart';
import 'package:papeeta/services/socket_service.dart';

import 'package:papeeta/pages/login_page.dart';
import 'package:papeeta/pages/usuarios_page.dart';

class LoadingPage extends StatelessWidget {
  const LoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder(
        future: checkLoginState(context),
        builder: (context, snapshot) => const Center(
          child: Text('Espere...'),
        ),
      ),
    );
  }

  Future checkLoginState(BuildContext context) async {
    final authService = Provider.of<AuthService>(context, listen: false);
    final socketService = Provider.of<SocketService>(context, listen: false);

    final autenticando = await authService.isLoggedIn();

    if (!context.mounted) return;

    if (autenticando) {
      socketService.connect();
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const UsuariosPage(),
          transitionDuration: const Duration(milliseconds: 0),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const LoginPage(),
          transitionDuration: const Duration(milliseconds: 0),
        ),
      );
    }
  }
}
