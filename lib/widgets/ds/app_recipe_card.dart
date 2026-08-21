import 'package:flutter/material.dart';

import 'package:papeeta/core/theme/theme.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';
import 'package:papeeta/widgets/my_image_widget.dart';
import 'app_avatar.dart';

/// Tarjeta de receta del sistema.
///
/// La foto domina (relación 16:11); debajo van las categorías en overline, el
/// título y la fila de autor.
///
/// [onFavoriteToggle] y [metadata] quedan opcionales a propósito: el diseño los
/// muestra, pero el modelo `Recipe` no tiene ni favoritos ni tiempo de cocción.
/// Mientras no exista ese dato en la API, no se pasan y la tarjeta no los
/// dibuja, en vez de mostrar un valor inventado.
class RecipeCard extends StatelessWidget {
  const RecipeCard({
    super.key,
    required this.recipe,
    required this.onTap,
    this.isFavorite,
    this.onFavoriteToggle,
    this.metadata,
  });

  final Recipe recipe;
  final VoidCallback onTap;

  final bool? isFavorite;
  final VoidCallback? onFavoriteToggle;

  /// Dato extra en la fila del autor, p. ej. "45 min".
  final String? metadata;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final categories = recipe.categories.map((c) => c.name).join(' · ');
    final author = recipe.author;
    final authorName = author?.alias ?? author?.nombreUsuario;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: AppRadius.lgAll,
          boxShadow: AppElevation.e1,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: AppSizes.recipeCardImageRatio,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  if (recipe.images.isNotEmpty)
                    MyImageWidget(
                      image: recipe.images.first,
                      fit: BoxFit.cover,
                    )
                  else
                    _ImageFallback(),
                  if (onFavoriteToggle != null)
                    Positioned(
                      top: 9,
                      right: 9,
                      child: _FavoriteButton(
                        isFavorite: isFavorite ?? false,
                        onTap: onFavoriteToggle!,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (categories.isNotEmpty)
                    Text(
                      categories.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.overline.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xs + 1),
                  Text(
                    recipe.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.subtitle.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  if (authorName != null || metadata != null) ...[
                    const SizedBox(height: AppSpacing.md - 1),
                    Row(
                      children: [
                        if (authorName != null) ...[
                          AppAvatar(name: authorName, size: 26),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Expanded(
                          child: Text(
                            [
                              if (authorName != null) authorName,
                              if (metadata != null) metadata!,
                            ].join(' · '),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.label.copyWith(
                              fontWeight: FontWeight.w400,
                              color: colors.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return ColoredBox(
      color: colors.primaryContainer,
      child: Center(
        child: Icon(
          Icons.restaurant_menu_rounded,
          size: 36,
          color: context.semantic.emptyIcon,
        ),
      ),
    );
  }
}

class _FavoriteButton extends StatelessWidget {
  const _FavoriteButton({required this.isFavorite, required this.onTap});

  final bool isFavorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: colors.surface.withValues(alpha: 0.92),
          shape: BoxShape.circle,
        ),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          size: 18,
          color: colors.primary,
        ),
      ),
    );
  }
}
