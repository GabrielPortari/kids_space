import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import '../service/auth_service.dart';
import '../service/collaborator_service.dart';
import 'collaborator_controller.dart';
import '../model/collaborator.dart';
import 'company_controller.dart';

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

  Future<void> saveRole(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'userRole',
      role == UserRole.company
          ? 'company'
          : (role == UserRole.collaborator ? 'collaborator' : 'unknown'),
    );
    _role = role;
    notifyListeners();
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
          ? (res['user']['role'] as String?)
          : null;
      final parsedRole = (roleStr != null && roleStr.toLowerCase() == 'company')
          ? UserRole.company
          : (roleStr != null && roleStr.toLowerCase() == 'collaborator'
                ? UserRole.collaborator
                : UserRole.unknown);
      if (token != null && refresh != null) {
        await saveTokens(token, refresh);
        await saveRole(parsedRole);
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
    if (_idToken == null) return false;
    // naive: assume token valid
    return true;
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
      return newToken;
    }
    return null;
  }

  Future<void> checkLoggedUser() async {
    await loadFromStorage();
    if (_idToken == null) return;
    try {
      if (_role == UserRole.collaborator) {
        final srv = CollaboratorService();
        final data = await srv.getMe();
        if (data != null) {
          final c = Collaborator.fromJson(data);
          final collabController = GetIt.I.get<CollaboratorController>();
          await collabController.setLoggedCollaborator(c);
        }
      } else if (_role == UserRole.company) {
        final co = GetIt.I.get<CompanyController>();
        await co.loadMyCompany();
      }
    } catch (_) {}
  }
}
