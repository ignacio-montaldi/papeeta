import 'package:flutter/material.dart';

import 'package:papeeta/core/theme/theme.dart';

/// Chip de filtro o categoría. Pill.
///
/// Seleccionado se rellena con el púrpura de marca y muestra un check.
class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.label,
    this.selected = false,
    this.enabled = true,
    this.onTap,
  });

  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    final Color background;
    final Color foreground;
    final Color? border;

    if (!enabled) {
      background = AppColors.inputDisabledFill;
      foreground = AppColors.disabledContent;
      border = AppColors.disabledFill;
    } else if (selected) {
      background = colors.primary;
      foreground = colors.onPrimary;
      border = null;
    } else {
      background = colors.surfaceContainer;
      foreground = context.text.bodyMedium!.color!;
      border = colors.outlineVariant;
    }

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: AppMotion.fast,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: background,
          borderRadius: AppRadius.fullAll,
          border: border == null ? null : Border.all(color: border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (selected) ...[
              Icon(Icons.check_rounded, size: 16, color: foreground),
              const SizedBox(width: AppSpacing.xs + 2),
            ],
            Text(
              label,
              style: AppTypography.label.copyWith(
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: foreground,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Chip de categoría en el detalle de receta: tinte de marca, sin borde.
class AppCategoryChip extends StatelessWidget {
  const AppCategoryChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 13,
        vertical: AppSpacing.sm - 2,
      ),
      decoration: BoxDecoration(
        color: colors.primaryContainer,
        borderRadius: AppRadius.fullAll,
      ),
      child: Text(
        label,
        style: AppTypography.overline.copyWith(
          fontSize: 11,
          letterSpacing: 0,
          color: colors.brightness == Brightness.light
              ? colors.primary
              : colors.onPrimaryContainer,
        ),
      ),
    );
  }
}

/// Píldora informativa: ícono + dato. "8 miembros", "24 recetas", "45 min".
class AppInfoChip extends StatelessWidget {
  const AppInfoChip({
    super.key,
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 5),
      decoration: BoxDecoration(
        color: colors.surfaceContainer,
        borderRadius: AppRadius.fullAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colors.onSurfaceVariant),
          const SizedBox(width: 5),
          Text(
            label,
            style: AppTypography.label.copyWith(
              fontSize: 12,
              color: colors.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
