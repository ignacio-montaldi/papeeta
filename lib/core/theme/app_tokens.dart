import 'package:flutter/material.dart';

/// Escala de espaciado. Base 4 — se elimina la convención de múltiplos de 5.
abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 48;

  /// Padding horizontal estándar de una pantalla.
  static const EdgeInsets screen = EdgeInsets.all(lg);
}

/// Radios de esquina. De 8 escalas a 5.
abstract final class AppRadius {
  /// Chips informativos, imágenes internas.
  static const double sm = 8;

  /// Botones, inputs, tarjeta de receta.
  static const double md = 12;

  /// Tarjetas, sheet de imagen.
  static const double lg = 16;

  /// Bottom sheets.
  static const double xl = 24;

  /// Chips de filtro, avatares, FAB.
  static const double full = 999;

  static const smAll = BorderRadius.all(Radius.circular(sm));
  static const mdAll = BorderRadius.all(Radius.circular(md));
  static const lgAll = BorderRadius.all(Radius.circular(lg));
  static const xlAll = BorderRadius.all(Radius.circular(xl));
  static const fullAll = BorderRadius.all(Radius.circular(full));

  /// Radio superior para bottom sheets.
  static const sheetTop = BorderRadius.vertical(top: Radius.circular(xl));
}

/// Cinco niveles de elevación, como sombras explícitas.
///
/// Se usan con `BoxDecoration(boxShadow: AppElevation.e1)` en vez de la
/// elevación de Material, para que el color de la sombra sea el del sistema.
abstract final class AppElevation {
  static const List<BoxShadow> e0 = [];

  /// Tarjetas de receta y grupo.
  static const List<BoxShadow> e1 = [
    BoxShadow(
      color: Color(0x0F1C1620),
      blurRadius: 2,
      offset: Offset(0, 1),
    ),
    BoxShadow(
      color: Color(0x0F1C1620),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  /// Bottom sheets, menús.
  static const List<BoxShadow> e2 = [
    BoxShadow(
      color: Color(0x141C1620),
      blurRadius: 6,
      offset: Offset(0, 2),
    ),
    BoxShadow(
      color: Color(0x1A1C1620),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  /// FAB.
  static const List<BoxShadow> e3 = [
    BoxShadow(
      color: Color(0x473C1642),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];

  /// Diálogos.
  static const List<BoxShadow> e4 = [
    BoxShadow(
      color: Color(0x381C1620),
      blurRadius: 40,
      offset: Offset(0, 12),
    ),
  ];

  /// Sombra del FAB secundario (teal).
  static const List<BoxShadow> fabSecondary = [
    BoxShadow(
      color: Color(0x4D0B6E7F),
      blurRadius: 16,
      offset: Offset(0, 6),
    ),
  ];
}

/// Duraciones y curvas.
abstract final class AppMotion {
  /// Estados de presión, ripple.
  static const Duration fast = Duration(milliseconds: 120);

  /// La mayoría de transiciones.
  static const Duration base = Duration(milliseconds: 200);

  /// App bar colapsando, puntos del carrusel.
  static const Duration emphasized = Duration(milliseconds: 300);

  /// Entrada/salida de bottom sheets.
  static const Duration sheet = Duration(milliseconds: 350);

  /// Curva por defecto.
  static const Curve standard = Cubic(0.2, 0, 0, 1);

  /// Entradas de elementos.
  static const Curve decelerate = Cubic(0, 0, 0, 1);

  /// Ciclo del shimmer de los skeletons.
  static const Duration shimmer = Duration(milliseconds: 1300);
}

/// Medidas fijas que el diseño define una sola vez.
abstract final class AppSizes {
  /// Alto de los botones de la familia principal.
  static const double buttonHeight = 48;

  /// Alto del botón de acción a ancho completo en formularios.
  static const double buttonHeightLarge = 50;

  /// Lado del FAB.
  static const double fab = 56;

  /// Radio de esquina del FAB (no es circular: es un squircle de 18).
  static const double fabRadius = 18;

  /// Alto del app bar.
  static const double appBar = 56;

  /// Diámetro del círculo de categoría en Home.
  static const double categoryCircle = 56;

  /// Alto de la foto en la tarjeta de receta (relación 16:11).
  static const double recipeCardImageRatio = 16 / 11;

  /// Alto del header de foto en el detalle de receta.
  static const double recipeHeaderHeight = 300;

  /// Alto de la portada en la tarjeta de grupo.
  static const double groupCoverHeight = 96;
}
