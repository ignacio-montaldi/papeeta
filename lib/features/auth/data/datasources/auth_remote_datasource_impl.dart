import 'dart:io';
import 'package:dio/dio.dart';
import 'package:papeeta/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:papeeta/features/auth/data/models/auth_response_dto.dart' show AuthResponseDto, ProfileResponseDto;

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

  @override
  Future<ProfileResponseDto> updateProfile({
    String? alias,
    String? email,
    String? passwordNueva,
    String? passwordActual,
    File? imagen,
  }) async {
    final formData = FormData();

    if (alias != null) formData.fields.add(MapEntry('alias', alias));
    if (email != null) formData.fields.add(MapEntry('email', email));
    if (passwordNueva != null) {
      formData.fields.add(MapEntry('passwordNueva', passwordNueva));
    }
    if (passwordActual != null) {
      formData.fields.add(MapEntry('passwordActual', passwordActual));
    }
    if (imagen != null) {
      formData.files.add(
        MapEntry(
          'imagen',
          await MultipartFile.fromFile(
            imagen.path,
            filename: imagen.path.split('/').last,
          ),
        ),
      );
    }

    final response = await dio.put(
      '/login/profile',
      data: formData,
    );
    if (response.data['ok'] == false) {
      throw Exception(response.data['msg'] ?? 'Error al actualizar perfil');
    }
    return ProfileResponseDto.fromJson(response.data);
  }
}
