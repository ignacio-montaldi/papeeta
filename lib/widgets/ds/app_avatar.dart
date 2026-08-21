import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'package:papeeta/core/theme/theme.dart';

/// Avatar de usuario.
///
/// Las iniciales son el caso principal, no el fallback: el modelo `User` de
/// `core/` — el que traen `Recipe.author` y los miembros de un grupo — no tiene
/// foto de perfil. Solo el usuario logueado (el `User` de `auth/`) la tiene.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.size = 40,
  });

  /// Nombre del que se derivan las iniciales.
  final String name;

  /// Solo para el usuario logueado. Si es `null`, se muestran las iniciales.
  final String? imageUrl;

  final double size;

  /// Hasta dos iniciales: "Sofía Fernández" → "SF", "sofia" → "S".
  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts[1][0]).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _initialsCircle(colors),
          errorWidget: (_, __, ___) => _initialsCircle(colors),
        ),
      );
    }

    return _initialsCircle(colors);
  }

  Widget _initialsCircle(ColorScheme colors) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.secondaryContainer,
        shape: BoxShape.circle,
      ),
      child: Text(
        _initials,
        style: AppTypography.label.copyWith(
          // La inicial escala con el avatar: ~36% del diámetro.
          fontSize: size * 0.36,
          fontWeight: FontWeight.w600,
          color: colors.brightness == Brightness.light
              ? AppColors.onSecondaryContainerStrong
              : colors.onSecondaryContainer,
        ),
      ),
    );
  }
}

/// Avatar de marca: el ícono de Papeeta sobre el púrpura.
class AppBrandAvatar extends StatelessWidget {
  const AppBrandAvatar({super.key, this.size = 52});

  final double size;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: colors.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.restaurant_menu_rounded,
        size: size * 0.5,
        color: colors.onPrimary,
      ),
    );
  }
}
