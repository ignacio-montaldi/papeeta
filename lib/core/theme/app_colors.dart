import 'package:flutter/material.dart';

/// Paleta cruda del design system (Fase 1).
///
/// No usar estos valores directamente en widgets: consumirlos vía
/// `Theme.of(context).colorScheme` o vía [AppSemanticColors]. Están acá para
/// que exista un único lugar donde cambiar un color del sistema.
abstract final class AppColors {
  // ---------------------------------------------------------------- claro ---
  static const primaryLight = Color(0xFF3C1642);
  static const onPrimaryLight = Color(0xFFFFFFFF);
  static const primaryContainerLight = Color(0xFFF3E7F1);
  static const onPrimaryContainerLight = Color(0xFF2A0F30);

  static const secondaryLight = Color(0xFF0B6E7F);
  static const onSecondaryLight = Color(0xFFFFFFFF);
  static const secondaryContainerLight = Color(0xFFDCEFF2);
  static const onSecondaryContainerLight = Color(0xFF063742);

  static const surfaceLight = Color(0xFFFDFBFD);
  static const surfaceContainerLight = Color(0xFFF5F0F4);
  static const surfaceContainerHighLight = Color(0xFFEEE7EC);
  static const onSurfaceLight = Color(0xFF1C1620);
  static const onSurfaceVariantLight = Color(0xFF6B6470);

  static const outlineLight = Color(0xFF8C8391);
  static const outlineVariantLight = Color(0xFFE4DCE2);

  // --------------------------------------------------------------- oscuro ---
  static const primaryDark = Color(0xFFE7B6E2);
  static const onPrimaryDark = Color(0xFF45204A);
  static const primaryContainerDark = Color(0xFF5A2E60);
  static const onPrimaryContainerDark = Color(0xFFF7E4F4);

  static const secondaryDark = Color(0xFF66D0DE);
  static const onSecondaryDark = Color(0xFF00363F);
  static const secondaryContainerDark = Color(0xFF0B4A54);
  static const onSecondaryContainerDark = Color(0xFFB4ECF3);

  static const surfaceDark = Color(0xFF17121A);
  static const surfaceContainerDark = Color(0xFF211A24);
  static const surfaceContainerHighDark = Color(0xFF2C2431);
  static const onSurfaceDark = Color(0xFFECE3EA);
  static const onSurfaceVariantDark = Color(0xFFCDC2CB);

  static const outlineDark = Color(0xFF978C96);
  static const outlineVariantDark = Color(0xFF443B49);

  // ----------------------------------------------------------- semánticos ---
  static const error = Color(0xFFB3261E);
  static const success = Color(0xFF1E7A46);
  static const warning = Color(0xFFB26A00);
  static const info = secondaryLight;

  // ------------------------------------------------ estados de interacción --
  /// Púrpura presionado del botón primario.
  static const primaryPressed = Color(0xFF2C0F31);
  static const secondaryContainerPressed = Color(0xFFC6E7EB);
  static const secondaryPressedBorder = Color(0xFF085460);
  static const onSecondaryPressed = Color(0xFF063742);

  /// Fondo del botón de texto en hover/pressed.
  static const textButtonPressed = Color(0xFFE6F2F4);
  static const errorPressed = Color(0xFF8C1D17);

  static const disabledFill = Color(0xFFEAE4E9);
  static const disabledContent = Color(0xFFB4ADB6);
  static const disabledOutline = Color(0xFFE0DAE0);
  static const disabledTextOnly = Color(0xFFC6BFC8);

  /// Teal oscuro para texto sobre [secondaryContainerLight].
  static const onSecondaryContainerStrong = Color(0xFF085460);

  // ------------------------------------------------------------ superficies --
  /// Fondo del ícono en estados de error ilustrados.
  static const errorContainerSoft = Color(0xFFFBE9E8);

  /// Fondo del campo de texto en estado de error.
  static const errorFieldFill = Color(0xFFFFF8F7);

  static const inputDisabledFill = Color(0xFFF0ECEF);

  /// Borde punteado del área de subir foto.
  static const dashedBorder = Color(0xFFC9BEC8);
  static const dashedFill = Color(0xFFFAF6F9);

  /// Ícono púrpura claro de los empty states.
  static const emptyIcon = Color(0xFFB98FBE);

  static const divider = Color(0xFFEFEAEE);

  // -------------------------------------------------------------- skeleton --
  static const skeletonBaseLight = Color(0xFFE7DEE7);
  static const skeletonHighlightLight = Color(0xFFF3ECF3);
  static const skeletonBaseDark = Color(0xFF2A222E);
  static const skeletonHighlightDark = Color(0xFF372E3C);

  // ------------------------------------------------------------- snackbar ---
  static const snackbarSurface = Color(0xFF2A2230);
  static const snackbarText = Color(0xFFF4EEF3);
  static const snackbarSuccess = Color(0xFF7BE0A3);
  static const snackbarError = Color(0xFFF2B8B5);
  static const snackbarWarning = Color(0xFFF5C97A);
  static const snackbarInfo = Color(0xFF66D0DE);
}

