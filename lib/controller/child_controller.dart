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
  // Retorna um mapa de Child para lista de responsáveis (User)
  Map<Child, List<User>> getChildrenWithResponsibles(List<Child> children) {
    final Map<Child, List<User>> result = {};
    for (final child in children) {
      final responsibles = mockUsers
          .where((u) => child.responsibleUserIds.contains(u.id))
          .toList();
      result[child] = responsibles;
    }
    return result;
  }

  // Getter para obter o mapa de responsáveis das crianças ativas da empresa selecionada
  Map<Child, List<User>> get activeChildrenWithResponsibles {
    // companyId deve ser passado externamente ou via outro controller
    // Aqui retorna vazio por padrão
    return {};
  }
}