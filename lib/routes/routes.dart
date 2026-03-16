import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/bloc/blocs.dart';
import 'package:papeeta/core/di/injection.dart';
import 'package:papeeta/core/domain/entities/category.dart';
import 'package:papeeta/features/recipes/domain/repositories/recipes_repository.dart'
    as recipes_domain;
import 'package:papeeta/pages/pages.dart';

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
  'recipeList': (context) {
    final category =
        ModalRoute.of(context)!.settings.arguments! as Category;
    return RecipeListPage(category: category);
  },
  'addRecipe': (_) => BlocProvider(
    create: (context) =>
        RecipeFormCubit(getIt<recipes_domain.RecipesRepository>()),
    child: const AddRecipePage(),
  ),
};
