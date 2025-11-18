import '../model/child.dart';
import '../model/mock/model_mock.dart';

// Serviço de crianças
class ChildService {
  // Retorna crianças com check-in ativo (isActive == true) para uma empresa
  List<Child> getActiveCheckedInChildren(String companyId) {
    return mockChildren.where((child) => child.isActive && child.companyId == companyId).toList();
  }
  
  // Busca uma criança pelo id
  Child? getChildById(String childId) {
    for (final child in mockChildren) {
      if (child.id == childId) return child;
    }
    return null;
  }

  // Adiciona uma criança (mock persistence)
  void addChild(Child child) {
    mockChildren.add(child);
  }

  // Atualiza uma criança existente pelo id (mock persistence)
  void updateChild(Child child) {
    for (var i = 0; i < mockChildren.length; i++) {
      if (mockChildren[i].id == child.id) {
        mockChildren[i] = child;
        return;
      }
    }
  }
}
