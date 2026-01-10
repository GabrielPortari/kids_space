// Serviço de autenticação
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {

  final Dio _dio;
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  AuthService(this._dio);
  
  Future<void> persistTokens(String idToken, String refreshToken, int expiresIn) async {
    final expireAt = DateTime.now().add(Duration(seconds: expiresIn));
    await _secureStorage.write(key: 'id_token', value: idToken);
    await _secureStorage.write(key: 'refresh_token', value: refreshToken);
    await _secureStorage.write(key: 'token_expire_at', value: expireAt.toIso8601String());
  }

  Future<bool> login(String email, String password) async {
    final resp = await _dio.post('/auth/login', data: {'email': email, 'password': password});
    if (resp.statusCode == 200) {
      final data = resp.data;
      await persistTokens(data['idToken'], data['refreshToken'], int.parse(data['expiresIn'].toString()));
      return true;
    }
    return false;
  }

  Future<String?> getIdToken() async => await _secureStorage.read(key: 'id_token');
  Future<String?> getRefreshToken() async => await _secureStorage.read(key: 'refresh_token');
  Future<DateTime?> getTokenExpireAt() async {
    final expireAt = await _secureStorage.read(key: 'token_expire_at');
    return expireAt == null ? null : DateTime.parse(expireAt);
  }

  Future<String?> refreshToken() async{
    final refresh = await getRefreshToken();
    if (refresh == null) return null;
    final response = await _dio.post('/auth/refresh', data: {'refreshToken': refresh});
    if (response.statusCode == 200) {
      final data = response.data;
      await persistTokens(data['idToken'], data['refreshToken'], int.parse(data['expiresIn'].toString()));
      return data['idToken'];
    }
    return null;
  }

  Future<void> logout() async{
    await _secureStorage.deleteAll();
  }
}
