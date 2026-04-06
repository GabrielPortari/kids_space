import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:get_it/get_it.dart';
import '../service/auth_service.dart';
import 'collaborator_controller.dart';
import '../model/collaborator.dart';
import 'company_controller.dart';
import '../model/user_type.dart';

enum UserRole { company, collaborator, unknown }

class AuthController extends ChangeNotifier {
  final AuthService _service = AuthService();
  String? _idToken;
  String? _refreshToken;
  UserRole _role = UserRole.unknown;

  String? get idToken => _idToken;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _idToken = prefs.getString('idToken');
    _refreshToken = prefs.getString('refreshToken');
    final r = prefs.getString('userRole');
    if (r != null) {
      _role = r.toLowerCase() == 'company'
          ? UserRole.company
          : (r.toLowerCase() == 'collaborator'
                ? UserRole.collaborator
                : UserRole.unknown);
    }
    notifyListeners();
  }

  Future<void> saveTokens(String idToken, String refreshToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('idToken', idToken);
    await prefs.setString('refreshToken', refreshToken);
    _idToken = idToken;
    _refreshToken = refreshToken;
    notifyListeners();
  }

  Map<String, dynamic>? _parseJwtPayload(String token) {
    try {
      final parts = token.split('.');
      if (parts.length < 2) return null;
      final payload = parts[1];
      String normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      return jsonDecode(decoded) as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  void _applyClaimsFromToken(String? token) {
    if (token == null) return;
    final payload = _parseJwtPayload(token);
    if (payload == null) return;
    // prefer explicit 'roles' claim, or fallback to 'role' or 'userType'
    final claims = payload['roles'] ?? payload['role'] ?? payload['userType'];
    if (claims is List && claims.isNotEmpty) {
      final first = claims.first.toString().toLowerCase();
      if (first == 'company')
        saveRole(UserRole.company);
      else if (first == 'collaborator')
        saveRole(UserRole.collaborator);
      else
        saveRole(UserRole.unknown);
    } else if (claims is String) {
      final c = claims.toLowerCase();
      if (c == 'company')
        saveRole(UserRole.company);
      else if (c == 'collaborator')
        saveRole(UserRole.collaborator);
      else
        saveRole(UserRole.unknown);
    }
  }

  String? _asString(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final v = value.trim();
      return v.isEmpty ? null : v;
    }
    return value.toString();
  }

  String? _extractCompanyId(Map<String, dynamic> payload) {
    final direct = _asString(payload['companyId'] ?? payload['company_id']);
    if (direct != null) return direct;

    final company = payload['company'];
    if (company is Map) {
      final map = Map<String, dynamic>.from(company);
      return _asString(map['id'] ?? map['companyId'] ?? map['company_id']);
    }
    return null;
  }

  Collaborator? _buildCollaboratorFromTokenClaims() {
    if (_idToken == null) return null;
    final payload = _parseJwtPayload(_idToken!);
    if (payload == null) return null;

    final id = _asString(payload['uid'] ?? payload['userId'] ?? payload['sub']);
    final companyId = _extractCompanyId(payload);
    final name = _asString(payload['name'] ?? payload['displayName']);
    final email = _asString(payload['email']);
    final role = _asString(payload['role'] ?? payload['userType']);

    if (id == null && companyId == null && name == null && email == null) {
      return null;
    }

    return Collaborator(
      id: id,
      companyId: companyId,
      name: name,
      email: email,
      userType: userTypeFromString(role),
    );
  }

  Future<void> saveRole(UserRole role) async {
    // Set role immediately so UI can read it synchronously.
    _role = role;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'userRole',
      role == UserRole.company
          ? 'company'
          : (role == UserRole.collaborator ? 'collaborator' : 'unknown'),
    );
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('idToken');
    await prefs.remove('refreshToken');
    _idToken = null;
    _refreshToken = null;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    try {
      final res = await _service.login(email, password);
      final token = res['idToken'] as String?;
      final refresh = res['refreshToken'] as String?;
      // parse role from response body (v2 returns user object with role)
      final roleStr = (res['user'] is Map)
          ? (res['user']['role'] as String? ??
                res['user']['userType'] as String?)
          : null;
      // Diagnostic logs to help identify unknown role issues
      // ignore: avoid_print
      print('AuthController.login: res.user=${res['user']} roleStr=$roleStr');
      final parsedRole = (roleStr != null && roleStr.toLowerCase() == 'company')
          ? UserRole.company
          : (roleStr != null && roleStr.toLowerCase() == 'collaborator'
                ? UserRole.collaborator
                : UserRole.unknown);
      if (token != null && refresh != null) {
        await saveTokens(token, refresh);
        // apply claims from token (if present) and fallback to response role
        // ignore: avoid_print
        print('AuthController.login: token payload=${_parseJwtPayload(token)}');
        _applyClaimsFromToken(token);
        // ignore: avoid_print
        print(
          'AuthController.login: role after claims=$_role parsedRole=$parsedRole',
        );
        if (_role == UserRole.unknown) await saveRole(parsedRole);
        // populate collaborator/company info after login
        await checkLoggedUser();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> signupCompany(Map<String, dynamic> payload) async {
    try {
      final res = await _service.signup(payload);
      final token = res['idToken'] as String?;
      final refresh = res['refreshToken'] as String?;
      if (token != null && refresh != null) {
        await saveTokens(token, refresh);
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _service.logout();
    } catch (_) {}
    await clearTokens();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userRole');
    _role = UserRole.unknown;
  }

  Future<bool> ensureSessionValid() async {
    if (_idToken == null) await loadFromStorage();
    if (_idToken == null) return false;
    try {
      final payload = _parseJwtPayload(_idToken!);
      if (payload != null && payload.containsKey('exp')) {
        final exp = payload['exp'];
        if (exp is int || exp is double || exp is String) {
          final expInt = int.tryParse(exp.toString());
          if (expInt != null) {
            final expiry = DateTime.fromMillisecondsSinceEpoch(expInt * 1000);
            final now = DateTime.now().toUtc();
            // refresh if token expires within the next 60 seconds
            if (expiry.isAfter(now.add(const Duration(seconds: 60)))) {
              return true;
            }
          }
        }
      }
      // token missing exp or about to expire -> try refresh
      final newToken = await refreshToken();
      if (newToken != null && newToken.isNotEmpty) return true;
      // refresh failed: force logout
      await logout();
      return false;
    } catch (e) {
      // on any unexpected error, be conservative and logout
      try {
        await logout();
      } catch (_) {}
      return false;
    }
  }

  Future<String?> getIdToken() async {
    if (_idToken == null) await loadFromStorage();
    return _idToken;
  }

  UserRole get role => _role;

  Future<String?> refreshToken() async {
    if (_refreshToken == null) await loadFromStorage();
    if (_refreshToken == null) return null;
    final res = await _service.refreshToken(_refreshToken!);
    final newToken = res['idToken'] as String?;
    if (newToken != null) {
      await saveTokens(newToken, _refreshToken!);
      // update role from refreshed token claims
      _applyClaimsFromToken(newToken);
      return newToken;
    }
    return null;
  }

  Future<void> checkLoggedUser() async {
    await loadFromStorage();
    if (_idToken == null) return;
    try {
      // Prefer token claims bootstrap to avoid hard dependency on /v2/collaborators/me.
      final collabController = GetIt.I.get<CollaboratorController>();
      if (_role == UserRole.collaborator) {
        final tokenCollab = _buildCollaboratorFromTokenClaims();
        if (tokenCollab != null) {
          await collabController.setLoggedCollaborator(tokenCollab);
        }
      } else if (_role == UserRole.company) {
        final co = GetIt.I.get<CompanyController>();
        await co.loadMyCompany();
      } else {
        // unknown: try to infer from token claims or API
        if (_idToken != null) _applyClaimsFromToken(_idToken);
        if (_role == UserRole.collaborator) {
          final tokenCollab = _buildCollaboratorFromTokenClaims();
          if (tokenCollab != null) {
            await collabController.setLoggedCollaborator(tokenCollab);
          }
        } else if (_role == UserRole.company) {
          final co = GetIt.I.get<CompanyController>();
          await co.loadMyCompany();
        }
      }
    } catch (_) {}
  }
}
