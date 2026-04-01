import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:papeeta/core/domain/entities/category.dart';
import 'package:papeeta/core/di/injection.dart';
import 'package:papeeta/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:papeeta/features/recipes/domain/repositories/recipes_repository.dart'
    as recipes_domain;
import 'package:papeeta/features/recipes/presentation/bloc/recipe_form/recipe_form_cubit.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_bloc.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_event.dart';
import 'package:papeeta/features/groups/presentation/pages/groups_page.dart';
import 'package:papeeta/features/groups/presentation/pages/group_detail_page.dart';
import 'package:papeeta/pages/pages.dart';

class AppRouter {
  final AuthBloc authBloc;

  AppRouter({required this.authBloc});

  late final GoRouter router = GoRouter(
    initialLocation: '/loading',
    debugLogDiagnostics: true,
    refreshListenable: GoRouterRefreshStream(authBloc.stream),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isAuthenticated = authState is Authenticated;
      final isInitialLoading = authState is AuthInitial;
      final isOnAuthPage =
          state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/loading';

      if (isInitialLoading) {
        return state.matchedLocation == '/loading' ? null : '/loading';
      }

      if (!isAuthenticated && !isOnAuthPage) {
        return '/login';
      }

      if (isAuthenticated && isOnAuthPage) {
        return '/';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/loading',
        builder: (context, state) => const LoadingPage(),
      ),
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),
      GoRoute(path: '/', builder: (context, state) => const HomePage()),
      GoRoute(
        path: '/recipe/:id',
        builder: (context, state) {
          final recipeId = int.tryParse(state.pathParameters['id'] ?? '');
          return RecipePage(recipeId: recipeId);
        },
      ),
      GoRoute(
        path: '/categories',
        builder: (context, state) => const CategoriesPage(),
      ),
      GoRoute(
        path: '/categories/:categoryId',
        builder: (context, state) {
          final category = state.extra as Category?;
          if (category == null) {
            return const HomePage();
          }
          return RecipeListPage(category: category);
        },
      ),
      GoRoute(
        path: '/addRecipe',
        builder: (context, state) {
          return BlocProvider(
            create: (context) =>
                RecipeFormCubit(getIt<recipes_domain.RecipesRepository>()),
            child: const AddRecipePage(),
          );
        },
      ),
      GoRoute(
        path: '/preview',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>?;
          final recipe = extra?['recipe'];
          final images = extra?['images'] as List<dynamic>?;
          return RecipePage(
            previewRecipe: recipe,
            previewImages: images?.cast<File>() ?? [],
          );
        },
      ),
      GoRoute(
        path: '/groups',
        builder: (context, state) => BlocProvider(
          create: (context) => getIt<GroupsBloc>()..add(LoadMyGroups()),
          child: const GroupsPage(),
        ),
      ),
      GoRoute(
        path: '/groups/:id',
        builder: (context, state) {
          final groupId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return BlocProvider(
            create: (context) =>
                getIt<GroupsBloc>()..add(LoadGroupDetail(groupId)),
            child: GroupDetailPage(groupId: groupId),
          );
        },
      ),
    ],
  );
}

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) {
      notifyListeners();
    });
  }

  late final dynamic _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
