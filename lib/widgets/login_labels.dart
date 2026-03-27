import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginLabels extends StatelessWidget {
  final String ruta;
  final String titulo;
  final String subtitulo;

  const LoginLabels({
    super.key,
    required this.ruta,
    required this.titulo,
    required this.subtitulo,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          titulo, //'¿No tienes cuenta?',
          style: const TextStyle(
            color: Colors.black54,
            fontSize: 15,
            fontWeight: FontWeight.w300,
          ),
        ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            final path = ruta == 'login' ? '/login' : '/register';
            context.go(path);
          },
          child: Text(
            subtitulo, //'Crea una ahora!',
            style: TextStyle(
              color: Color(0XFF086375),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
