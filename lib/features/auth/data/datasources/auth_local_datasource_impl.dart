import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:papeeta/features/auth/data/datasources/auth_local_datasource.dart';

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  AuthLocalDataSourceImpl({required FlutterSecureStorage storage})
      : _storage = storage;

  @override
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  @override
  Future<void> removeToken() async {
    await _storage.delete(key: 'token');
  }

  @override
  Future<void> saveToken(String token) async {
    await _storage.write(key: 'token', value: token);
  }
}
