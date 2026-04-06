import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:papeeta/features/categories/data/datasources/categories_remote_datasource.dart';
import 'package:papeeta/features/categories/data/datasources/categories_remote_datasource_impl.dart';
import 'package:papeeta/features/categories/domain/repositories/category_repository.dart';
import 'package:papeeta/features/categories/data/repositories/category_repository_impl.dart';
import 'package:papeeta/features/categories/presentation/bloc/category_bloc.dart';
import 'package:papeeta/features/recipes/data/datasources/recipes_remote_datasource.dart';
import 'package:papeeta/features/recipes/data/datasources/recipes_remote_datasource_impl.dart';
import 'package:papeeta/features/recipes/domain/repositories/recipes_repository.dart';
import 'package:papeeta/features/recipes/data/repositories/recipes_repository_impl.dart';
import 'package:papeeta/features/recipes/presentation/bloc/recipe_bloc.dart';
import 'package:papeeta/global/enviroment.dart';
import 'package:papeeta/core/interceptor/papeeta_interceptor.dart';
import 'package:papeeta/features/ingredients/data/datasources/ingredients_remote_datasource.dart';
import 'package:papeeta/features/ingredients/data/datasources/ingredients_remote_datasource_impl.dart';
import 'package:papeeta/features/ingredients/domain/repositories/ingredient_repository.dart';
import 'package:papeeta/features/ingredients/data/repositories/ingredient_repository_impl.dart';
import 'package:papeeta/features/ingredients/presentation/bloc/ingredient_bloc.dart';
import 'package:papeeta/features/groups/data/datasources/groups_remote_datasource.dart';
import 'package:papeeta/features/groups/data/repositories/groups_repository_impl.dart';
import 'package:papeeta/features/groups/domain/repositories/groups_repository.dart';
import 'package:papeeta/features/groups/presentation/bloc/groups_bloc.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:papeeta/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:papeeta/features/auth/data/datasources/auth_local_datasource_impl.dart';
import 'package:papeeta/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:papeeta/features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'package:papeeta/features/auth/domain/repositories/auth_repository.dart';
import 'package:papeeta/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:papeeta/features/auth/presentation/bloc/auth_bloc.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  _registerDio();
  _registerAuth();
  _registerRecipes();
  _registerCategories();
  _registerIngredients();
  _registerGroups();
}

void _registerDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: Enviroment.apiUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  );

  // Interceptor (auth, logs, etc)
  dio.interceptors.add(PapeetaInterceptor());

  getIt.registerSingleton<Dio>(dio);
}

void _registerRecipes() {
  getIt.registerLazySingleton<RecipesRemoteDataSource>(
    () => RecipesRemoteDataSourceImpl(getIt<Dio>()),
  );

  getIt.registerLazySingleton<RecipesRepository>(
    () => RecipesRepositoryImpl(getIt<RecipesRemoteDataSource>()),
  );

  getIt.registerFactory(() => RecipeBloc(getIt<RecipesRepository>()));
}

void _registerCategories() {
  getIt.registerLazySingleton<CategoriesRemoteDataSource>(
    () => CategoriesRemoteDataSourceImpl(getIt<Dio>()),
  );

  getIt.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(getIt<CategoriesRemoteDataSource>()),
  );

  getIt.registerFactory<CategoryBloc>(
    () => CategoryBloc(getIt<CategoryRepository>()),
  );
}

void _registerIngredients() {
  getIt.registerLazySingleton<IngredientsRemoteDataSource>(
    () => IngredientsRemoteDataSourceImpl(getIt<Dio>()),
  );

  getIt.registerLazySingleton<IngredientRepository>(
    () => IngredientRepositoryImpl(getIt<IngredientsRemoteDataSource>()),
  );

  getIt.registerFactory<IngredientBloc>(
    () => IngredientBloc(repository: getIt<IngredientRepository>()),
  );
}

void _registerAuth() {
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );

  getIt.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(storage: getIt<FlutterSecureStorage>()),
  );

  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  getIt.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      localDataSource: getIt<AuthLocalDataSource>(),
    ),
  );

  getIt.registerLazySingleton<AuthBloc>(
    () => AuthBloc(repository: getIt<AuthRepository>()),
  );
}

void _registerGroups() {
  getIt.registerLazySingleton<GroupsRemoteDataSource>(
    () => GroupsRemoteDataSourceImpl(dio: getIt<Dio>()),
  );

  getIt.registerLazySingleton<GroupsRepository>(
    () =>
        GroupsRepositoryImpl(remoteDataSource: getIt<GroupsRemoteDataSource>()),
  );

  getIt.registerFactory<GroupsBloc>(
    () => GroupsBloc(repository: getIt<GroupsRepository>()),
  );
}
