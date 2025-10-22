import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:papeeta/bloc/recipe/recipe_bloc.dart';

import 'package:provider/provider.dart';

import 'package:papeeta/routes/routes.dart';

import 'package:papeeta/services/auth_service.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => AuthService())],
      child: MultiBlocProvider(
        providers: [BlocProvider(create: (context) => RecipeBloc())],
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
