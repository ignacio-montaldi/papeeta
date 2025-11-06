import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import 'package:papeeta/bloc/blocs.dart';
import 'package:papeeta/models/models.dart';
import 'package:papeeta/widgets/widgets.dart';

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
      final categoryBloc = BlocProvider.of<CategoryBloc>(
        context,
        listen: false,
      );
      final recipeBloc = BlocProvider.of<RecipeBloc>(context, listen: false);

      final selectedCategory = categoryBloc.state.selectedCategory;

      if (selectedCategory != null) {
        recipeBloc.getRecipesByCategory(selectedCategory.id!);
      } else {
        debugPrint("⚠️ No hay categoría seleccionada en el CategoryBloc");
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
            builder: (context, recipeState) {
              final recipes = recipeState.recipesByCategory;

              if (recipes == null) {
                return const Center(child: CircularProgressIndicator());
              }

              if (recipes.isEmpty) {
                return const Center(
                  child: Text('No se encontraron recetas para esta categoría.'),
                );
              }
              return SmartRefresher(
                controller: _refreshController,
                enablePullDown: true,
                onRefresh: _recargar,
                child: _mainView(recipes),
              );
            },
          ),
        );
      },
    );
  }

  Widget _mainView(List<RecipeModel> recipes) {
    return ListView(
      padding: const EdgeInsets.only(top: 20),
      physics: BouncingScrollPhysics(),
      children: [RecipeList(recipes: recipes)],
    );
  }

  _recargar() async {
    await Future.delayed(Duration(seconds: 1));
    _refreshController.refreshCompleted();
  }
}
