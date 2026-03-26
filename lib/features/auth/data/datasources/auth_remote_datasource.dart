import 'package:papeeta/features/auth/data/models/auth_response_dto.dart';

abstract class AuthRemoteDataSource {
  Future<AuthResponseDto> login(String email, String password);
  Future<AuthResponseDto> register(String name, String email, String password);
  Future<AuthResponseDto> checkAuthStatus();
}
