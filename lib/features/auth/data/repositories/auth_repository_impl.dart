import 'dart:io';
import 'package:papeeta/features/auth/data/datasources/auth_local_datasource.dart';
import 'package:papeeta/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:papeeta/features/auth/data/mappers/user_mapper.dart';
import 'package:papeeta/features/auth/domain/entities/user.dart';
import 'package:papeeta/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<User?> checkAuthStatus() async {
    try {
      final token = await localDataSource.getToken();
      if (token == null) return null;

      final response = await remoteDataSource.checkAuthStatus();
      if (response.ok) {
        await localDataSource.saveToken(response.token);
        return UserMapper.toEntity(response.user);
      }
    } catch (e) {
      await localDataSource.removeToken();
    }
    return null;
  }

  @override
  Future<String?> getToken() async {
    return await localDataSource.getToken();
  }

  @override
  Future<User> login(String email, String password) async {
    final response = await remoteDataSource.login(email, password);
    if (!response.ok) {
      throw Exception('Invalid credentials');
    }
    await localDataSource.saveToken(response.token);
    return UserMapper.toEntity(response.user);
  }

  @override
  Future<void> logout() async {
    await localDataSource.removeToken();
  }

  @override
  Future<User> register(String alias, String nombreUsuario, String email, String password) async {
    final response = await remoteDataSource.register(alias, nombreUsuario, email, password);
    if (!response.ok) {
      throw Exception('Could not register user');
    }
    await localDataSource.saveToken(response.token);
    return UserMapper.toEntity(response.user);
  }

  @override
  Future<User> updateProfile({
    String? alias,
    String? email,
    String? passwordNueva,
    String? passwordActual,
    File? imagen,
  }) async {
    final response = await remoteDataSource.updateProfile(
      alias: alias,
      email: email,
      passwordNueva: passwordNueva,
      passwordActual: passwordActual,
      imagen: imagen,
    );
    if (!response.ok) {
      throw Exception(response.message ?? 'Could not update profile');
    }
    return UserMapper.toEntity(response.user);
  }
}
