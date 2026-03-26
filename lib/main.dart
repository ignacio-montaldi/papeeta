import 'package:flutter/material.dart';
import 'package:papeeta/core/di/injection.dart';
import 'package:papeeta/features/categories/presentation/bloc/category_bloc.dart';
import 'package:papeeta/features/recipes/presentation/bloc/recipe_bloc.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:papeeta/bloc/blocs.dart' as old_blocs;
import 'package:papeeta/routes/routes.dart';

void main() {
  setupDependencies();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(create: (_) => getIt<AuthBloc>()),
        BlocProvider<old_blocs.IngredientBloc>(
          create: (_) => getIt<old_blocs.IngredientBloc>(),
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
    );
  }
}
