import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/bloc/blocs.dart';
import 'package:papeeta/pages/pages.dart';
import 'package:papeeta/repositories/repositories.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  'home': (_) => const HomePage(),
  'login': (_) => const LoginPage(),
  'register': (_) => const RegisterPage(),
  'loading': (_) => const LoadingPage(),
  'recipe': (context) {
    final recipeId = ModalRoute.of(context)!.settings.arguments as int;
    return RecipePage(recipeId: recipeId);
  },
  'categories': (_) => CategoriesPage(),
  'recipeList': (_) => const RecipeListPage(),
  'addRecipe': (_) => BlocProvider(
    create: (context) => RecipeFormCubit(context.read<RecipesRepository>()),
    child: const AddRecipePage(),
  ),
};
