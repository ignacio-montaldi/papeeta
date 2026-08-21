import 'package:flutter/material.dart';

/// Escala tipográfica del sistema: 7 roles nombrados sobre Quicksand.
///
/// Los 11 tamaños sueltos de la app vieja se colapsan acá. Un cambio global
/// toca este archivo y nada más.
///
/// Mapeo a los slots de Material, para que los widgets estándar hereden bien:
///
/// | Rol       | Spec                  | Slot Material   |
/// |-----------|-----------------------|-----------------|
/// | Display   | 30 · 700 · -0.5       | displaySmall    |
/// | Headline  | 24 · 700 · -0.3       | headlineMedium  |
/// | Title     | 20 · 600              | titleLarge      |
/// | Subtitle  | 18 · 600              | titleMedium     |
/// | Body      | 16 · 400              | bodyLarge       |
/// | Label     | 13 · 500              | labelMedium     |
/// | Overline  | 12 · 600 · +0.6 · MAY | labelSmall      |
abstract final class AppTypography {
  static const String fontFamily = 'Quicksand';

  /// Logo, momentos de marca.
  static const display = TextStyle(
    fontFamily: fontFamily,
    fontSize: 30,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    height: 1.15,
  );

  /// Título de pantalla.
  static const headline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.3,
    height: 1.2,
  );

  /// Títulos de sección.
  static const title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  /// Título de tarjeta — el workhorse del sistema.
  static const subtitle = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.25,
  );

  /// Ingredientes, pasos, cuerpo.
  static const body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
  );

  /// Autor, handles, ayuda.
  static const label = TextStyle(
    fontFamily: fontFamily,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.35,
  );

  /// Metadatos, categorías, chips. Va en mayúsculas.
  static const overline = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.6,
    height: 1.3,
  );

  /// Texto de los botones (no es uno de los 7 roles: es su propia medida).
  static const button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 15,
    fontWeight: FontWeight.w600,
    height: 1.2,
  );

  /// [TextTheme] completo para el [ThemeData].
  static TextTheme textTheme(Color onSurface, Color onSurfaceVariant) {
    return TextTheme(
      displayLarge: display.copyWith(color: onSurface),
      displayMedium: display.copyWith(color: onSurface),
      displaySmall: display.copyWith(color: onSurface),
      headlineLarge: headline.copyWith(color: onSurface),
      headlineMedium: headline.copyWith(color: onSurface),
      headlineSmall: headline.copyWith(color: onSurface),
      titleLarge: title.copyWith(color: onSurface),
      titleMedium: subtitle.copyWith(color: onSurface),
      titleSmall: label.copyWith(color: onSurface),
      bodyLarge: body.copyWith(color: onSurface),
      bodyMedium: body.copyWith(color: onSurface),
      bodySmall: label.copyWith(color: onSurfaceVariant),
      labelLarge: button.copyWith(color: onSurface),
      labelMedium: label.copyWith(color: onSurfaceVariant),
      labelSmall: overline.copyWith(color: onSurfaceVariant),
    );
  }
}
