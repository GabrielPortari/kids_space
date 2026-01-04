// Serviço de colaboradores
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/model/mock/model_mock.dart';
import 'dart:developer' as developer;

class CollaboratorService {
  // Busca colaborador pelo email e senha
  Future<Collaborator?> loginCollaborator(String email, String password) async {
    developer.log('loginCollaborator called: email=$email', name: 'CollaboratorService');
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final found = mockCollaborators.firstWhere(
        (c) => c.email == email && c.password == password,
      );
      developer.log('loginCollaborator found id=${found.id}', name: 'CollaboratorService');
      return found;
    } catch (_) {
      developer.log('loginCollaborator not found for email=$email', name: 'CollaboratorService');
      return null;
    }
  }

  // Busca colaborador apenas pelo email
  Future<Collaborator?> getCollaboratorByEmail(String email) async {
    developer.log('getCollaboratorByEmail called: email=$email', name: 'CollaboratorService');
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final found = mockCollaborators.firstWhere(
        (c) => c.email == email,
      );
      developer.log('getCollaboratorByEmail found id=${found.id}', name: 'CollaboratorService');
      return found;
    } catch (_) {
      developer.log('getCollaboratorByEmail not found: email=$email', name: 'CollaboratorService');
      return null;
    }
  }

  Future<Collaborator?> getCollaboratorById(String id) async {
    developer.log('getCollaboratorById called: id=$id', name: 'CollaboratorService');
    await Future.delayed(const Duration(milliseconds: 300));
    try {
      final found = mockCollaborators.firstWhere((c) => c.id == id);
      developer.log('getCollaboratorById found id=${found.id}', name: 'CollaboratorService');
      return found;
    } catch (_) {
      developer.log('getCollaboratorById not found: id=$id', name: 'CollaboratorService');
      return null;
    }
  }

  Future<List<Collaborator>> getCollaboratorsByCompanyId(String companyId) async {
    developer.log('getCollaboratorsByCompanyId called: companyId=$companyId', name: 'CollaboratorService');
    await Future.delayed(const Duration(milliseconds: 300));
    final result = mockCollaborators.where((c) => c.companyId == companyId).toList();
    developer.log('getCollaboratorsByCompanyId returning ${result.length} collaborators for companyId=$companyId', name: 'CollaboratorService');
    return result;
  }

  Future<bool> deleteCollaborator(String id) async {
    developer.log('deleteCollaborator called: id=$id', name: 'CollaboratorService');
    await Future.delayed(const Duration(milliseconds: 300));
    developer.log('deleteCollaborator returning true for id=$id', name: 'CollaboratorService');
    // Simula exclusão bem-sucedida
    return true;
  }

  /// Atualiza um colaborador (mock persistence)
  Future<bool> updateCollaborator(Collaborator collaborator) async {
    developer.log('updateCollaborator called: id=${collaborator.id}', name: 'CollaboratorService');
    await Future.delayed(const Duration(milliseconds: 300));
    developer.log('updateCollaborator returning true for id=${collaborator.id}', name: 'CollaboratorService');
    return true;
  }
}
