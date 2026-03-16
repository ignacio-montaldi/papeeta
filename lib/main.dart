import 'package:flutter/material.dart';
import 'package:papeeta/core/di/injection.dart';
import 'package:papeeta/features/categories/presentation/bloc/category_bloc.dart';
import 'package:papeeta/features/recipes/presentation/bloc/recipe_bloc.dart';

import 'package:provider/provider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:papeeta/bloc/blocs.dart' as old_blocs;
import 'package:papeeta/routes/routes.dart';
import 'package:papeeta/services/services.dart';

void main() {
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthService())],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => old_blocs.IngredientBloc(
              ingredientService: IngredientService(),
            ),
          ),
          BlocProvider<RecipeBloc>(create: (_) => getIt<RecipeBloc>()),
          BlocProvider<CategoryBloc>(create: (_) => getIt<CategoryBloc>()),
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
