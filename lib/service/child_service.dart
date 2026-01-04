import '../model/child.dart';
import '../model/mock/model_mock.dart';
import 'dart:developer' as developer;

// Serviço de crianças
class ChildService {
  // Retorna crianças com check-in ativo (isActive == true) para uma empresa
  List<Child> getActiveCheckedInChildren(String companyId) {
    developer.log('getActiveCheckedInChildren called: companyId=$companyId', name: 'ChildService');
    final result = mockChildren.where((child) => child.isActive! && child.companyId == companyId).toList();
    developer.log('getActiveCheckedInChildren returning ${result.length} children', name: 'ChildService');
    return result;
  }
  
  // Busca uma criança pelo id
  Child? getChildById(String childId) {
    developer.log('getChildById called: childId=$childId', name: 'ChildService');
    for (final child in mockChildren) {
      if (child.id == childId) {
        developer.log('getChildById found child: ${child.id}', name: 'ChildService');
        return child;
      }
    }
    developer.log('getChildById found no child for id: $childId', name: 'ChildService');
    return null;
  }

  // Adiciona uma criança (mock persistence)
  Future<bool> addChild(Child child) async {
    developer.log('addChild called: childId=${child.id}', name: 'ChildService');
    await Future.delayed(const Duration(milliseconds: 300));
    developer.log('addChild returning true for childId=${child.id}', name: 'ChildService');
    return true;
  }

  // Atualiza uma criança existente pelo id (mock persistence)
  Future<bool> updateChild(Child child) async {
    developer.log('updateChild called: childId=${child.id}', name: 'ChildService');
    await Future.delayed(const Duration(milliseconds: 300));
    developer.log('updateChild returning true for childId=${child.id}', name: 'ChildService');
    return true;
  }

  // Remove uma criança pelo id (mock persistence)
  Future<bool> deleteChild(String childId) async {
    developer.log('deleteChild called: childId=$childId', name: 'ChildService');
    await Future.delayed(const Duration(milliseconds: 300));
    developer.log('deleteChild returning true for childId=$childId', name: 'ChildService');
    return true;
  }

  // Busca todas as crianças da empresa (mock async)
  Future<List<Child>> getChildrenByCompanyId(String companyId) async {
    developer.log('getChildrenByCompanyId called: companyId=$companyId', name: 'ChildService');
    await Future.delayed(const Duration(milliseconds: 300));
    final result = mockChildren.where((child) => child.companyId == companyId).toList();
    developer.log('getChildrenByCompanyId returning ${result.length} children for companyId=$companyId', name: 'ChildService');
    return result;
  }
}
