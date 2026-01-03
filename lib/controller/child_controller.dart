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
      child.responsibleUserIds?..clear()..addAll(newResponsibleUserIds);
    }
  }
  // Retorna um mapa de childId para lista de responsáveis (User)
  Map<String, List<User>> getChildrenWithResponsibles(List<Child> children) {
    final Map<String, List<User>> result = {};
    for (final child in children) {
      final responsibles = mockUsers
          .where((u) => child.responsibleUserIds?.contains(u.id) ?? false).toList();
      result[child.id ?? '0'] = responsibles;
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
  Future<bool> updateChild(Child child) async{
    String? id = child.id;
    if(id != null && id.isNotEmpty){
      bool success = await _childService.updateChild(child);
      return success;
    }else{
      return false;
    }
  }

  // Expõe busca de criança por id delegando ao serviço
  Future<Child?> getChildById(String? id) async {
    if(id != null && id.isNotEmpty){
      Child? children = await _childService.getChildById(id);
      return children;
    }else{
      return null;
    }
  }

  // Expõe exclusão de criança delegando ao serviço
  Future<bool> deleteChild(String childId) {
    return _childService.deleteChild(childId);
  }

  // Busca crianças da empresa (delegando ao serviço)
  Future<List<Child>> getChildrenByCompanyId(String companyId) async {
    return await _childService.getChildrenByCompanyId(companyId);
  }
}