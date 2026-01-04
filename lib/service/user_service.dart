import '../model/user.dart';
import '../model/mock/model_mock.dart';
import 'dart:developer' as developer;

class UserService {
	// Simula busca de usuário por ID
	User? getUserById(String id) {
		developer.log('getUserById called: id=$id', name: 'UserService');
		try {
			final found = mockUsers.firstWhere((user) => user.id == id);
			developer.log('getUserById found id=${found.id}', name: 'UserService');
			return found;
		} catch (e) {
			developer.log('getUserById not found: id=$id', name: 'UserService');
			return null;
		}
	}

	Future<List<User>> getUsersByCompanyId(String companyId) async {
    developer.log('getUsersByCompanyId called: companyId=$companyId', name: 'UserService');
    await Future.delayed(const Duration(milliseconds: 300));
		final result = mockUsers.where((user) => user.companyId == companyId).toList();
		developer.log('getUsersByCompanyId returning ${result.length} users for companyId=$companyId', name: 'UserService');
		return result;
	}

  Future<bool> deleteUser(String id) async {
    developer.log('deleteUser called: id=$id', name: 'UserService');
    await Future.delayed(const Duration(milliseconds: 300));
    developer.log('deleteUser returning true for id=$id', name: 'UserService');
    // Simula exclusão bem-sucedida
    return true;
  }

  Future<bool> updateUser(User user) async {
    developer.log('updateUser called: id=${user.id}', name: 'UserService');
    await Future.delayed(const Duration(milliseconds: 300));
    developer.log('updateUser returning true for id=${user.id}', name: 'UserService');
    // Simula atualização do usuário
    return true;
  }

}