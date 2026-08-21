import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:papeeta/core/domain/entities/category.dart';
import 'package:papeeta/core/domain/entities/category_group.dart';
import 'package:papeeta/core/theme/theme.dart';
import 'package:papeeta/features/categories/presentation/bloc/category_bloc.dart';
import 'package:papeeta/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:papeeta/widgets/ds/ds.dart';

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  int? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    context.read<CategoryBloc>().add(LoadCategories());
  }

  void _cargar() => context.read<CategoryBloc>().add(LoadCategories());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Categorías'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocBuilder<CategoryBloc, CategoryState>(
        builder: (context, state) {
          if (state is CategoryInitial || state is CategoryLoading) {
            return const _CategoriesSkeleton();
          }

          if (state is CategoryError) {
            return ErrorStateView(
              title: 'No pudimos cargar las categorías',
              message: 'Revisá tu conexión e intentá de nuevo.',
              onRetry: _cargar,
            );
          }

          if (state is! CategoryLoaded) return const SizedBox.shrink();

          final categories = state.categories;
          final groups = state.groups;

          if (categories.isEmpty && groups.isEmpty) {
            return EmptyStateView(
              icon: Icons.category_rounded,
              title: 'Todavía no hay categorías',
              message: 'Cuando se carguen categorías, van a aparecer acá.',
              actionLabel: 'Reintentar',
              actionIcon: Icons.refresh_rounded,
              onAction: _cargar,
            );
          }

          final filtered = _selectedGroupId == null
              ? categories
              : categories
                  .where((c) =>
                      c.groupId == _selectedGroupId ||
                      c.group?.id == _selectedGroupId)
                  .toList();

          return CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              if (groups.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: _GroupRail(
                      groups: groups,
                      selectedGroupId: _selectedGroupId,
                      onSelected: (id) => setState(() => _selectedGroupId = id),
                    ),
                  ),
                ),
              if (filtered.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: EmptyStateView(
                    icon: Icons.filter_alt_off_rounded,
                    title: 'Sin categorías en este grupo',
                    message: 'Probá con otro grupo o mirá todas.',
                    actionLabel: 'Ver todas',
                    onAction: () => setState(() => _selectedGroupId = null),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.xxl,
                  ),
                  sliver: SliverGrid.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.lg,
                      crossAxisSpacing: AppSpacing.lg,
                      mainAxisExtent: 150,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final category = filtered[index];
                      return _CategoryTile(
                        category: category,
                        onTap: () {
                          context
                              .read<RecipeBloc>()
                              .add(LoadRecipesByCategory(category.id));
                          context.push(
                            '/categories/${category.id}',
                            extra: category,
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({required this.category, required this.onTap});

  final Category category;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasImage =
        category.imageUrl != null && category.imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: colors.surfaceContainer,
          borderRadius: AppRadius.lgAll,
          boxShadow: AppElevation.e1,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: hasImage
                  ? CachedNetworkImage(
                      imageUrl: category.imageUrl!,
                      fit: BoxFit.contain,
                      errorWidget: (_, __, ___) => Icon(
                        Icons.restaurant_menu_rounded,
                        size: 36,
                        color: context.semantic.emptyIcon,
                      ),
                    )
                  : Icon(
                      Icons.restaurant_menu_rounded,
                      size: 36,
                      color: context.semantic.emptyIcon,
                    ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              category.name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: colors.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Filtro horizontal por grupo de categorías.
class _GroupRail extends StatelessWidget {
  const _GroupRail({
    required this.groups,
    required this.selectedGroupId,
    required this.onSelected,
  });

  final List<CategoryGroup> groups;
  final int? selectedGroupId;
  final ValueChanged<int?> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: groups.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.lg),
        itemBuilder: (context, index) {
          if (index == 0) {
            return _GroupItem(
              label: 'Todas',
              icon: Icons.restaurant_menu_rounded,
              selected: selectedGroupId == null,
              onTap: () => onSelected(null),
            );
          }

          final group = groups[index - 1];
          return _GroupItem(
            label: group.name,
            imageUrl: group.imageUrl,
            selected: selectedGroupId == group.id,
            onTap: () => onSelected(group.id),
          );
        },
      ),
    );
  }
}

class _GroupItem extends StatelessWidget {
  const _GroupItem({
    required this.label,
    required this.selected,
    required this.onTap,
    this.imageUrl,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final String? imageUrl;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 72,
        child: Column(
          children: [
            AnimatedContainer(
              duration: AppMotion.fast,
              width: AppSizes.categoryCircle,
              height: AppSizes.categoryCircle,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
                border: selected
                    ? Border.all(color: colors.primary, width: 2.5)
                    : null,
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImage
                  ? Padding(
                      padding: const EdgeInsets.all(AppSpacing.sm + 2),
                      child: CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.contain,
                        errorWidget: (_, __, ___) => Icon(
                          Icons.restaurant_menu_rounded,
                          size: 24,
                          color: colors.primary,
                        ),
                      ),
                    )
                  : Icon(
                      icon ?? Icons.restaurant_menu_rounded,
                      size: 26,
                      color: colors.primary,
                    ),
            ),
            const SizedBox(height: 7),
            Text(
              label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.label.copyWith(
                fontSize: 11,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                color: selected ? colors.primary : colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CategoriesSkeleton extends StatelessWidget {
  const _CategoriesSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonized(
      child: ListView(
        padding: const EdgeInsets.only(top: AppSpacing.lg),
        physics: const NeverScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: 104,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              itemCount: 5,
              separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.lg),
              itemBuilder: (_, __) => const SizedBox(
                width: 72,
                child: Column(
                  children: [
                    SkeletonBox.circle(size: AppSizes.categoryCircle),
                    SizedBox(height: 7),
                    SkeletonBox.line(width: 44, height: 9),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: AppSpacing.lg,
              crossAxisSpacing: AppSpacing.lg,
              mainAxisExtent: 150,
            ),
            itemCount: 4,
            itemBuilder: (_, __) => const SkeletonBox(
              borderRadius: AppRadius.lgAll,
            ),
          ),
        ],
      ),
    );
  }
}
