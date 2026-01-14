import 'dart:async';
import 'dart:convert';

import 'dart:developer' as dev;
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
  Timer? _tokenMonitorTimer;
  bool _isRefreshing = false;
  final Duration _monitorInterval = const Duration(seconds: 60);

  final CollaboratorController _collaboratorController = GetIt.I<CollaboratorController>();
  final AuthService _authService = GetIt.I<AuthService>();

  final _kIdTokenKey = 'idToken';
  final _kRefreshTokenKey = 'refreshToken';
  final _kLoggedCollaboratorKey = 'loggedCollaborator';

  AuthController() {
    _startTokenMonitor();
  }

  /// Tenta logar; retorna `true` se sucesso.
  Future<bool> login(String email, String password) async {
    final result = await _authService.login(email, password);

    final idToken = result[_kIdTokenKey] as String?;
    final refreshToken = result[_kRefreshTokenKey] as String?;
    
    String? userId = result['userId'] as String?;
    // If backend didn't return userId, try to decode from JWT idToken
    if ((userId == null || userId.isEmpty) && idToken != null) {
      try {
        final extracted = _extractUserIdFromJwt(idToken);
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
      final t = token.trim();
      if (t.isNotEmpty && t.toLowerCase() != 'null') {
        try {
          await _authService.logout(t);
        } catch (_) {}
      }
    }

    await secureStorage.delete(key: _kIdTokenKey);
    await secureStorage.delete(key: _kRefreshTokenKey);
    await secureStorage.delete(key: _kLoggedCollaboratorKey);
    _collaboratorController.loggedCollaborator = null;
    ApiClient().tokenProvider = null;
    ApiClient().refreshToken = null;
  }

  Future<void> checkLoggedUser() async {
    final token = await secureStorage.read(key: 'idToken');
    final collaboratorJson = await secureStorage.read(key: _kLoggedCollaboratorKey);

    dev.log('AuthController.checkLoggedUser -> loaded from storage', name: 'AuthController', error: {
      'tokenPresent': token != null,
      'collaboratorJsonPresent': collaboratorJson != null,
      'collaboratorJson': collaboratorJson,
    });

    if (token == null) {
      dev.log('AuthController.checkLoggedUser -> no token found in storage', name: 'AuthController');
      return;
    }

    ApiClient().tokenProvider = () async => token;
    ApiClient().refreshToken = () async => await refreshToken();

    if (collaboratorJson != null) {
      try {
        final collaborator = Collaborator.fromJson(jsonDecode(collaboratorJson));
        _collaboratorController.setLoggedCollaborator(collaborator);
        dev.log('AuthController.checkLoggedUser -> set collaborator from storage', name: 'AuthController', error: {'id': collaborator.id});
        return;
      } catch (e) {
        dev.log('AuthController.checkLoggedUser -> failed to parse stored collaborator: $e', name: 'AuthController');
      }
    }

    // fallback: try to extract userId from token or from stored userId
    String? userId = await secureStorage.read(key: 'userId');
    if ((userId == null || userId.isEmpty)) {
      final extracted = _extractUserIdFromJwt(token);
      dev.log('AuthController.checkLoggedUser -> extracted userId from token', name: 'AuthController', error: {'extracted': extracted});
      userId = extracted;
      if (userId != null) await secureStorage.write(key: 'userId', value: userId);
    }

    if (userId != null) {
      final collaborator = await _collaboratorController.getCollaboratorById(userId);
      dev.log('AuthController.checkLoggedUser -> collaborator fetch by userId', name: 'AuthController', error: {'collaborator': collaborator?.toJson()});
      if (collaborator != null) {
        _collaboratorController.setLoggedCollaborator(collaborator);
        await secureStorage.write(key: _kLoggedCollaboratorKey, value: jsonEncode(collaborator.toJson()));
      }
    } else {
      dev.log('AuthController.checkLoggedUser -> no userId available to fetch collaborator', name: 'AuthController');
    }
  }

  void _startTokenMonitor() {
    // Avoid multiple timers
    _tokenMonitorTimer?.cancel();
    _tokenMonitorTimer = Timer.periodic(_monitorInterval, (_) async {
      try {
        await _checkAndRefreshIfNeeded();
      } catch (e, st) {
        dev.log('AuthController._startTokenMonitor error: $e', name: 'AuthController', error: st);
      }
    });
  }

  Future<void> stopTokenMonitor() async {
    _tokenMonitorTimer?.cancel();
    _tokenMonitorTimer = null;
  }

  Future<void> _checkAndRefreshIfNeeded() async {
    if (_isRefreshing) return;
    try {
      final token = await secureStorage.read(key: _kIdTokenKey);
      if (token == null) return;
      if (!_isTokenExpired(token)) return;
      _isRefreshing = true;
      dev.log('AuthController._checkAndRefreshIfNeeded -> token expired, attempting refresh', name: 'AuthController');
      final newId = await refreshToken();
      if (newId != null) {
        // refreshToken already writes tokens to storage; update ApiClient provider
        ApiClient().tokenProvider = () async => await secureStorage.read(key: _kIdTokenKey);
        dev.log('AuthController._checkAndRefreshIfNeeded -> refresh successful', name: 'AuthController');
      } else {
        dev.log('AuthController._checkAndRefreshIfNeeded -> refresh failed', name: 'AuthController');
      }
    } finally {
      _isRefreshing = false;
    }
  }

  /// Returns the currently stored id token (if any).
  Future<String?> getIdToken() async {
    return await secureStorage.read(key: _kIdTokenKey);
  }

  int? _extractExpFromJwt(String jwt) {
    try {
      final parts = jwt.split('.');
      if (parts.length != 3) return null;
      String payload = parts[1];
      payload = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(payload));
      final map = jsonDecode(decoded) as Map<String, dynamic>;
      final exp = map['exp'];
      if (exp is int) return exp;
      if (exp is String) return int.tryParse(exp);
      return null;
    } catch (e) {
      dev.log('AuthController._extractExpFromJwt failed: $e', name: 'AuthController');
      return null;
    }
  }

  bool _isTokenExpired(String jwt, {Duration buffer = const Duration(seconds: 60)}) {
    final exp = _extractExpFromJwt(jwt);
    if (exp == null) return true;
    final expiry = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
    return DateTime.now().isAfter(expiry.subtract(buffer));
  }

  /// Ensures token is valid: returns true if valid or refreshed, false otherwise.
  Future<bool> ensureSessionValid() async {
    final token = await secureStorage.read(key: _kIdTokenKey);
    if (token == null) return false;
    if (!_isTokenExpired(token)) return true;
    final newId = await refreshToken();
    return newId != null;
  }

  Future<String?> refreshToken() async {
    final stored = await secureStorage.read(key: _kRefreshTokenKey);
    if (stored == null) return null;
    final response = await apiClient.dio.post('/auth/refresh-auth', data: {
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