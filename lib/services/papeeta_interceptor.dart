import 'package:dio/dio.dart';
import 'package:papeeta/core/di/injection.dart';
import 'package:papeeta/features/auth/data/datasources/auth_local_datasource.dart';

class PapeetaInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final localDataSource = getIt<AuthLocalDataSource>();
    final token = await localDataSource.getToken();

    if (token != null) {
      options.headers.addAll({'x-token': token});
    }

    super.onRequest(options, handler);
  }
}
