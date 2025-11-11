import 'dart:convert';

import 'package:mobx/mobx.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'collaborator_controller.g.dart';

class CollaboratorController = _CollaboratorController with _$CollaboratorController;

abstract class _CollaboratorController with Store {
  @observable
  Collaborator? loggedCollaborator;

  /// Define o colaborador logado e persiste localmente
  @action
  Future<void> setLoggedCollaborator(Collaborator? collaborator) async {
    loggedCollaborator = collaborator;
    final prefs = await SharedPreferences.getInstance();
    if (collaborator != null) {
      // Cria uma cópia sem a senha antes de salvar
      final sanitized = Collaborator(
        id: collaborator.id,
        name: collaborator.name,
        email: collaborator.email,
        companyId: collaborator.companyId,
        phoneNumber: collaborator.phoneNumber,
        // adicione outros campos se houver
      );
      await prefs.setString('logged_user', jsonEncode(sanitized.toJson()));
    } else {
      await prefs.remove('logged_user');
    }
  }

  /// Limpa o colaborador logado e remove dos dados locais
  @action
  Future<void> clearLoggedCollaborator() async {
    loggedCollaborator = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('logged_user');
  }

  /// Carrega colaborador salvo localmente (se existir)
  @action
  Future<bool> loadLoggedCollaboratorFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('logged_user');
    if (jsonString != null) {
      loggedCollaborator = Collaborator.fromJson(jsonDecode(jsonString));
      return true;
    }
    loggedCollaborator = null;
    return false;
  }
}