import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/core/di/injection.dart';
import 'package:papeeta/core/router/app_router.dart';
import 'package:papeeta/core/theme/theme.dart';
import 'package:papeeta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:papeeta/features/categories/presentation/bloc/category_bloc.dart';
import 'package:papeeta/features/ingredients/presentation/bloc/ingredient_bloc.dart';
import 'package:papeeta/features/recipes/presentation/bloc/recipe_bloc.dart';

void main() {
  if (!getIt.isRegistered<Dio>()) {
    setupDependencies();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authBloc = getIt<AuthBloc>();
    final appRouter = AppRouter(authBloc: authBloc);

    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>.value(value: authBloc),
        BlocProvider<IngredientBloc>(create: (_) => getIt<IngredientBloc>()),
        BlocProvider<RecipeBloc>(create: (_) => getIt<RecipeBloc>()),
        BlocProvider<CategoryBloc>(create: (_) => getIt<CategoryBloc>()),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        title: 'Papeeta',
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        routerConfig: appRouter.router,
      ),
    );
  }
}
