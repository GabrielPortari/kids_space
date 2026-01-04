// Serviço de autenticação
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_space/model/mock/model_mock.dart';
import 'dart:developer' as developer;

class AuthService {

  // Simulação de autenticação usando mockCollaborators
  Future<bool> login(String email, String password) async {
    developer.log('login called: email=$email', name: 'AuthService');
    await Future.delayed(const Duration(milliseconds: 300));

    final exists = mockCollaborators.any(
      (c) => c.email == email && c.password == password,
    );

    developer.log('login result for email=$email: $exists', name: 'AuthService');
    return exists;

  }

  Future<String?> getLoggedUser() async {
    developer.log('getLoggedUser called', name: 'AuthService');
    final prefs = await SharedPreferences.getInstance();
    final v = prefs.getString('logged_user');
    developer.log('getLoggedUser returning ${v != null}', name: 'AuthService');
    return v;
  }
}
