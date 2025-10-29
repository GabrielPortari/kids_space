import 'package:kids_space/service/collaborator_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../service/auth_service.dart';
import '../model/collaborator.dart';

class AuthController {
  final AuthService _authService = AuthService();
  final CollaboratorService _collaboratorService = CollaboratorService();
  Collaborator? _loggedUser;

  Collaborator? get loggedUser => _loggedUser;

  Future<bool> login(String email, String password) async {
    final success = await _authService.login(email, password);
    
    if (success) {
      _loggedUser = await _collaboratorService.getCollaboratorByEmail(email);

      if (_loggedUser != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('logged_user', jsonEncode(_loggedUser!.toJson()));
      }

    } else {
      _loggedUser = null;
    }
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_user');
    _loggedUser = null;
  }

  Future<bool> checkLoggedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('logged_user');
    if (jsonString != null) {
      _loggedUser = Collaborator.fromJson(jsonDecode(jsonString));
      return true;
    }
    _loggedUser = null;
    return false;
  }
}