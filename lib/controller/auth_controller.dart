import 'dart:convert';

import 'dart:developer' as dev;
import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/service/api_client.dart';
import '../service/auth_service.dart';
import 'base_controller.dart';

/// AuthController — parte do padrão MVC.
/// - Controller: expõe métodos que a View chama.
/// - Usa `AuthService` para lógica de autenticação (Model/Service).
class AuthController extends BaseController {
  final CollaboratorController _collaboratorController = GetIt.I<CollaboratorController>();
  final AuthService _authService = GetIt.I<AuthService>();

  final _kIdTokenKey = 'idToken';
  final _kRefreshTokenKey = 'refreshToken';
  final _kLoggedCollaboratorKey = 'loggedCollaborator';

  /// Tenta logar; retorna `true` se sucesso.
  Future<bool> login(String email, String password) async {
    final result = await _authService.login(email, password);

    dev.log('AuthController.login -> authService result', name: 'AuthController', error: result.values);

    final idToken = result[_kIdTokenKey] as String?;
    final refreshToken = result[_kRefreshTokenKey] as String?;
    
    String? userId = result['userId'] as String?;
    // If backend didn't return userId, try to decode from JWT idToken
    if ((userId == null || userId.isEmpty) && idToken != null) {
      try {
        final extracted = _extractUserIdFromJwt(idToken);
        dev.log('AuthController.login -> extracted userId from token', name: 'AuthController', error: {'extracted': extracted});
        userId = extracted;
      } catch (e) {
        dev.log('AuthController.login -> failed to extract userId from token: $e', name: 'AuthController');
      }
    }
    
    if (idToken == null || refreshToken == null) return false;

    await secureStorage.write(key: _kIdTokenKey, value: idToken);
    await secureStorage.write(key: _kRefreshTokenKey, value: refreshToken);

    if (userId != null) {
      dev.log('AuthController.login -> fetching collaborator for userId', name: 'AuthController', error: {'userId': userId});
      final collaborator = await _collaboratorController.getCollaboratorById(userId);
      dev.log('AuthController.login -> collaborator fetch result', name: 'AuthController', error: {'collaborator': collaborator?.toJson()});
      if (collaborator != null) {
        await secureStorage.write(key: _kLoggedCollaboratorKey, value: jsonEncode(collaborator.toJson()));
        _collaboratorController.setLoggedCollaborator(collaborator);
      }
    } else {
      dev.log('AuthController.login -> userId null in auth result', name: 'AuthController');
    }
    ApiClient().tokenProvider = () async => await secureStorage.read(key: _kIdTokenKey);
    ApiClient().refreshToken = () async => refreshToken;

    return true;
  }

  /// Faz logout local e remoto via `AuthService`.
  Future<void> logout() async {
    final token = await secureStorage.read(key: _kIdTokenKey);
    if (token != null) {
      try { await ApiClient().dio.post('/auth/logout', 
      options: Options(
        headers: {'Authorization': 'Bearer $token'}
        )); 
      } catch (_) {}
    }
    
    await secureStorage.delete(key: _kIdTokenKey);
    await secureStorage.delete(key: _kRefreshTokenKey);
    await secureStorage.delete(key: _kLoggedCollaboratorKey);
    _collaboratorController.loggedCollaborator = null;
    ApiClient().tokenProvider = null;
    ApiClient().refreshToken = null;
  }

  /// Chamada na inicialização da View/App para restaurar estado.
  Future<void> checkLoggedUser() async {
    final token = await secureStorage.read(key: 'idToken');
    final collaboratorJson = await secureStorage.read(key: _kLoggedCollaboratorKey);

    if (token != null) {
      ApiClient().tokenProvider = () async => token;
      ApiClient().refreshToken = () async => await refreshToken();

      if(collaboratorJson != null){
        final collaborator = Collaborator.fromJson(jsonDecode(collaboratorJson));
        _collaboratorController.setLoggedCollaborator(collaborator);
        return;
      }

      final userId = await secureStorage.read(key: 'userId');
      if (userId != null) {
        final collaborator = await _collaboratorController.getCollaboratorById(userId);
        if(collaborator != null){
          _collaboratorController.setLoggedCollaborator(collaborator);
          await secureStorage.write(key: _kLoggedCollaboratorKey, value: jsonEncode(collaborator.toJson()));
        }
      }
    }
  }

  Future<String?> refreshToken() async {
    final stored = await secureStorage.read(key: _kRefreshTokenKey);
    if (stored == null) return null;
    final response = await apiClient.dio.post('/auth/refresh', data: {
      'refreshToken': stored,
    });
    final newId = response.data['idToken'] as String?;
    final newRefreshToken = response.data['refreshToken'] as String?;
    if (newId != null && newRefreshToken != null) {
      await secureStorage.write(key: _kIdTokenKey, value: newId);
      await secureStorage.write(key: _kRefreshTokenKey, value: newRefreshToken);
      return newId;
    }
    return null;
  }
  
  String? _extractUserIdFromJwt(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return null;
      String payload = parts[1];
      // Normalize base64 (URL-safe)
      payload = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      // common claim names: user_id (firebase), sub, uid, userId
      return map['user_id'] as String? ?? map['sub'] as String? ?? map['uid'] as String? ?? map['userId'] as String?;
    } catch (e) {
      dev.log('AuthController._extractUserIdFromJwt failed: $e', name: 'AuthController');
      return null;
    }
  }
}