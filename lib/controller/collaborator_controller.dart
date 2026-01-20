import 'dart:convert';
import 'dart:developer' as developer;
import 'package:kids_space/service/collaborator_service.dart';
import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import 'package:kids_space/model/collaborator.dart';
// use secure storage via BaseController
import 'base_controller.dart';

part 'collaborator_controller.g.dart';

class CollaboratorController = _CollaboratorController with _$CollaboratorController;

abstract class _CollaboratorController extends BaseController with Store {
  
  final CollaboratorService _collaboratorService = GetIt.I<CollaboratorService>();
  
  @observable
  Collaborator? loggedCollaborator;

  @observable
  Collaborator? selectedCollaborator;

  @observable
  ObservableList<Collaborator> collaborators = ObservableList<Collaborator>();

  @observable
  String collaboratorFilter = '';

  @computed
  List<Collaborator> get filteredCollaborators {
    final filter = collaboratorFilter.toLowerCase();
    if (filter.isEmpty) return collaborators;
    return collaborators.where((c) => (c.name?.toLowerCase().contains(filter) ?? false) || (c.email?.toLowerCase().contains(filter) ?? false)).toList();
  }

  @observable
  bool refreshLoading = false;

  @action
  Future<void> refreshCollaboratorsForCompany(String? companyId) async {
    refreshLoading = true;
    if (companyId == null) {
      collaborators.clear();
      refreshLoading = false;
      return;
    }
    final list = await _collaboratorService.getCollaboratorsByCompanyId(companyId);
    collaborators
      ..clear()
      ..addAll(list);
    refreshLoading = false;
  }

  /// Define o colaborador logado e persiste localmente
  @action
  setLoggedCollaborator(Collaborator? collaborator)  {
    loggedCollaborator = collaborator;
    try {
      if (collaborator != null) {
        secureStorage.write(key: 'loggedCollaborator', value: jsonEncode(collaborator.toJson()));
        developer.log('CollaboratorController.setLoggedCollaborator persisted', name: 'CollaboratorController', error: {'id': collaborator.id});
      } else {
        secureStorage.delete(key: 'loggedCollaborator');
        developer.log('CollaboratorController.setLoggedCollaborator cleared', name: 'CollaboratorController');
      }
    } catch (e) {
      developer.log('CollaboratorController.setLoggedCollaborator persist failed', name: 'CollaboratorController', error: e);
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
    try {
      await secureStorage.delete(key: 'loggedCollaborator');
    } catch (_) {}
  }

  /// Carrega colaborador salvo localmente (se existir)
  @action
  Future<bool> loadLoggedCollaboratorFromPrefs() async {
    try {
      final jsonString = await secureStorage.read(key: 'loggedCollaborator');
      if (jsonString != null && jsonString.isNotEmpty) {
        loggedCollaborator = Collaborator.fromJson(jsonDecode(jsonString));
        return true;
      }
    } catch (e) {
      developer.log('CollaboratorController.loadLoggedCollaboratorFromPrefs failed', name: 'CollaboratorController', error: e);
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
  Future<Collaborator?> getCollaboratorById(String id) async {
    try {
      return await _collaboratorService.getCollaboratorById(id);
    } catch (e) {
      developer.log('CollaboratorController.getCollaboratorById failed', name: 'CollaboratorController', error: e);
      return null;
    }
  }

  @action
  Future<bool> createCollaborator(Collaborator collaborator) async {
    final success = await _collaboratorService.createCollaborator(collaborator);
    return success;
  }
}