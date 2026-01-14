import 'package:flutter/material.dart';
import 'package:papeeta/repositories/repositories.dart';

import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:papeeta/bloc/blocs.dart';
import 'package:papeeta/routes/routes.dart';
import 'package:papeeta/services/services.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        RepositoryProvider<RecipesRepository>(
          create: (_) => RecipesRepositoryImpl(RecipesService()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => RecipeBloc(recipesService: RecipesService()),
          ),
          BlocProvider(
            create: (context) =>
                CategoryBloc(categoriesService: CategoriesService()),
          ),
          BlocProvider(
            create: (context) =>
                IngredientBloc(ingredientService: IngredientService()),
          ),
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Papeeta',
          initialRoute: 'loading',
          // theme: ThemeData(fontFamily: 'Inter'),
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Color(0xFF3C1642),
              onPrimary: Color(0xFF3C1642),
              onSecondary: Color(0XFF086375),
            ),
            fontFamily: 'Inter',
          ),
          routes: appRoutes,
        ),
      ),
    );
  }
}
