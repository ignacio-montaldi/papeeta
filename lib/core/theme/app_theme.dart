import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_tokens.dart';
import 'app_typography.dart';

/// Los dos temas de la app.
///
/// Regla del sistema: ningún widget define colores literales. Todo sale de
/// `Theme.of(context).colorScheme` o de la extensión [AppSemanticColors].
abstract final class AppTheme {
  static final ThemeData light = _build(_lightScheme, AppSemanticColors.light);
  static final ThemeData dark = _build(_darkScheme, AppSemanticColors.dark);

  static const _lightScheme = ColorScheme(
    brightness: Brightness.light,
    primary: AppColors.primaryLight,
    onPrimary: AppColors.onPrimaryLight,
    primaryContainer: AppColors.primaryContainerLight,
    onPrimaryContainer: AppColors.onPrimaryContainerLight,
    secondary: AppColors.secondaryLight,
    onSecondary: AppColors.onSecondaryLight,
    secondaryContainer: AppColors.secondaryContainerLight,
    onSecondaryContainer: AppColors.onSecondaryContainerLight,
    tertiary: AppColors.secondaryLight,
    onTertiary: AppColors.onSecondaryLight,
    error: AppColors.error,
    onError: Color(0xFFFFFFFF),
    errorContainer: AppColors.errorContainerSoft,
    onErrorContainer: Color(0xFF410E0B),
    surface: AppColors.surfaceLight,
    onSurface: AppColors.onSurfaceLight,
    surfaceContainerLowest: Color(0xFFFFFFFF),
    surfaceContainerLow: Color(0xFFF9F4F8),
    surfaceContainer: AppColors.surfaceContainerLight,
    surfaceContainerHigh: AppColors.surfaceContainerHighLight,
    surfaceContainerHighest: Color(0xFFE8E1E7),
    onSurfaceVariant: AppColors.onSurfaceVariantLight,
    outline: AppColors.outlineLight,
    outlineVariant: AppColors.outlineVariantLight,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: AppColors.snackbarSurface,
    onInverseSurface: AppColors.snackbarText,
    inversePrimary: AppColors.primaryDark,
  );

