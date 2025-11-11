import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/models/models.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:papeeta/bloc/blocs.dart';
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
    final recipeBloc = context.read<RecipeBloc>();
    final categoryBloc = context.read<CategoryBloc>();

    if (recipeBloc.state.recipes == null || recipeBloc.state.recipes!.isEmpty) {
      recipeBloc.add(LoadHomeRecipes());
    }

    if (categoryBloc.state.categories == null ||
        categoryBloc.state.categories!.isEmpty) {
      categoryBloc.add(LoadHomeCategoriesList());
    }
  }

  void _onRefresh() {
    context.read<RecipeBloc>().add(LoadHomeRecipes());
    context.read<CategoryBloc>().add(LoadHomeCategoriesList());
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
      body: MultiBlocListener(
        listeners: [
          // 🔹 Cuando cambian recetas o categorías, se completa el refresh
          BlocListener<RecipeBloc, RecipeState>(
            listener: (context, state) {
              if (state.recipes != null) {
                _refreshController.refreshCompleted();
              }
            },
          ),
          BlocListener<CategoryBloc, CategoryState>(
            listener: (context, state) {
              if (state.categories != null) {
                _refreshController.refreshCompleted();
              }
            },
          ),
        ],
        child: BlocBuilder<RecipeBloc, RecipeState>(
          builder: (context, recipeState) {
            return BlocBuilder<CategoryBloc, CategoryState>(
              builder: (context, categoryState) {
                final recipes = recipeState.recipes;
                final categories = categoryState.categories;

                if (recipes == null || categories == null) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (recipes.isEmpty && categories.isEmpty) {
                  return const Center(
                    child: Text('No se encontraron recetas ni categorías.'),
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
  final List<CategoryModel> categories;

  @override
  State<_CategoriesList> createState() => _CategoriesListState();
}

class _CategoriesListState extends State<_CategoriesList> {
  late List<CategoryModel> limitedCategories;

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

  final CategoryModel? category;
  final String label;
  final String? imageUrl;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final categoryBloc = context.read<CategoryBloc>();
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            if (imageUrl != null) {
              categoryBloc.add(SelectedCategory(category: category!));
              Navigator.pushNamed(context, 'recipeList');
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
              child: imageUrl != null
                  ? MyImageWidget(
                      image: MyImageModel(url: imageUrl!),
                      width: 45,
                      height: 45,
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
