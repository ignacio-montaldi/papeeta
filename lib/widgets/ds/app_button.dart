import 'package:flutter/material.dart';

import 'package:papeeta/core/theme/theme.dart';

/// Variantes de la familia de botones del sistema.
enum AppButtonVariant {
  /// Púrpura de marca. La acción principal de la pantalla.
  primary,

  /// Tonal teal con borde. Acciones secundarias y la feature Grupos.
  secondary,

  /// Sin fondo. Acciones terciarias, "Ver todas", "Volver".
  text,

  /// Rojo. Acciones destructivas.
  destructive,
}

/// Botón del design system.
///
/// Reemplaza a `ButtonComponent` y a los `ElevatedButton.styleFrom` sueltos.
/// Cubre los cinco estados de la Fase 1: default, pressed, disabled, loading
/// y con ícono.
///
/// ```dart
/// AppButton(
///   label: 'Guardar receta',
///   icon: Icons.post_add_rounded,
///   onPressed: _guardar,
/// )
/// ```
class AppButton extends StatefulWidget {
  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.loadingLabel,
    this.expand = true,
    this.height,
  });

  final String label;

  /// `null` deja el botón deshabilitado.
  final VoidCallback? onPressed;

  final AppButtonVariant variant;
  final IconData? icon;

  /// Muestra un spinner y bloquea el tap.
  final bool isLoading;

  /// Texto mientras carga. Si es `null` se mantiene [label].
  final String? loadingLabel;

  /// Si ocupa todo el ancho disponible.
  final bool expand;

  final double? height;

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _pressed = false;

  bool get _enabled => widget.onPressed != null && !widget.isLoading;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final style = _resolve(colors);
    final height = widget.height ?? AppSizes.buttonHeight;

    final content = Row(
      mainAxisSize: widget.expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.isLoading) ...[
          SizedBox(
            width: 17,
            height: 17,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(style.foreground),
              backgroundColor: style.foreground.withValues(alpha: 0.35),
            ),
          ),
          const SizedBox(width: AppSpacing.sm + 2),
        ] else if (widget.icon != null) ...[
          Icon(widget.icon, size: 20, color: style.foreground),
          const SizedBox(width: AppSpacing.sm),
        ],
        Flexible(
          child: Text(
            widget.isLoading ? (widget.loadingLabel ?? widget.label) : widget.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.button.copyWith(color: style.foreground),
          ),
        ),
      ],
    );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: _enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
        onTap: _enabled ? widget.onPressed : null,
        child: AnimatedContainer(
          duration: AppMotion.fast,
          curve: AppMotion.standard,
          height: height,
          width: widget.expand ? double.infinity : null,
          padding: EdgeInsets.symmetric(
            horizontal: widget.expand ? AppSpacing.lg : AppSpacing.xl,
          ),
          decoration: BoxDecoration(
            color: style.background,
            borderRadius: AppRadius.mdAll,
            border: style.border == null
                ? null
                : Border.all(color: style.border!, width: 1.5),
            boxShadow: _pressed && widget.variant == AppButtonVariant.primary
                ? AppElevation.e3
                : null,
          ),
          child: Center(child: content),
        ),
      ),
    );
  }

  _ButtonStyle _resolve(ColorScheme colors) {
    if (!_enabled && !widget.isLoading) return _disabled();

    return switch (widget.variant) {
      AppButtonVariant.primary => _ButtonStyle(
          background: _pressed ? AppColors.primaryPressed : colors.primary,
          foreground: colors.onPrimary,
        ),
      AppButtonVariant.secondary => _ButtonStyle(
          background: _pressed
              ? AppColors.secondaryContainerPressed
              : colors.secondaryContainer,
          foreground: _pressed
              ? AppColors.onSecondaryPressed
              : AppColors.onSecondaryContainerStrong,
          border: _pressed ? AppColors.secondaryPressedBorder : colors.secondary,
        ),
      AppButtonVariant.text => _ButtonStyle(
          background:
              _pressed ? AppColors.textButtonPressed : Colors.transparent,
          foreground: colors.secondary,
        ),
      AppButtonVariant.destructive => _ButtonStyle(
          background: _pressed ? AppColors.errorPressed : colors.error,
          foreground: colors.onError,
        ),
    };
  }

  _ButtonStyle _disabled() {
    return switch (widget.variant) {
      AppButtonVariant.text => const _ButtonStyle(
          background: Colors.transparent,
          foreground: AppColors.disabledTextOnly,
        ),
      AppButtonVariant.secondary => const _ButtonStyle(
          background: Colors.transparent,
          foreground: AppColors.disabledContent,
          border: AppColors.disabledOutline,
        ),
      _ => const _ButtonStyle(
          background: AppColors.disabledFill,
          foreground: AppColors.disabledContent,
        ),
    };
  }
}

class _ButtonStyle {
  const _ButtonStyle({
    required this.background,
    required this.foreground,
    this.border,
  });

  final Color background;
  final Color foreground;
  final Color? border;
}
