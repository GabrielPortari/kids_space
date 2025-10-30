import 'package:kids_space/model/collaborator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class CollaboratorController {
  Collaborator? _loggedCollaborator;
  Collaborator? get loggedCollaborator => _loggedCollaborator;

  /// Define o colaborador logado e persiste localmente
  Future<void> setLoggedCollaborator(Collaborator? collaborator) async {
    _loggedCollaborator = collaborator;
    final prefs = await SharedPreferences.getInstance();
    if (collaborator != null) {
      // Cria uma cópia sem a senha antes de salvar
      final sanitized = Collaborator(
        id: collaborator.id,
        name: collaborator.name,
        email: collaborator.email,
        password: '', // senha removida
        companyId: collaborator.companyId,
        // adicione outros campos se houver
      );
      await prefs.setString('logged_user', jsonEncode(sanitized.toJson()));
    } else {
      await prefs.remove('logged_user');
    }
  }

  /// Limpa o colaborador logado e remove dos dados locais
  Future<void> clearLoggedCollaborator() async {
    _loggedCollaborator = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_user');
  }

  /// Carrega colaborador salvo localmente (se existir)
  Future<bool> loadLoggedCollaboratorFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('logged_user');
    if (jsonString != null) {
      _loggedCollaborator = Collaborator.fromJson(jsonDecode(jsonString));
      return true;
    }
    _loggedCollaborator = null;
    return false;
  }
}