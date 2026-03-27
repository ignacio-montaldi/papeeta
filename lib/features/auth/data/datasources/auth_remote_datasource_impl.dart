import 'package:dio/dio.dart';
import 'package:papeeta/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:papeeta/features/auth/data/models/auth_response_dto.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<AuthResponseDto> login(String email, String password) async {
    final response = await dio.post(
      '/login',
      data: {'email': email, 'password': password},
    );
    return AuthResponseDto.fromJson(response.data);
  }

  @override
  Future<AuthResponseDto> register(
    String name,
    String email,
    String password,
  ) async {
    final response = await dio.post(
      '/login/new',
      data: {'nombre': name, 'email': email, 'password': password},
    );
    return AuthResponseDto.fromJson(response.data);
  }

  @override
  Future<AuthResponseDto> checkAuthStatus() async {
    final response = await dio.get('/login/renew');
    return AuthResponseDto.fromJson(response.data);
  }
}
