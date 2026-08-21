import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:papeeta/core/domain/entities/category.dart';
import 'package:papeeta/core/theme/theme.dart';
import 'package:papeeta/features/categories/presentation/bloc/category_bloc.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';
import 'package:papeeta/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:papeeta/widgets/custom_drawer.dart';
import 'package:papeeta/widgets/ds/ds.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RefreshController _refreshController = RefreshController();

  /// Última lista conocida.
  ///
  /// El bloc es compartido con el detalle: al abrir una receta pasa por
  /// `RecipeDetailLoading`, que no transporta lista, y sin cachearla el Home
  /// mostraba el estado vacío debajo de la pantalla empujada.
  List<Recipe>? _recipes;

  /// La lista que transporta el estado, si transporta alguna.
  List<Recipe>? _listaDe(RecipeState state) {
    return switch (state) {
      RecipeListLoaded(:final recipes) => recipes,
      RecipeDetailLoaded(:final recipes) => recipes,
      _ => null,
    };
  }

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _cargar() {
    context.read<RecipeBloc>().add(const LoadHomeRecipes());
    context.read<CategoryBloc>().add(LoadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Papeeta')),
      drawer: const CustomDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/addRecipe'),
        tooltip: 'Agregar receta',
        child: const Icon(Icons.post_add_rounded),
      ),
      body: BlocListener<RecipeBloc, RecipeState>(
        listener: (context, state) {
          final lista = _listaDe(state);
          if (lista != null) setState(() => _recipes = lista);

          switch (state) {
            case RecipeListLoaded():
              _refreshController.refreshCompleted();
            case RecipeError():
              _refreshController.refreshFailed();
            default:
              break;
          }
        },
        child: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, categoryState) {
            return BlocBuilder<RecipeBloc, RecipeState>(
              builder: (context, recipeState) {
                return _body(categoryState, recipeState);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _body(CategoryState categoryState, RecipeState recipeState) {
    final recipes = _listaDe(recipeState) ?? _recipes;

    if (categoryState is CategoryError) {
      return ErrorStateView(
        title: 'No pudimos cargar las categorías',
        message: 'Revisá tu conexión e intentá de nuevo.',
        onRetry: _cargar,
      );
    }

    // Un error mientras ya hay lista suele venir del detalle que se acaba de
    // abrir, no del Home: se sigue mostrando el contenido.
    if (recipeState is RecipeError && recipes == null) {
      return ErrorStateView(
        title: 'No pudimos cargar las recetas',
        message: 'Revisá tu conexión e intentá de nuevo.',
        onRetry: _cargar,
      );
    }

    if (categoryState is! CategoryLoaded || recipes == null) {
      return const _HomeSkeleton();
    }

    final categories = categoryState.categories;

    if (recipes.isEmpty && categories.isEmpty) {
      return EmptyStateView(
        icon: Icons.restaurant_menu_rounded,
        title: 'Todavía no hay recetas',
        message: 'Agregá tu primera receta y empezá a armar tu recetario.',
        actionLabel: 'Agregar receta',
        actionIcon: Icons.post_add_rounded,
        onAction: () => context.push('/addRecipe'),
      );
    }

    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      onRefresh: _cargar,
      physics: const BouncingScrollPhysics(),
      child: CustomScrollView(
        slivers: [
          if (categories.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.lg),
                child: _CategoriesRail(categories: categories),
              ),
            ),
          if (recipes.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyStateView(
                icon: Icons.restaurant_menu_rounded,
                title: 'Todavía no hay recetas',
                message:
                    'Agregá tu primera receta y empezá a armar tu recetario.',
                actionLabel: 'Agregar receta',
                actionIcon: Icons.post_add_rounded,
                onAction: () => context.push('/addRecipe'),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.xxxl * 2,
              ),
              sliver: SliverList.separated(
                itemCount: recipes.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.lg),
                itemBuilder: (context, index) {
                  final recipe = recipes[index];
                  return RecipeCard(
                    recipe: recipe,
                    onTap: () => context.push('/recipe/${recipe.id}'),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

/// Carrusel de categorías. Orden estable: el diseño retira el shuffle aleatorio
/// que impedía la memoria visual entre sesiones.
class _CategoriesRail extends StatelessWidget {
  const _CategoriesRail({required this.categories});

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    // El grupo 2 queda fuera del rail, como en la versión anterior.
    final visible = categories.where((c) => c.groupId != 2).take(8).toList();

    return SizedBox(
      height: 104,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        itemCount: visible.length + 1,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.lg),
        itemBuilder: (context, index) {
          if (index == visible.length) {
            return _CategoryItem(
              label: 'Ver todas',
              icon: Icons.arrow_forward_rounded,
              onTap: () => context.push('/categories'),
            );
          }

          final category = visible[index];
          return _CategoryItem(
            label: category.name,
            imageUrl: category.imageUrl,
            onTap: () {
              context.read<RecipeBloc>().add(LoadRecipesByCategory(category.id));
              context.push('/categories/${category.id}', extra: category);
            },
          );
        },
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.label,
    required this.onTap,
    this.imageUrl,
    this.icon,
  });

  final String label;
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
            Container(
              width: AppSizes.categoryCircle,
              height: AppSizes.categoryCircle,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                shape: BoxShape.circle,
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
                          size: 26,
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
                color: colors.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

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
          const SizedBox(height: AppSpacing.sm),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              children: [
                RecipeCardSkeleton(),
                SizedBox(height: AppSpacing.lg),
                RecipeCardSkeleton(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
