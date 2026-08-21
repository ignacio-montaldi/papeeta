import 'package:flutter/material.dart';

import 'package:papeeta/core/theme/theme.dart';

/// Logo de marca de las pantallas de autenticación.
class Logo extends StatelessWidget {
  const Logo({super.key, required this.titulo});

  final String titulo;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.only(top: AppSpacing.xxxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 140,
              child: Image.asset('images/app_icon/launcher_icon.png'),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              titulo,
              style: AppTypography.display.copyWith(color: colors.primary),
            ),
          ],
        ),
      ),
    );
  }
}
