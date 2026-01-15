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

  @observable
  bool refreshLoading = false;

  // Retorna um mapa de childId para lista de responsáveis (User)
  Map<String, List<User>> getChildrenWithResponsibles(List<Child> children) {
    Map<String, List<User>> result = {};
    for (final child in children) {
      List<String>? responsibleIds = child.responsibleUserIds;
      if(responsibleIds != null){
        for(final id in responsibleIds) {
          for(final user in _userController.users) {
            // lógica para associar usuários às crianças
            user.id == id;
            result.putIfAbsent(child.id!, () => []).add(user);
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
      final exists = children.any((c) => c.id == fetched.id);
      if (!exists) {
        children = [...children, fetched];
      }
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

	@observable
	List<Child> children = [];
  // Busca crianças da empresa (delegando ao serviço)
  Future<void> getChildrenByCompanyId(String? companyId) async {
    if (companyId == null) return;
    children = await _childService.getChildrenByCompanyId(companyId);
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