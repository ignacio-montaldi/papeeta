import 'package:flutter/material.dart';

import 'app_colors.dart';

export 'app_colors.dart';
export 'app_theme.dart';
export 'app_tokens.dart';
export 'app_typography.dart';

/// Atajos para llegar al tema sin escribir `Theme.of(context)` cada vez.
extension AppThemeX on BuildContext {
  ThemeData get theme => Theme.of(this);

  ColorScheme get colors => Theme.of(this).colorScheme;

  TextTheme get text => Theme.of(this).textTheme;

  /// Colores del sistema que Material no modela como roles.
  AppSemanticColors get semantic =>
      Theme.of(this).extension<AppSemanticColors>() ?? AppSemanticColors.light;

  bool get isDark => Theme.of(this).brightness == Brightness.dark;
}
