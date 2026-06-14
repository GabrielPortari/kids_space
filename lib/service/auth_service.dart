import 'dart:convert';
import 'api_client.dart';

class AuthService {
  final ApiClient _api = ApiClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final res = await _api.post('/auth/login', {
      'email': email,
      'password': password,
    });
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Login failed: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> signup(Map<String, dynamic> payload) async {
    final res = await _api.post('/auth/signup', payload);
    if (res.statusCode == 201) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Signup failed: ${res.statusCode}');
  }

  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final res = await _api.post('/auth/refresh-auth', {
      'refreshToken': refreshToken,
    });
    if (res.statusCode == 200) {
      return jsonDecode(res.body) as Map<String, dynamic>;
    }
    throw Exception('Refresh failed: ${res.statusCode}');
  }

  Future<void> logout() async {
    final res = await _api.post('/auth/logout', {});
    if (res.statusCode == 204) return;
    throw Exception('Logout failed: ${res.statusCode}');
  }
}
