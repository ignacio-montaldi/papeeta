import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/bloc/recipe/recipe_bloc.dart';

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
  final RefreshController _refreshController = RefreshController(
    initialRefresh: false,
  );

  @override
  void initState() {
    super.initState();
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
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      drawer: CustomDrawer(),
      body: SmartRefresher(
        controller: _refreshController,
        enablePullDown: true,
        onRefresh: _recargar,
        child: _MainView(),
      ),
    );
  }

  _recargar() async {
    await Future.delayed(Duration(seconds: 1));
    _refreshController.refreshCompleted();
  }
}

class _MainView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final recipesBloc = BlocProvider.of<RecipeBloc>(context);

    final Map<String, String> categories = {
      'Mexicana': 'mexicana',
      'Pastas': 'pastas',
      'Asiática': 'asiatica',
      'Entradas': 'entradas',
      'Carne Vacuna': 'carne',
      'Frutas': 'frutas',
    };
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
      children: [
        _CategoriesList(categories: categories),
        const SizedBox(height: 20),
        BlocBuilder<RecipeBloc, RecipeState>(
          // recipesBloc
          builder: (context, state) => RecipeList(recetas: recetas),
        ),
      ],
    );
  }
}

class _CategoriesList extends StatelessWidget {
  const _CategoriesList({required this.categories});

  final Map<String, String> categories;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        itemCount: categories.length + 1,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        separatorBuilder: (context, index) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          if (index < categories.length) {
            final categoryName = categories.keys.elementAt(index);
            final categoryImage = categories.values.elementAt(index);
            return _CategoryItem(
              label: categoryName,
              imagePath: 'images/categories/$categoryImage.png',
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
  const _CategoryItem({required this.label, this.imagePath, this.icon});
  final String label;
  final String? imagePath;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            imagePath != null
                ? Navigator.pushNamed(context, 'recipeList')
                : Navigator.pushNamed(context, 'categories');
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
              radius: 45,
              backgroundColor: Colors.white,
              child: imagePath != null
                  ? ClipOval(
                      child: Image.asset(
                        imagePath!,
                        fit: BoxFit.cover,
                        width: 90,
                        height: 90,
                      ),
                    )
                  : Icon(icon, color: Colors.black54, size: 30),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(height: 20, child: Text(label)),
      ],
    );
  }
}
