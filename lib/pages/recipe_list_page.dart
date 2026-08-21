import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:papeeta/core/domain/entities/category.dart';
import 'package:papeeta/core/theme/theme.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';
import 'package:papeeta/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:papeeta/widgets/ds/ds.dart';

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key, required this.category});

  final Category category;

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  /// Última lista conocida.
  ///
  /// El bloc es compartido: al abrir una receta pasa a `RecipeDetailLoading` y
  /// después a `RecipeDetailLoaded`, y esta pantalla —que sigue montada abajo—
  /// se reconstruye con esos estados. Sin cachear la lista, al volver del
  /// detalle no había nada que dibujar y la pantalla quedaba en blanco.
  List<Recipe>? _recipes;

  /// La lista que transporta el estado, si transporta alguna.
  ///
  /// `RecipeDetailLoaded` arrastra la lista de la que salió justamente para que
  /// la pantalla de atrás pueda seguir mostrándola.
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  void _cargar() {
    context.read<RecipeBloc>().add(LoadRecipesByCategory(widget.category.id));
  }

  void _volver() {
    context.read<RecipeBloc>().add(const RestoreHomeRecipes());
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: _volver,
        ),
      ),
      body: BlocConsumer<RecipeBloc, RecipeState>(
        listener: (context, state) {
          final lista = _listaDe(state);
          if (lista != null) setState(() => _recipes = lista);
        },
        builder: (context, state) {
          final recipes = _listaDe(state) ?? _recipes;

          // Un error mientras ya tenemos lista suele venir del detalle, no de
          // acá: se sigue mostrando la lista en vez de tapar la pantalla.
          if (state is RecipeError && recipes == null) {
            return ErrorStateView(
              title: 'No pudimos cargar las recetas',
              message: 'Revisá tu conexión e intentá de nuevo.',
              onRetry: _cargar,
              onSecondary: _volver,
              secondaryLabel: 'Volver',
            );
          }

          if (recipes == null) return const _ListSkeleton();

          if (recipes.isEmpty) {
            return EmptyStateView(
              icon: Icons.restaurant_menu_rounded,
              title: 'Sin recetas en esta categoría',
              message: 'Todavía nadie cargó una receta de ${widget.category.name}.',
              actionLabel: 'Agregar receta',
              actionIcon: Icons.post_add_rounded,
              onAction: () => context.push('/addRecipe'),
            );
          }

          return SmartRefresher(
            controller: _refreshController,
            enablePullDown: true,
            onRefresh: () {
              _cargar();
              _refreshController.refreshCompleted();
            },
            physics: const BouncingScrollPhysics(),
            child: _RecipeList(recipes: recipes),
          );
        },
      ),
    );
  }
}

class _RecipeList extends StatelessWidget {
  const _RecipeList({required this.recipes});

  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xxl,
      ),
      itemCount: recipes.length,
      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.lg),
      itemBuilder: (context, index) {
        final recipe = recipes[index];
        return RecipeCard(
          recipe: recipe,
          onTap: () => context.push('/recipe/${recipe.id}'),
        );
      },
    );
  }
}

class _ListSkeleton extends StatelessWidget {
  const _ListSkeleton();

  @override
  Widget build(BuildContext context) {
    return Skeletonized(
      child: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          RecipeCardSkeleton(),
          SizedBox(height: AppSpacing.lg),
          RecipeCardSkeleton(),
        ],
      ),
    );
  }
}
