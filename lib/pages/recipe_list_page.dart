import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/bloc/category/category_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:papeeta/widgets/widgets.dart';

import 'package:papeeta/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';

class RecipeListPage extends StatefulWidget {
  const RecipeListPage({super.key});

  @override
  State<RecipeListPage> createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();

    // Esperamos a que el widget se monte completamente antes de acceder al context
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final categoryBloc = context.read<CategoryBloc>();
      final selectedCategory = categoryBloc.state.selectedCategory;

      if (selectedCategory != null) {
        context.read<RecipeBloc>().add(
          LoadRecipesByCategory(selectedCategory.id!),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CategoryBloc, CategoryState>(
      builder: (context, categoryState) {
        final category = categoryState.selectedCategory!;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              category.name,
              style: const TextStyle(color: Colors.white),
            ),
            elevation: 1,
            backgroundColor: Theme.of(context).colorScheme.onPrimary,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            automaticallyImplyLeading: false,
          ),
          body: BlocBuilder<RecipeBloc, RecipeState>(
            builder: (context, state) {
              if (state is RecipeLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              if (state is RecipeListLoaded) {
                if (state.recipes.isEmpty) {
                  return const Center(
                    child: Text(
                      'No se encontraron recetas para esta categoría.',
                    ),
                  );
                }

                return SmartRefresher(
                  controller: _refreshController,
                  enablePullDown: true,
                  onRefresh: _recargar,
                  child: _mainView(state.recipes),
                );
              }

              if (state is RecipeError) {
                return Center(child: Text(state.message));
              }

              return const SizedBox();
            },
          ),
        );
      },
    );
  }

  Widget _mainView(List<Recipe> recipes) {
    return ListView(
      padding: const EdgeInsets.only(top: 20),
      physics: const BouncingScrollPhysics(),
      children: [RecipeList(recipes: recipes)],
    );
  }

  _recargar() async {
    final category = context.read<CategoryBloc>().state.selectedCategory;
    if (category != null) {
      context.read<RecipeBloc>().add(LoadRecipesByCategory(category.id!));
    }
    _refreshController.refreshCompleted();
  }
}
