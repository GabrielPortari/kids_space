import '../model/child.dart';
import '../service/child_service.dart';
import '../model/user.dart';
import 'base_controller.dart';

class ChildController extends BaseController {
  final ChildService _childService = ChildService();

  List<Child> activeCheckedInChildren(String companyId) => _childService.getActiveCheckedInChildren(companyId);

  // Atualiza os responsáveis de uma criança pelo id
  bool updateResponsibleUsers(String childId, List<String> newResponsibleUserIds) {
    return true;
  }
  // Retorna um mapa de childId para lista de responsáveis (User)
  Map<String, List<User>> getChildrenWithResponsibles(List<Child> children) {
    return {};
  }

  // Getter para obter o mapa de responsáveis das crianças ativas da empresa selecionada
  // Retorna mapa por childId
  Map<String, List<User>> get activeChildrenWithResponsibles {
    return {};
  }

  // Atualiza uma criança (delegando ao serviço)
  Future<bool> updateChild(Child child) async{
    return true;
  }

  // Expõe busca de criança por id delegando ao serviço
  Child? getChildById(String? id) {
    return null;
  }

  // Expõe exclusão de criança delegando ao serviço
  Future<bool> deleteChild(String childId) async {
    return await _childService.deleteChild(childId);
  }

  // Busca crianças da empresa (delegando ao serviço)
  Future<List<Child>> getChildrenByCompanyId(String companyId) async {
    return await _childService.getChildrenByCompanyId(companyId);
  }
}