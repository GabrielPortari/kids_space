// Serviço de autenticação
import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kids_space/service/base_service.dart';

class AuthService extends BaseService {
  
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final _kIdTokenKey = 'idToken';
  final _kRefreshTokenKey = 'refreshToken';

  Future<Map<String,dynamic>> login(String email, String password) async {
    try{
      final response = await dio.post('/auth/login', data: {
        'email': email,
        'password': password,
      });

      return {
        'idToken': response.data['idToken'],
        'refreshToken': response.data['refreshToken'],
        'userId': response.data['userId'] ?? response.data['localId'],
        'success': true,
      };

    } on DioException catch (e){
      dev.log('Login failed: ${e.response?.data ?? e.message}');
      return {'success': false, 'message': e.response?.data ?? e.message};
    } catch (e, stackTrace){
      dev.log('Login failed: $e - $stackTrace');
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<String?> refreshToken() async{
  final stored = await _secureStorage.read(key: _kRefreshTokenKey);
  if (stored == null) return null;
  final resp = await dio.post('/auth/refresh-auth', data: {'refreshToken': stored});
  final newId = resp.data['idToken'] as String?;
  final newRefresh = resp.data['refreshToken'] as String?;
  if (newId != null && newRefresh != null) {
    await _secureStorage.write(key: _kIdTokenKey, value: newId);
    await _secureStorage.write(key: _kRefreshTokenKey, value: newRefresh);
    return newId;
  }
  return null;
  }

  /// Calls backend to invalidate a token (logout). Returns true if request succeeded (2xx).
  Future<bool> logout(String token) async {
    try {
      final t = token.trim();
      if (t.isEmpty || t.toLowerCase() == 'null') return false;
      dev.log('AuthService.logout sending Authorization header', name: 'AuthService');
      final resp = await dio.post('/auth/logout',
        data: {},
        options: Options(headers: {'Authorization': 'Bearer $t'}),
      );
      return resp.statusCode != null && resp.statusCode! >= 200 && resp.statusCode! < 300;
    } on DioException catch (e) {
      dev.log('AuthService.logout DioException: ${e.response?.statusCode} ${e.response?.data ?? e.message}');
      return false;
    } catch (e, st) {
      dev.log('AuthService.logout error: $e', stackTrace: st);
      return false;
    }
  }
}
