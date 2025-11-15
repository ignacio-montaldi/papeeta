import 'package:flutter/material.dart';
import 'package:papeeta/pages/pages.dart';

final Map<String, Widget Function(BuildContext)> appRoutes = {
  'home': (_) => const HomePage(),
  'login': (_) => const LoginPage(),
  'register': (_) => const RegisterPage(),
  'loading': (_) => const LoadingPage(),
  'recipe': (_) => const RecipePage(),
  'categories': (_) => CategoriesPage(),
  'recipeList': (_) => const RecipeListPage(),
  'addRecipe': (_) => const AddRecipePage(),
};
