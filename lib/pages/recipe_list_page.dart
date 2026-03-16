import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/core/domain/entities/category.dart';
import 'package:papeeta/features/recipes/domain/entities/recipe.dart';
import 'package:papeeta/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:papeeta/widgets/widgets.dart';

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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecipeBloc>().add(
            LoadRecipesByCategory(widget.category.id),
          );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.category.name,
          style: const TextStyle(color: Colors.white),
        ),
        elevation: 1,
        backgroundColor: Theme.of(context).colorScheme.onPrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.read<RecipeBloc>().add(const RestoreHomeRecipes());
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
      ),
      body: BlocBuilder<RecipeBloc, RecipeState>(
        builder: (context, state) {
          if (state is RecipeListLoading || state is RecipeInitial) {
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

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _mainView(List<Recipe> recipes) {
    return ListView(
      padding: const EdgeInsets.only(top: 20),
      physics: const BouncingScrollPhysics(),
      children: [RecipeList(recipes: recipes)],
    );
  }

  void _recargar() {
    context.read<RecipeBloc>().add(LoadRecipesByCategory(widget.category.id));
    _refreshController.refreshCompleted();
  }
}
