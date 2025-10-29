// Serviço de autenticação
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kids_space/model/mock/model_mock.dart';

class AuthService {

  // Simulação de autenticação usando mockCollaborators
  Future<bool> login(String email, String password) async {
    await Future.delayed(Duration(seconds: 1));

    final exists = mockCollaborators.any(
      (c) => c.email == email && c.password == password,
    );

    return exists;

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