/// Colores del sistema que Material 3 no modela como roles del [ColorScheme].
///
/// Se acceden con `Theme.of(context).extension<AppSemanticColors>()!` o, más
/// corto, con `context.semantic` (ver `theme_x.dart`).
@immutable
class AppSemanticColors extends ThemeExtension<AppSemanticColors> {
  const AppSemanticColors({
    required this.success,
    required this.onSuccess,
    required this.warning,
    required this.onWarning,
    required this.info,
    required this.emptyIcon,
    required this.emptyIconBackground,
    required this.errorIconBackground,
    required this.skeletonBase,
    required this.skeletonHighlight,
    required this.dashedBorder,
    required this.dashedFill,
    required this.divider,
  });

  final Color success;
  final Color onSuccess;
  final Color warning;
  final Color onWarning;
  final Color info;

  /// Ícono de los empty states ilustrados.
  final Color emptyIcon;
  final Color emptyIconBackground;
  final Color errorIconBackground;

  final Color skeletonBase;
  final Color skeletonHighlight;

  final Color dashedBorder;
  final Color dashedFill;
  final Color divider;

  static const light = AppSemanticColors(
    success: AppColors.success,
    onSuccess: Color(0xFFFFFFFF),
    warning: AppColors.warning,
    onWarning: Color(0xFFFFFFFF),
    info: AppColors.info,
    emptyIcon: AppColors.emptyIcon,
    emptyIconBackground: AppColors.primaryContainerLight,
    errorIconBackground: AppColors.errorContainerSoft,
    skeletonBase: AppColors.skeletonBaseLight,
    skeletonHighlight: AppColors.skeletonHighlightLight,
    dashedBorder: AppColors.dashedBorder,
    dashedFill: AppColors.dashedFill,
    divider: AppColors.divider,
  );

  static const dark = AppSemanticColors(
    success: Color(0xFF7BE0A3),
    onSuccess: Color(0xFF00391D),
    warning: Color(0xFFF5C97A),
    onWarning: Color(0xFF3D2A00),
    info: AppColors.snackbarInfo,
    emptyIcon: Color(0xFF9C7AA1),
    emptyIconBackground: AppColors.primaryContainerDark,
    errorIconBackground: Color(0xFF4A2320),
    skeletonBase: AppColors.skeletonBaseDark,
    skeletonHighlight: AppColors.skeletonHighlightDark,
    dashedBorder: Color(0xFF5A4F5C),
    dashedFill: Color(0xFF1F1922),
    divider: AppColors.outlineVariantDark,
  );

  @override
  AppSemanticColors copyWith({
    Color? success,
    Color? onSuccess,
    Color? warning,
    Color? onWarning,
    Color? info,
    Color? emptyIcon,
    Color? emptyIconBackground,
    Color? errorIconBackground,
    Color? skeletonBase,
    Color? skeletonHighlight,
    Color? dashedBorder,
    Color? dashedFill,
    Color? divider,
  }) {
    return AppSemanticColors(
      success: success ?? this.success,
      onSuccess: onSuccess ?? this.onSuccess,
      warning: warning ?? this.warning,
      onWarning: onWarning ?? this.onWarning,
      info: info ?? this.info,
      emptyIcon: emptyIcon ?? this.emptyIcon,
      emptyIconBackground: emptyIconBackground ?? this.emptyIconBackground,
      errorIconBackground: errorIconBackground ?? this.errorIconBackground,
      skeletonBase: skeletonBase ?? this.skeletonBase,
      skeletonHighlight: skeletonHighlight ?? this.skeletonHighlight,
      dashedBorder: dashedBorder ?? this.dashedBorder,
      dashedFill: dashedFill ?? this.dashedFill,
      divider: divider ?? this.divider,
    );
  }

  @override
  AppSemanticColors lerp(AppSemanticColors? other, double t) {
    if (other == null) return this;
    return AppSemanticColors(
      success: Color.lerp(success, other.success, t)!,
      onSuccess: Color.lerp(onSuccess, other.onSuccess, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      onWarning: Color.lerp(onWarning, other.onWarning, t)!,
      info: Color.lerp(info, other.info, t)!,
      emptyIcon: Color.lerp(emptyIcon, other.emptyIcon, t)!,
      emptyIconBackground:
          Color.lerp(emptyIconBackground, other.emptyIconBackground, t)!,
      errorIconBackground:
          Color.lerp(errorIconBackground, other.errorIconBackground, t)!,
      skeletonBase: Color.lerp(skeletonBase, other.skeletonBase, t)!,
      skeletonHighlight:
          Color.lerp(skeletonHighlight, other.skeletonHighlight, t)!,
      dashedBorder: Color.lerp(dashedBorder, other.dashedBorder, t)!,
      dashedFill: Color.lerp(dashedFill, other.dashedFill, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
    );
  }
}
