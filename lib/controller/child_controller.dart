import '../model/child.dart';
import '../service/child_service.dart';
import '../model/user.dart';
import '../model/mock/model_mock.dart';

class ChildController {
  final ChildService _childService = ChildService();

  List<Child> activeCheckedInChildren(String companyId) => _childService.getActiveCheckedInChildren(companyId);

  // Atualiza os responsáveis de uma criança pelo id
  void updateResponsibleUsers(String childId, List<String> newResponsibleUserIds) {
    final child = _childService.getChildById(childId);
    if (child != null) {
      child.responsibleUserIds
        ..clear()
        ..addAll(newResponsibleUserIds);
    }
  }
  // Retorna um mapa de childId para lista de responsáveis (User)
  Map<String, List<User>> getChildrenWithResponsibles(List<Child> children) {
    final Map<String, List<User>> result = {};
    for (final child in children) {
      final responsibles = mockUsers
          .where((u) => child.responsibleUserIds.contains(u.id))
          .toList();
      result[child.id] = responsibles;
    }
    return result;
  }

  // Getter para obter o mapa de responsáveis das crianças ativas da empresa selecionada
  // Retorna mapa por childId
  Map<String, List<User>> get activeChildrenWithResponsibles {
    // companyId deve ser passado externamente ou via outro controller
    // Aqui retorna vazio por padrão
    return {};
  }

  // Atualiza uma criança (delegando ao serviço)
  void updateChild(Child child) {
    _childService.updateChild(child);
  }

  // Busca crianças da empresa (delegando ao serviço)
  Future<List<Child>> getChildrenByCompanyId(String companyId) {
    return _childService.getChildrenByCompanyId(companyId);
  }
}