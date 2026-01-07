import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/bloc/blocs.dart';
import 'package:papeeta/pages/pages.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  'home': (_) => const HomePage(),
  'login': (_) => const LoginPage(),
  'register': (_) => const RegisterPage(),
  'loading': (_) => const LoadingPage(),
  'recipe': (_) => const RecipePage(),
  'categories': (_) => CategoriesPage(),
  'recipeList': (_) => const RecipeListPage(),
  'addRecipe': (_) => BlocProvider(
    create: (_) => RecipeFormCubit(),
    child: const AddRecipePage(),
  ),
};
