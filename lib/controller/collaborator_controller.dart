import 'dart:convert';

import 'package:kids_space/service/collaborator_service.dart';
import 'package:mobx/mobx.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'collaborator_controller.g.dart';

class CollaboratorController = _CollaboratorController with _$CollaboratorController;

abstract class _CollaboratorController with Store {
  
  final CollaboratorService _collaboratorService = CollaboratorService();
  
  @observable
  Collaborator? loggedCollaborator;

  @observable
  Collaborator? selectedCollaborator;

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
        phone: collaborator.phone, 
        userType: collaborator.userType,
        // adicione outros campos se houver
      );
      await prefs.setString('logged_user', jsonEncode(sanitized.toJson()));
    } else {
      await prefs.remove('logged_user');
    }
  }

  /// Define o colaborador selecionado para visualização (não altera o logado)
  @action
  Future<void> setSelectedCollaborator(Collaborator? collaborator) async {
    selectedCollaborator = collaborator;
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
  
  @action
  Future<bool> deleteCollaborator(String? id) async {
    if(id != null && id.isNotEmpty){
      return _collaboratorService.deleteCollaborator(id);
    } else {
      return false;
    }
  }

  /// Atualiza colaborador via serviço e mantém estado local consistente
  @action
  Future<bool> updateCollaborator(Collaborator collaborator) async {
    final success = await _collaboratorService.updateCollaborator(collaborator);
    if (success) {
      // atualiza selected e logged se necessário
      if (selectedCollaborator?.id == collaborator.id) {
        selectedCollaborator = collaborator;
      }
      if (loggedCollaborator?.id == collaborator.id) {
        await setLoggedCollaborator(collaborator);
      }
    }
    return success;
  }

  /// Busca colaborador por id delegando ao serviço
  Future<Collaborator?> getCollaboratorById(String id) {
    return _collaboratorService.getCollaboratorById(id);
  }
}