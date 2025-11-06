import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final String titulo;

  const Logo({super.key, required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 50),
        width: 170,
        child: Column(
          children: [
            const Image(image: AssetImage('images/app_icon/launcher_icon.png')),
            const SizedBox(height: 20),
            Text(titulo, style: const TextStyle(fontSize: 30)),
          ],
        ),
      ),
    );
  }
}
