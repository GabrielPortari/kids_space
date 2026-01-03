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

	Future<List<User>> getUsersByCompanyId(String companyId) async {
    await Future.delayed(Duration(milliseconds: 500));
		return mockUsers.where((user) => user.companyId == companyId).toList();
	}

  Future<bool> deleteUser(String id) async {
    await Future.delayed(Duration(milliseconds: 500));
    // Simula exclusão bem-sucedida
    return true;
  }

  Future<bool> updateUser(User user) async {
    await Future.delayed(Duration(milliseconds: 500));
    // Simula atualização do usuário
    return true;
  }

}