import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/service/collaborator_service.dart';
import '../service/auth_service.dart';
import '../service/api_client.dart';
import 'dart:developer' as developer;

class AuthController {
  AuthService? _authService;
  final CollaboratorService _collaboratorService = GetIt.I<CollaboratorService>();
  final CollaboratorController _collaboratorController = GetIt.I<CollaboratorController>();

  bool isLoading = false;
  String? error;

  AuthController({AuthService? authService}) : _authService = authService;

  AuthService get _auth => _authService ??= AuthService(ApiClient().dio);

  /// Tenta autenticar e, em caso de sucesso, armazena o colaborador logado.
  Future<bool> login(String email, String password) async {
    developer.log('AuthController.login start', name: 'AuthController');
    isLoading = true;
    error = null;
    try {
      final success = await _auth.login(email, password);
      if (!success) {
        await _collaboratorController.clearLoggedCollaborator();
        error = 'Credenciais inválidas';
        developer.log('AuthController.login failed: $error', name: 'AuthController');
        return false;
      }

      // Ensure FirebaseAuth session exists before reading Firestore.
      // Try signing in via Firebase (preferred) and fall back to simple query.
      Collaborator? collaborator;
      try {
        collaborator = await _collaboratorService.loginCollaborator(email, password);
      } catch (_) {
        collaborator = null;
      }
      if (collaborator == null) {
        collaborator = await _collaboratorService.getCollaboratorById(collaborator);
      }
      await _collaboratorController.setLoggedCollaborator(collaborator);
      developer.log('AuthController.login success for email=$email', name: 'AuthController');
      return collaborator != null;
    } catch (e) {
      error = e.toString();
      developer.log('AuthController.login error: $error', name: 'AuthController', error: e);
      await _collaboratorController.clearLoggedCollaborator();
      return false;
    } finally {
      isLoading = false;
    }
  }

  /// Faz logout: limpa tokens e colaborador salvo
  Future<void> logout() async {
    developer.log('AuthController.logout', name: 'AuthController');
    await _auth.logout();
    await _collaboratorController.clearLoggedCollaborator();
  }

  /// Verifica se existe usuário logado e, se necessário, tenta refresh do token.
  /// Retorna true se houver sessão válida carregada.
  Future<bool> checkLoggedUser() async {
    developer.log('AuthController.checkLoggedUser', name: 'AuthController');
    try {
      final idToken = await _auth.getIdToken();
      if (idToken == null) return false;

      // If AuthService does not expose an expiresAt, attempt a refresh and
      // require it to succeed to consider the session valid.
      final newToken = await _auth.refreshToken();
      if (newToken == null) {
        await logout();
        return false;
      }

      // carrega colaborador salvo localmente
      final loaded = await _collaboratorController.loadLoggedCollaboratorFromPrefs();
      developer.log('AuthController.checkLoggedUser loaded=$loaded', name: 'AuthController');
      return loaded;
    } catch (e) {
      developer.log('AuthController.checkLoggedUser error: $e', name: 'AuthController', error: e);
      return false;
    }
  }
}