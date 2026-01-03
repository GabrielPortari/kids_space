// Serviço de colaboradores
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/model/mock/model_mock.dart';

class CollaboratorService {
  // Busca colaborador pelo email e senha
  Future<Collaborator?> loginCollaborator(String email, String password) async {
    await Future.delayed(Duration(milliseconds: 500));
    try {
      return mockCollaborators.firstWhere(
        (c) => c.email == email && c.password == password,
      );
    } catch (_) {
      return null;
    }
  }

  // Busca colaborador apenas pelo email
  Future<Collaborator?> getCollaboratorByEmail(String email) async {
    await Future.delayed(Duration(milliseconds: 500));
    try {
      return mockCollaborators.firstWhere(
        (c) => c.email == email,
      );
    } catch (_) {
      return null;
    }
  }

  Future<Collaborator?> getCollaboratorById(String id) async {
    await Future.delayed(Duration(milliseconds: 200));
    try {
      return mockCollaborators.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<List<Collaborator>> getCollaboratorsByCompanyId(String companyId) async {
    await Future.delayed(Duration(milliseconds: 500));
    return mockCollaborators.where((c) => c.companyId == companyId).toList();
  }

  Future<bool> deleteCollaborator(String id) async {
    await Future.delayed(Duration(milliseconds: 500));
    // Simula exclusão bem-sucedida
    return true;
  }
}
