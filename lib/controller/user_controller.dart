import 'package:get_it/get_it.dart';
import 'package:mobx/mobx.dart';
import '../model/user.dart';
import '../service/user_service.dart';
import '../controller/child_controller.dart';
import 'base_controller.dart';

part 'user_controller.g.dart';

class UserController = _UserController with _$UserController;

abstract class _UserController extends BaseController with Store {
	final UserService _userService;
	ChildController get _childController => GetIt.I.get<ChildController>();

	_UserController(this._userService);

  @observable
  String userFilter = '';

  @computed
  List<User> get filteredUsers {
    final filter = userFilter.toLowerCase();
    if (filter.isEmpty) {
      return users;
    } else {
      return users
          .where((u) =>
              (u.name?.toLowerCase().contains(filter) ?? false) ||
              (u.email?.toLowerCase().contains(filter) ?? false) ||
              (u.document?.toLowerCase().contains(filter) ?? false))
          .toList();
    }
  }

	@observable
	String? selectedUserId;

	@computed
	User? get selectedUser {
		final id = selectedUserId;
		if (id == null) return null;
		try {
			return users.firstWhere((u) => u.id == id);
		} catch (_) {
			return null;
		}
	}

	User? get mSelectedUser => selectedUser;

	@observable
	ObservableList<User> users = ObservableList<User>();

  @observable
  bool refreshLoading = false;

	@action
	Future<void> refreshUsersForCompany(String? companyId) async {
    refreshLoading = true;
		if (companyId == null) {
			users.clear();
			refreshLoading = false;
			return;
		}

		final token = await getIdToken();
		final list = await _userService.getUsersByCompanyId(companyId, token: token);
		if (list.isEmpty) {
			users.clear();
			refreshLoading = false;
			return;
		}

		// deduplicate by id (preserve last occurrence) using a map
		final Map<String, User> byId = {};
		for (final u in list) {
			if (u.id != null) byId[u.id!] = u;
		}
		final unique = byId.values.toList();
		users
			..clear()
			..addAll(unique);
		refreshLoading = false;
	}


	User? getUserById(String id) {
		for (final u in users) {
			if (u.id == id) return u;
		}
		// try synchronous service cache if available
		try {
			final maybe = _userService.getUserById(id);
			if (maybe != null) return maybe;
		} catch (_) {}
		// trigger background fetch for later
		fetchUserById(id);
		return null;
	}

	/// Async fetch by id that queries service and updates local cache.
	Future<User?> fetchUserById(String id) async {
		final fetched = await _userService.fetchUserById(id);
		if (fetched == null) return null;
		final idx = users.indexWhere((u) => u.id == fetched.id);
		if (idx >= 0) {
			users[idx] = fetched;
		} else {
			users.add(fetched);
		}
		return fetched;
	}

	Future<List<User>> getUsersByCompanyId(String companyId) {
		return _userService.getUsersByCompanyId(companyId);
	}

	@action
  Future<bool> createUser(User user) async {
    final success = await _userService.createUser(user);
    return success;
  }

	@action
	Future<bool> deleteUser(String? id) async {
    if(id != null && id.isNotEmpty){
			// antes de excluir o usuário, verificar suas crianças
			final user = getUserById(id);
			final childIds = user?.childrenIds ?? [];
			for (final cid in childIds) {
				final child = _childController.getChildById(cid);
				if (child != null) {
					final responsibles = List<String>.from(child.responsibleUserIds ?? []);
					if (!responsibles.contains(id)) {
						if (responsibles.length > 1) {
							// apenas remover este id da lista de responsáveis da criança
							child.responsibleUserIds?.removeWhere((r) => r == id);
							_childController.updateChild(child);
						} else {
							// era o único responsável, excluir a criança também
							_childController.deleteChild(cid);
						}
					}
				}
			}

			final success = await _userService.deleteUser(id);
      
			return success;
    } else {
      return false;
    }
  }

	@action
	Future<bool> updateUser(User updated) async {
    String? id = updated.id;
		if(id != null && id.isNotEmpty){
      final success = await _userService.updateUser(updated);
			return success;
    } else {
      return false;
    }
	}
}
