import 'package:flutter/material.dart';

class Labels extends StatelessWidget {
  final String ruta;
  final String titulo;
  final String subtitulo;

  const Labels(
      {super.key,
      required this.ruta,
      required this.titulo,
      required this.subtitulo});

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
            Navigator.pushReplacementNamed(context, ruta);
          },
          child: Text(
            subtitulo, //'Crea una ahora!',
            style: TextStyle(
              color: Colors.blue[600],
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    );
  }
}
