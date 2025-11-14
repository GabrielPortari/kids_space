import 'package:mobx/mobx.dart';

import '../model/user.dart';
import '../service/user_service.dart';

part 'user_controller.g.dart';

class UserController = _UserController with _$UserController;

abstract class _UserController with Store {
	final UserService _userService = UserService();

	String? companyId;

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

	@action
	void refreshUsersForCompany(String? companyId) {
		this.companyId = companyId;
		if (companyId == null) {
			users.clear();
			return;
		}
		final list = _userService.getUsersByCompanyId(companyId);
		users
			..clear()
			..addAll(list);
	}

	// Convenience synchronous accessors (keeps compatibility with previous API)
	List<User> get usersByCompany => users.where((u) => u.companyId == companyId).toList();

	User? getUserById(String id) {
		// prefer local cache first
		try {
			return users.firstWhere((u) => u.id == id);
			} catch (_) {
				return _userService.getUserById(id);
		}
	}

	List<User> getUsersByCompanyId(String companyId) {
		return _userService.getUsersByCompanyId(companyId);
	}

	// Mutators that notify observers by mutating the ObservableList instance
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