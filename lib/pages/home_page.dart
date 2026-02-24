import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:papeeta/core/domain/entities/category.dart';
import 'package:papeeta/features/categories/presentation/bloc/category_bloc.dart';
import 'package:papeeta/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:papeeta/services/auth_service.dart';
import 'package:papeeta/widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    context.read<RecipeBloc>().add(const LoadRecipes());
    context.read<CategoryBloc>().add(LoadCategories());
  }

  void _onRefresh() {
    context.read<RecipeBloc>().add(const LoadRecipes());
    context.read<CategoryBloc>().add(LoadCategories());
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final usuario = authService.usuario;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          usuario.nombre,
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      drawer: CustomDrawer(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, 'addRecipe');
        },
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        child: Icon(Icons.post_add, color: Colors.white),
      ),
      body: BlocListener<RecipeBloc, RecipeState>(
        listener: (context, recipeState) {
          if (recipeState is RecipeListLoaded || recipeState is RecipeError) {
            if (recipeState is RecipeError) {
              _refreshController.refreshFailed();
            } else {
              _refreshController.refreshCompleted();
            }
          }
        },
        child: BlocBuilder<CategoryBloc, CategoryState>(
          builder: (context, categoryState) {
            return BlocBuilder<RecipeBloc, RecipeState>(
              builder: (context, recipeState) {
                if (categoryState is CategoryLoading ||
                    recipeState is RecipeLoading ||
                    categoryState is CategoryInitial ||
                    recipeState is RecipeInitial) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (categoryState is CategoryError) {
                  return Center(child: Text(categoryState.message));
                }

                if (recipeState is RecipeError) {
                  return Center(child: Text(recipeState.message));
                }

                if (categoryState is CategoryLoaded && recipeState is RecipeListLoaded) {
                  final categories = categoryState.categories;
                  final recipes = recipeState.recipes;

                  if (categories.isEmpty && recipes.isEmpty) {
                    return const Center(
                      child: Text('No se encontraron recetas ni categorías'),
                    );
                  }

                  return SmartRefresher(
                    controller: _refreshController,
                    enablePullDown: true,
                    onRefresh: _onRefresh,
                    physics: const BouncingScrollPhysics(),
                    child: ListView(
                      padding: const EdgeInsets.only(top: 20),
                      children: [
                        if (categories.isNotEmpty)
                          _CategoriesList(categories: categories),
                        const SizedBox(height: 20),
                        if (recipes.isNotEmpty)
                          RecipeList(recipes: recipes)
                        else
                          const Center(child: Text('No se encontraron recetas.')),
                      ],
                    ),
                  );
                }

                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }
}

class _CategoriesList extends StatefulWidget {
  const _CategoriesList({required this.categories});
  final List<Category> categories;

  @override
  State<_CategoriesList> createState() => _CategoriesListState();
}

class _CategoriesListState extends State<_CategoriesList> {
  late List<Category> limitedCategories;

  @override
  void initState() {
    super.initState();
    _shuffleCategories();
  }

  @override
  void didUpdateWidget(covariant _CategoriesList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.categories != widget.categories) {
      _shuffleCategories();
    }
  }

  void _shuffleCategories() {
    final filtered = widget.categories.where((c) => c.groupId != 2).toList();
    filtered.shuffle();
    limitedCategories = filtered.take(8).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 114,
      child: ListView.builder(
        itemCount: limitedCategories.length + 1,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemBuilder: (context, index) {
          if (index < limitedCategories.length) {
            return _CategoryItem(
              category: limitedCategories[index],
              label: limitedCategories[index].name,
              imageUrl: limitedCategories[index].imageUrl,
            );
          }

          return const _CategoryItem(
            label: 'Ver todas',
            icon: Icons.arrow_forward,
          );
        },
      ),
    );
  }
}

class _CategoryItem extends StatelessWidget {
  const _CategoryItem({
    required this.label,
    this.imageUrl,
    this.icon,
    this.category,
  });

  final Category? category;
  final String label;
  final String? imageUrl;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (category != null) {
              context.read<RecipeBloc>().add(
                LoadRecipesByCategory(category!.id),
              );

              Navigator.pushNamed(context, 'recipeList', arguments: category);
            } else {
              Navigator.pushNamed(context, 'categories');
            }
          },
          child: Container(
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 3,
                  spreadRadius: 0.3,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 35,
              backgroundColor: Colors.white,
              child: imageUrl != null && imageUrl!.isNotEmpty
                  ? ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: imageUrl!,
                        fit: BoxFit.cover,
                        width: 45,
                        height: 45,
                        placeholder: (context, url) => const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.broken_image, color: Colors.grey),
                      ),
                    )
                  : Icon(icon, color: Colors.black54, size: 30),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: 88,
          child: Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}
