import '../model/child.dart';
import 'dart:developer' as developer;

// Serviço de crianças
class ChildService {
  // Retorna crianças com check-in ativo (isActive == true) para uma empresa
  List<Child> getActiveCheckedInChildren(String companyId) {
    return [];
  }
  
  // Busca uma criança pelo id
  Child? getChildById(String childId) {
    return null;
  }

  // Adiciona uma criança (mock persistence)
  Future<bool> addChild(Child child) async {
    return true;
  }

  // Atualiza uma criança existente pelo id (mock persistence)
  Future<bool> updateChild(Child child) async {
    return true;
  }

  // Remove uma criança pelo id (mock persistence)
  Future<bool> deleteChild(String childId) async {
    return true;
  }

  // Busca todas as crianças da empresa (mock async)
  Future<List<Child>> getChildrenByCompanyId(String companyId) async {
    return [];
  }
}
