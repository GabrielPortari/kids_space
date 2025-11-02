import '../model/user.dart';
import '../model/mock/model_mock.dart';

class UserService {
	// Simula busca de usuário por ID
	User? getUserById(String id) {
		try {
			return mockUsers.firstWhere((user) => user.id == id);
		} catch (e) {
			return null;
		}
	}

	List<User> getUsersByCompanyId(String companyId) {
		return mockUsers.where((user) => user.companyId == companyId).toList();
	}

}