  static const _darkScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: AppColors.primaryDark,
    onPrimary: AppColors.onPrimaryDark,
    primaryContainer: AppColors.primaryContainerDark,
    onPrimaryContainer: AppColors.onPrimaryContainerDark,
    secondary: AppColors.secondaryDark,
    onSecondary: AppColors.onSecondaryDark,
    secondaryContainer: AppColors.secondaryContainerDark,
    onSecondaryContainer: AppColors.onSecondaryContainerDark,
    tertiary: AppColors.secondaryDark,
    onTertiary: AppColors.onSecondaryDark,
    error: Color(0xFFF2B8B5),
    onError: Color(0xFF601410),
    errorContainer: Color(0xFF8C1D18),
    onErrorContainer: Color(0xFFF9DEDC),
    surface: AppColors.surfaceDark,
    onSurface: AppColors.onSurfaceDark,
    surfaceContainerLowest: Color(0xFF120D15),
    surfaceContainerLow: Color(0xFF1D171F),
    surfaceContainer: AppColors.surfaceContainerDark,
    surfaceContainerHigh: AppColors.surfaceContainerHighDark,
    surfaceContainerHighest: Color(0xFF372E3C),
    onSurfaceVariant: AppColors.onSurfaceVariantDark,
    outline: AppColors.outlineDark,
    outlineVariant: AppColors.outlineVariantDark,
    shadow: Color(0xFF000000),
    scrim: Color(0xFF000000),
    inverseSurface: AppColors.onSurfaceDark,
    onInverseSurface: AppColors.surfaceDark,
    inversePrimary: AppColors.primaryLight,
  );

  static ThemeData _build(ColorScheme scheme, AppSemanticColors semantic) {
    final text = AppTypography.textTheme(
      scheme.onSurface,
      scheme.onSurfaceVariant,
    );
    final isLight = scheme.brightness == Brightness.light;

    // En modo claro el app bar es el púrpura de marca con contenido blanco.
    // En oscuro, primary es un lila claro, así que el app bar usa la superficie
    // elevada y el contenido va en onSurface.
    final appBarBackground = isLight ? scheme.primary : scheme.surfaceContainer;
    final appBarForeground = isLight ? scheme.onPrimary : scheme.onSurface;

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      fontFamily: AppTypography.fontFamily,
      textTheme: text,
      extensions: [semantic],
      splashFactory: InkSparkle.splashFactory,

      appBarTheme: AppBarTheme(
        backgroundColor: appBarBackground,
        foregroundColor: appBarForeground,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: AppTypography.subtitle.copyWith(
          color: appBarForeground,
        ),
        iconTheme: IconThemeData(color: appBarForeground, size: 24),
        actionsIconTheme: IconThemeData(color: appBarForeground, size: 24),
        systemOverlayStyle: isLight
            ? SystemUiOverlayStyle.light
            : SystemUiOverlayStyle.light,
      ),

      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppSizes.fabRadius)),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          disabledBackgroundColor: AppColors.disabledFill,
          disabledForegroundColor: AppColors.disabledContent,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          elevation: 0,
          textStyle: AppTypography.button,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        ),
      ),

      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.secondary,
          disabledForegroundColor: AppColors.disabledTextOnly,
          minimumSize: const Size(0, AppSizes.buttonHeight),
          textStyle: AppTypography.button,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: scheme.secondaryContainer,
          foregroundColor: isLight
              ? AppColors.onSecondaryContainerStrong
              : scheme.onSecondaryContainer,
          disabledForegroundColor: AppColors.disabledContent,
          minimumSize: const Size.fromHeight(AppSizes.buttonHeight),
          side: BorderSide(color: scheme.secondary, width: 1.5),
          textStyle: AppTypography.button,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainer,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 12,
        ),
        labelStyle: AppTypography.label.copyWith(
          fontSize: 11,
          color: scheme.onSurfaceVariant,
        ),
        floatingLabelStyle: AppTypography.label.copyWith(
          fontSize: 11,
          color: scheme.primary,
        ),
        hintStyle: AppTypography.body.copyWith(
          fontSize: 15,
          color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
        ),
        helperStyle: AppTypography.label.copyWith(
          fontSize: 12,
          color: scheme.onSurfaceVariant,
        ),
        errorStyle: AppTypography.label.copyWith(
          fontSize: 12,
          color: scheme.error,
        ),
        border: _fieldBorder(scheme.outlineVariant),
        enabledBorder: _fieldBorder(scheme.outlineVariant),
        focusedBorder: _fieldBorder(scheme.primary),
        errorBorder: _fieldBorder(scheme.error),
        focusedErrorBorder: _fieldBorder(scheme.error),
        disabledBorder: _fieldBorder(AppColors.disabledOutline),
      ),

      cardTheme: CardThemeData(
        color: scheme.surfaceContainer,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),

      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainer,
        selectedColor: scheme.primary,
        disabledColor: AppColors.disabledFill,
        side: BorderSide(color: scheme.outlineVariant),
        labelStyle: AppTypography.label.copyWith(color: scheme.onSurface),
        secondaryLabelStyle: AppTypography.label.copyWith(
          color: scheme.onPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
        shape: const StadiumBorder(),
        showCheckmark: false,
      ),

      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: scheme.surface,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.sheetTop),
        clipBehavior: Clip.antiAlias,
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        titleTextStyle: AppTypography.subtitle.copyWith(color: scheme.onSurface),
        contentTextStyle: AppTypography.body.copyWith(
          fontSize: 15,
          color: scheme.onSurfaceVariant,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.snackbarSurface,
        contentTextStyle: AppTypography.label.copyWith(
          fontSize: 14,
          color: AppColors.snackbarText,
        ),
        actionTextColor: AppColors.snackbarInfo,
        elevation: 0,
        insetPadding: const EdgeInsets.all(AppSpacing.md),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(14)),
        ),
      ),

      dividerTheme: DividerThemeData(
        color: semantic.divider,
        thickness: 1,
        space: 1,
      ),

      listTileTheme: ListTileThemeData(
        iconColor: scheme.primary,
        titleTextStyle: AppTypography.body.copyWith(
          fontSize: 15,
          color: scheme.onSurface,
        ),
        subtitleTextStyle: AppTypography.label.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        circularTrackColor: Colors.transparent,
      ),

      iconTheme: IconThemeData(color: scheme.onSurface, size: 24),

      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color) {
    return OutlineInputBorder(
      borderRadius: AppRadius.mdAll,
      borderSide: BorderSide(color: color, width: 1.5),
    );
  }
}
