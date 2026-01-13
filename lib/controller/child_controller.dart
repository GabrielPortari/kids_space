import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/attendance_controller.dart';
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
	ObservableList<Child> children = ObservableList<Child>();

  @observable
  bool refreshLoading = false;

  @action
	Future<void> refreshChildrenForCompany(String? companyId) async {
    refreshLoading = true;
		if (companyId == null) {
			children.clear();
			refreshLoading = false;
			return;
		}
		final token = await getIdToken();
		final list = await _childService.getChildrenByCompanyId(companyId, token: token);
		children
			..clear()
			..addAll(list);
    refreshLoading = false;
	}

  List<Child> activeCheckedInChildren(String companyId) => _childService.getActiveCheckedInChildren(companyId);

  // Compute active checked-in children using AttendanceController's activeCheckins
  List<Child> activeCheckedInChildrenComputed(String companyId) {
    try {
      final attendanceController = GetIt.I.get<AttendanceController>();
      final active = (attendanceController.activeCheckins ?? []).map((a) => a.childId).whereType<String>().toSet();
      return children.where((c) => c.id != null && active.contains(c.id)).toList();
    } catch (_) {
      // fallback to service if attendanceController not available
      return _childService.getActiveCheckedInChildren(companyId);
    }
  }

  // Atualiza os responsáveis de uma criança pelo id
  bool updateResponsibleUsers(String childId, List<String> newResponsibleUserIds) {
    return true;
  }

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
  Future<bool> updateChild(Child child) async{
    return true;
  }

  // Expõe busca de criança por id delegando ao serviço
  Child? getChildById(String? id) {
    if(id == null || id.isEmpty) return null;
    return children.firstWhere((c) => c.id == id, orElse: () => _childService.getChildById(id)!);
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