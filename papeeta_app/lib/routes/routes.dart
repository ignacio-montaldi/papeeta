import 'package:flutter/material.dart';

import 'package:papeeta/pages/chat_page.dart';
import 'package:papeeta/pages/loading_page.dart';
import 'package:papeeta/pages/login_page.dart';
import 'package:papeeta/pages/register_page.dart';
import 'package:papeeta/pages/usuarios_page.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  'usuarios': (_) => const UsuariosPage(),
  'chat': (_) => const ChatPage(),
  'login': (_) => const LoginPage(),
  'register': (_) => const RegisterPage(),
  'loading': (_) => const LoadingPage(),
};
