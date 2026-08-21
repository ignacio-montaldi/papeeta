import 'package:flutter/material.dart';

import 'package:papeeta/core/theme/theme.dart';
import 'app_button.dart';

/// Estado vacío ilustrado. Un solo patrón para toda la app.
///
/// Reemplaza a los `Center(child: Text('No se encontraron…'))` sueltos.
class EmptyStateView extends StatelessWidget {
  const EmptyStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.tone = EmptyStateTone.brand,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;

  /// Define el color del círculo y del botón.
  final EmptyStateTone tone;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final semantic = context.semantic;

    final (bubble, iconColor, variant) = switch (tone) {
      EmptyStateTone.brand => (
          semantic.emptyIconBackground,
          semantic.emptyIcon,
          AppButtonVariant.primary,
        ),
      EmptyStateTone.accent => (
          colors.secondaryContainer,
          colors.secondary,
          AppButtonVariant.secondary,
        ),
    };

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl + 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: bubble, shape: BoxShape.circle),
              child: Icon(icon, size: 42, color: iconColor),
            ),
            const SizedBox(height: AppSpacing.xl - 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.subtitle.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                fontSize: 14,
                color: colors.onSurfaceVariant,
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.xl - 2),
              AppButton(
                label: actionLabel!,
                icon: actionIcon,
                onPressed: onAction,
                variant: variant,
                expand: false,
                height: 46,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

enum EmptyStateTone { brand, accent }

/// Estado de error con salida. Nunca se muestra un mensaje técnico sin acción.
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.wifi_off_rounded,
    this.onRetry,
    this.retryLabel = 'Reintentar',
    this.onSecondary,
    this.secondaryLabel,
  });

  final String title;
  final String message;
  final IconData icon;
  final VoidCallback? onRetry;
  final String retryLabel;
  final VoidCallback? onSecondary;
  final String? secondaryLabel;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final semantic = context.semantic;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xxl + 2),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: semantic.errorIconBackground,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 42, color: colors.error),
            ),
            const SizedBox(height: AppSpacing.xl - 4),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTypography.subtitle.copyWith(color: colors.onSurface),
            ),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTypography.body.copyWith(
                fontSize: 14,
                color: colors.onSurfaceVariant,
              ),
            ),
            if (onRetry != null || onSecondary != null) ...[
              const SizedBox(height: AppSpacing.xl - 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (onRetry != null)
                    AppButton(
                      label: retryLabel,
                      icon: Icons.refresh_rounded,
                      onPressed: onRetry,
                      variant: AppButtonVariant.secondary,
                      expand: false,
                      height: 46,
                    ),
                  if (onRetry != null && onSecondary != null)
                    const SizedBox(width: AppSpacing.sm + 2),
                  if (onSecondary != null && secondaryLabel != null)
                    AppButton(
                      label: secondaryLabel!,
                      onPressed: onSecondary,
                      variant: AppButtonVariant.text,
                      expand: false,
                      height: 46,
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
