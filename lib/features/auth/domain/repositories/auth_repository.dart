import 'package:papeeta/features/auth/domain/entities/user.dart';

abstract class AuthRepository {
  Future<User> login(String email, String password);
  Future<User> register(String name, String email, String password);
  Future<User?> checkAuthStatus();
  Future<void> logout();
  Future<String?> getToken();
}
