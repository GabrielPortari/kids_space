import 'package:mobx/mobx.dart';

import '../model/user.dart';
import '../service/user_service.dart';

part 'user_controller.g.dart';

class UserController = _UserController with _$UserController;

abstract class _UserController with Store {
	final UserService _userService = UserService();

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
              u.name.toLowerCase().contains(filter) ||
              u.email.toLowerCase().contains(filter) ||
              u.document.toLowerCase().contains(filter))
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
		final list = await _userService.getUsersByCompanyId(companyId);
		users
			..clear()
			..addAll(list);
    refreshLoading = false;
	}


	User? getUserById(String id) {
		try {
			return users.firstWhere((u) => u.id == id);
			} catch (_) {
				return _userService.getUserById(id);
		}
	}

	Future<List<User>> getUsersByCompanyId(String companyId) {
		return _userService.getUsersByCompanyId(companyId);
	}

	@action
	void addUser(User user) => users.add(user);

	@action
	void removeUserById(String id) => users.removeWhere((u) => u.id == id);

	@action
	void updateUser(User updated) {
		final i = users.indexWhere((u) => u.id == updated.id);
		if (i >= 0) {
			users[i] = updated;
		}
	}
}