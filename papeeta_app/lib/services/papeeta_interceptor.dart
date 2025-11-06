import 'package:dio/dio.dart';
import 'package:papeeta/services/services.dart';

class PapeetaInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers.addAll({'x-token': await AuthService.getToken()});
    super.onRequest(options, handler);
  }
}
