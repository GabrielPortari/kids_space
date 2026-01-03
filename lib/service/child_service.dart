import '../model/child.dart';
import '../model/mock/model_mock.dart';

// Serviço de crianças
class ChildService {
  // Retorna crianças com check-in ativo (isActive == true) para uma empresa
  List<Child> getActiveCheckedInChildren(String companyId) {
    return mockChildren.where((child) => child.isActive! && child.companyId == companyId).toList();
  }
  
  // Busca uma criança pelo id
  Child? getChildById(String childId) {
    for (final child in mockChildren) {
      if (child.id == childId) return child;
    }
    return null;
  }

  // Adiciona uma criança (mock persistence)
  Future<bool> addChild(Child child) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  // Atualiza uma criança existente pelo id (mock persistence)
  Future<bool> updateChild(Child child) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  // Remove uma criança pelo id (mock persistence)
  Future<bool> deleteChild(String childId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return true;
  }

  // Busca todas as crianças da empresa (mock async)
  Future<List<Child>> getChildrenByCompanyId(String companyId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return mockChildren.where((child) => child.companyId == companyId).toList();
  }
}
