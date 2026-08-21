import 'package:flutter/material.dart';

import 'package:papeeta/core/domain/entities/recipe_share_group.dart';
import 'package:papeeta/core/theme/theme.dart';
import 'package:papeeta/widgets/my_image_widget.dart';
import 'app_chip.dart';

/// Tarjeta de grupo: portada, nombre, descripción y conteos.
class GroupCard extends StatelessWidget {
  const GroupCard({
    super.key,
    required this.group,
    required this.onTap,
  });

  final RecipeShareGroup group;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: AppRadius.lgAll,
          border: Border.all(color: context.semantic.divider),
          boxShadow: AppElevation.e1,
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: AppSizes.groupCoverHeight,
              width: double.infinity,
              child: group.images.isNotEmpty
                  ? MyImageWidget(
                      image: group.images.first,
                      fit: BoxFit.cover,
                    )
                  : ColoredBox(
                      color: colors.primaryContainer,
                      child: Center(
                        child: Icon(
                          Icons.group_rounded,
                          size: 40,
                          color: context.semantic.emptyIcon,
                        ),
                      ),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    group.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.subtitle.copyWith(
                      color: colors.onSurface,
                    ),
                  ),
                  if (group.description != null &&
                      group.description!.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      group.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.label.copyWith(
                        fontWeight: FontWeight.w400,
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                  const SizedBox(height: 13),
                  Row(
                    children: [
                      AppInfoChip(
                        icon: Icons.group_rounded,
                        label: '${group.members.length} miembros',
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      AppInfoChip(
                        icon: Icons.restaurant_menu_rounded,
                        label: '${group.recipes.length} recetas',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
