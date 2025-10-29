import 'package:kids_space/service/collaborator_service.dart';

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
    } else {
      _loggedUser = null;
    }
    return success;
  }

  Future<void> logout() async {
    await _authService.logout();
    _loggedUser = null;
  }

  Future<bool> checkLoggedUser() async {
    return false;
  }
}