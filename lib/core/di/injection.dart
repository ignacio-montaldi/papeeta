import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:papeeta/features/recipes/data/datasources/recipes_remote_datasource.dart';
import 'package:papeeta/features/recipes/data/datasources/recipes_remote_datasource_impl.dart';
import 'package:papeeta/features/recipes/domain/repositories/recipes_repository.dart';
import 'package:papeeta/features/recipes/domain/repositories/recipes_repository_impl.dart';
import 'package:papeeta/global/enviroment.dart';
import 'package:papeeta/services/papeeta_interceptor.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  _registerDio();
  _registerRecipes();
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
}
