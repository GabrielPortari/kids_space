import '../model/user.dart';

class UserService {
	// Simula busca de usuário por ID
	User? getUserById(String id) {
    return null;
	}

	Future<List<User>> getUsersByCompanyId(String companyId) async {
    return [];
	}

  Future<bool> deleteUser(String id) async {
    return true;
  }

  Future<bool> updateUser(User user) async {
    return true;
  }
}