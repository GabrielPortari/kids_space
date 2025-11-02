import '../model/user.dart';
import '../service/user_service.dart';

class UserController {
	final UserService _userService = UserService();

	String? companyId;

	// Armazena o id do usuário selecionado
	String? _selectedUserId;

	// Getter e setter para o id do usuário selecionado
	String? get selectedUserId => _selectedUserId;
	set selectedUserId(String? id) => _selectedUserId = id;

	User? getUserById(String id) {
		return _userService.getUserById(id);
	}

	// Getter para obter usuários da empresa atual
	List<User> get usersByCompany {
		if (companyId == null) return [];
		return _userService.getUsersByCompanyId(companyId!);
	}

	List<User> getUsersByCompanyId(String companyId) {
		return _userService.getUsersByCompanyId(companyId);
	}
}