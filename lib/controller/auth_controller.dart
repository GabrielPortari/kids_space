import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/service/collaborator_service.dart';
import '../service/auth_service.dart';

class AuthController {
  final AuthService _authService = AuthService();
  final CollaboratorService _collaboratorService = CollaboratorService();
  final CollaboratorController _collaboratorController = GetIt.I<CollaboratorController>();

  /// Apenas autentica. Se sucesso, delega ao CollaboratorController para armazenar o colaborador logado.
  Future<bool> login(String email, String password) async {
    final success = await _authService.login(email, password);
    if (success) {
      final collaborator = await _collaboratorService.getCollaboratorByEmail(email);
      await _collaboratorController.setLoggedCollaborator(collaborator);
      return collaborator != null;
    } else {
      await _collaboratorController.clearLoggedCollaborator();
      return false;
    }
  }

  /// Faz logout e limpa colaborador logado
  Future<void> logout() async {
    await _collaboratorController.clearLoggedCollaborator();
  }

  /// Carrega colaborador salvo localmente (se existir)
  Future<bool> checkLoggedUser() async {
    return await _collaboratorController.loadLoggedCollaboratorFromPrefs();
  }
}