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
    if (response.data['ok'] == false) {
      throw Exception(response.data['body'] ?? 'Error en el login');
    }
    return AuthResponseDto.fromJson(response.data);
  }

  @override
  Future<AuthResponseDto> register(
    String alias,
    String nombreUsuario,
    String email,
    String password,
  ) async {
    final response = await dio.post(
      '/login/new',
      data: {
        'alias': alias.isNotEmpty ? alias : null,
        'nombre_usuario': nombreUsuario,
        'email': email,
        'password': password,
      },
    );
    if (response.data['ok'] == false) {
      throw Exception(response.data['msg'] ?? response.data['body'] ?? 'Error en el registro');
    }
    return AuthResponseDto.fromJson(response.data);
  }

  @override
  Future<AuthResponseDto> checkAuthStatus() async {
    final response = await dio.get('/login/renew');
    return AuthResponseDto.fromJson(response.data);
  }
}
