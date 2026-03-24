import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _service = AuthService();
  String? _idToken;
  String? _refreshToken;

  String? get idToken => _idToken;

  Future<void> loadFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    _idToken = prefs.getString('idToken');
    _refreshToken = prefs.getString('refreshToken');
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

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('idToken');
    await prefs.remove('refreshToken');
    _idToken = null;
    _refreshToken = null;
    notifyListeners();
  }

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _service.login(email, password);
    final token = res['idToken'] as String?;
    final refresh = res['refreshToken'] as String?;
    if (token != null && refresh != null) {
      await saveTokens(token, refresh);
    }
    return res;
  }

  Future<void> logout() async {
    try {
      await _service.logout();
    } catch (_) {}
    await clearTokens();
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

  Future<String?> refreshToken() async {
    if (_refreshToken == null) await loadFromStorage();
    if (_refreshToken == null) return null;
    final res = await _service.refreshToken(_refreshToken!);
    final newToken = res['idToken'] as String?;
    final expires = res['expiresIn'] as String?;
    if (newToken != null) {
      await saveTokens(newToken, _refreshToken!);
      return newToken;
    }
    return null;
  }
}
