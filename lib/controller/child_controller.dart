import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/user_controller.dart';
import 'package:mobx/mobx.dart';

import '../model/child.dart';
import '../service/child_service.dart';
import '../model/user.dart';
import 'base_controller.dart';

part 'child_controller.g.dart';
class ChildController = _ChildController with _$ChildController;

abstract class _ChildController extends BaseController with Store {
  final ChildService _childService;
  UserController get _userController => GetIt.I.get<UserController>();
  _ChildController(this._childService);
  
  @observable
  String childFilter = '';
  @computed
  List<Child> get filteredChildren {
    final filter = childFilter.toLowerCase();
    if (filter.isEmpty) {
      return children;
    } else {
      return children
          .where((u) =>
              (u.name?.toLowerCase().contains(filter) ?? false) ||
              (u.email?.toLowerCase().contains(filter) ?? false) ||
              (u.document?.toLowerCase().contains(filter) ?? false))
          .toList();
    }
  }

  // Retorna um mapa de childId para lista de responsáveis (User)
  Map<String, List<User>> getChildrenWithResponsibles(List<Child> children) {
    Map<String, List<User>> result = {};
    for (final child in children) {
      List<String>? responsibleIds = child.responsibleUserIds;
      if(responsibleIds != null){
        for(final id in responsibleIds) {
          for(final user in _userController.users) {
            // associate only matching users
            if (user.id == id) {
              result.putIfAbsent(child.id!, () => []).add(user);
            }
          }
        }
      }
    }
    return result;
  }
  
  Map<String, List<User>> get activeChildrenWithResponsibles { 
    return {};
  }

  // Atualiza uma criança (delegando ao serviço)
  Future<bool> updateChild(Child? child) async{
    if(child == null) return false;
    return await _childService.updateChild(child);
  }

  /// Synchronous cache-first getter. Returns cached `Child` if present.
  /// If not present, triggers a background fetch (`fetchChildById`) and returns null.
  Child? getChildById(String? id) {
    if (id == null) return null;
    final local = getChildFromCache(id);
    if (local != null) return local;
    // Fire-and-forget fetch to populate cache for subsequent calls
    fetchChildById(id);
    return null;
  }

  /// Async fetch that queries the service and updates local cache.
  Future<Child?> fetchChildById(String? id) async {
    if (id == null) return null;
    final fetched = await _childService.getChildById(id);
    if (fetched != null) {
      final idx = children.indexWhere((c) => c.id == fetched.id);
      if (idx >= 0) {
        final newList = List<Child>.from(children);
        newList[idx] = fetched;
        children = newList;
      } else {
        children = [...children, fetched];
      }
      // deduplicate children by id and assign to trigger observers
      final Map<String, Child> uniq = {};
      for (final c in children) {
        if (c.id != null) uniq[c.id!] = c;
      }
      children = uniq.values.toList();
    }
    return fetched;
  }

  /// Synchronous cache-only lookup. Returns null if not present locally.
  Child? getChildFromCache(String? id) {
    if (id == null) return null;
    try {
      return children.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  // Expõe exclusão de criança delegando ao serviço
  Future<bool> deleteChild(String? childId) async {
    if (childId == null) return false;
    return await _childService.deleteChild(childId);
  }

  /// Cria uma nova criança associada a um responsável (parentId).
  /// Retorna true se sucesso.
  Future<bool> registerChild(String parentId, Child child) async {
    try {
      final success = await _childService.registerChild(child, parentId);
      if (success) {
        // optional: add to cache local for immediate feedback (assign to trigger MobX)
        children = [...children, child];
      }
      return success;
    } catch (e) {
      return false;
    }
  }

  @observable
  bool refreshLoading = false;
	@observable
	List<Child> children = [];
  // Busca crianças da empresa (delegando ao serviço)
  Future<void> getChildrenByCompanyId(String? companyId) async {
    if (companyId == null) return;
    refreshLoading = true;
    try {
      final list = await _childService.getChildrenByCompanyId(companyId);
      // deduplicate by id and assign to trigger MobX observers
      final Map<String, Child> byId = {};
      for (final c in list) {
        if (c.id != null) byId[c.id!] = c;
      }
      final unique = byId.values.toList();
      children = unique;
    } finally {
      refreshLoading = false;
    }
  }

  /// Refresh children list for a company (keeps same behavior as getChildrenByCompanyId).
  Future<void> refreshChildrenForCompany(String? companyId) async {
    await getChildrenByCompanyId(companyId);
  }

  /// Returns the children currently marked as active for the given company.
  List<Child> activeCheckedInChildren(String? companyId) {
    if (companyId == null) return [];
    return children.where((c) => c.companyId == companyId && (c.checkedIn ?? false)).toList();
  }

  /// Compatibility wrapper used in some places expecting a "computed" style method.
  List<Child> activeCheckedInChildrenComputed(String? companyId) => activeCheckedInChildren(companyId);
}