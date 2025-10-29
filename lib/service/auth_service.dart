// Serviço de autenticação
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {

  // Simulação de autenticação
  Future<bool> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 1));
    bool success = email == 'admin@admin.com' && password == '123456';
    return success;
  }

  Future<bool> logout() async {
    await Future.delayed(Duration(milliseconds: 500));
    return true;
  }

  Future<String?> getLoggedUser() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('logged_user');
  }
}
