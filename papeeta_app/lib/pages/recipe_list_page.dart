import 'package:flutter/material.dart';
import 'package:papeeta/widgets/widgets.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

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
  Widget build(BuildContext context) {
    final String category = 'Mexicana';
    return Scaffold(
      appBar: AppBar(
        title: Text(category, style: const TextStyle(color: Colors.white)),
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
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        onRefresh: _recargar,
        child: _mainView(),
      ),
    );
  }

  Widget _mainView() {
    final recetas = [
      'Receta 1',
      'Receta 2',
      'Receta 3',
      'Receta 4',
      'Receta 5',
      'Receta 6',
      'Receta 7',
      'Receta 8',
    ];

    return ListView(
      padding: const EdgeInsets.only(top: 20),
      physics: BouncingScrollPhysics(),
      children: [RecipeList(recetas: recetas)],
    );
  }

  _recargar() async {
    await Future.delayed(Duration(seconds: 1));
    _refreshController.refreshCompleted();
  }
}
