import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/model/base_user.dart';
import '../../controller/auth_controller.dart';
import '../../controller/company_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController _authController = GetIt.I<AuthController>();
  final CompanyController _companyController = GetIt.I<CompanyController>();
  final CollaboratorController _collaboratorController = GetIt.I<CollaboratorController>();

  @override
  void initState() {
    super.initState();
    _startSplashFlow();
  }

  Future<void> _startSplashFlow() async {
    await _loadCompanies();
    // Verifica sessão ao iniciar: se inválida, desloga e direciona para seleção de company
    final valid = await _authController.ensureSessionValid();
    if (!valid) {
      try { await _authController.logout(); } catch (_) {}
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (c) => AlertDialog(
          title: const Text('Sessão expirada'),
          content: const Text('Sua sessão expirou. Faça login novamente.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(c).pop();
                Navigator.of(context).pushNamedAndRemoveUntil('/company_selection', (route) => false);
              },
              child: const Text('OK'),
            )
          ],
        ),
      );
      return;
    }
    await _checkLoggedUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.child_care, size: 80),
            const SizedBox(height: 24),
            Text(
              'Kids Space',
            ),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Future<void> _loadCompanies() async {
    await _companyController.loadCompanies();
  }

  Future<void> _checkLoggedUser() async {
    await _authController.checkLoggedUser();
      // refresh collaborator from API to ensure latest fields (roles/userType, companyId, etc.)
      var loggedCollaborator = _collaboratorController.loggedCollaborator;
      try {
        if (loggedCollaborator != null && loggedCollaborator.id != null) {
          final refreshed = await _collaboratorController.getCollaboratorById(loggedCollaborator.id!);
          if (refreshed != null) {
            await _collaboratorController.setLoggedCollaborator(refreshed);
            loggedCollaborator = refreshed;
          }
        }
      } catch (e) {
        debugPrint('Failed to refresh logged collaborator: $e');
      }
    if (!mounted) return;
    if (loggedCollaborator != null) {
      final companyId = loggedCollaborator.companyId;
      if (companyId != null) {
        final company = _companyController.getCompanyById(companyId);
        if (company != null) {
          _companyController.selectCompany(company);
          if (!mounted) return;
          loggedCollaborator.userType == UserType.companyAdmin ? 
          Navigator.pushReplacementNamed(context, '/admin_panel')
          : Navigator.pushReplacementNamed(context, '/app_bottom_nav');
          return;
        }
      }
      Navigator.pushReplacementNamed(context, '/company_selection');
      return;
    }
    Navigator.pushReplacementNamed(context, '/company_selection');
  }
}
