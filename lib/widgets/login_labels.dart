import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:papeeta/core/theme/theme.dart';

/// Par pregunta + acción para alternar entre Login y Register.
class LoginLabels extends StatelessWidget {
  const LoginLabels({
    super.key,
    required this.ruta,
    required this.titulo,
    required this.subtitulo,
  });

  final String ruta;
  final String titulo;
  final String subtitulo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          titulo,
          style: AppTypography.body.copyWith(
            fontSize: 15,
            color: colors.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: () => context.go(ruta == 'login' ? '/login' : '/register'),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
            child: Text(
              subtitulo,
              style: AppTypography.button.copyWith(
                fontSize: 16,
                color: colors.secondary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
