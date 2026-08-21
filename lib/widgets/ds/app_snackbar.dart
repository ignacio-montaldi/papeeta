import 'package:flutter/material.dart';

import 'package:papeeta/core/theme/theme.dart';

/// Intención de un snackbar. Define ícono y color del acento.
enum SnackIntent { success, error, warning, info }

/// Feedback flotante del sistema.
///
/// Un solo mecanismo para toda la app: reemplaza a `mostrarAlerta` (el diálogo
/// del login) y a los `SnackBar` armados a mano. El error de red siempre
/// ofrece salida, así que [onAction] es obligatorio de facto en
/// [SnackIntent.error].
void showAppSnackBar(
  BuildContext context, {
  required String message,
  SnackIntent intent = SnackIntent.info,
  String? actionLabel,
  VoidCallback? onAction,
}) {
  final (icon, accent) = switch (intent) {
    SnackIntent.success => (
        Icons.check_circle_rounded,
        AppColors.snackbarSuccess,
      ),
    SnackIntent.error => (Icons.error_rounded, AppColors.snackbarError),
    SnackIntent.warning => (Icons.warning_rounded, AppColors.snackbarWarning),
    SnackIntent.info => (Icons.info_rounded, AppColors.snackbarInfo),
  };

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, size: 20, color: accent),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                message,
                style: AppTypography.label.copyWith(
                  fontSize: 13,
                  color: AppColors.snackbarText,
                ),
              ),
            ),
          ],
        ),
        action: actionLabel != null && onAction != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: accent,
                onPressed: onAction,
              )
            : null,
        duration: intent == SnackIntent.error
            ? const Duration(seconds: 6)
            : const Duration(seconds: 4),
      ),
    );
}
