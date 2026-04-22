import 'dart:io';
import 'package:papeeta/features/auth/data/models/auth_response_dto.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseDto> login(String email, String password);
  Future<AuthResponseDto> register(String alias, String nombreUsuario, String email, String password);
  Future<AuthResponseDto> checkAuthStatus();
  Future<ProfileResponseDto> updateProfile({
    String? alias,
    String? email,
    String? passwordNueva,
    String? passwordActual,
    File? imagen,
  });
}
