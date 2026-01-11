import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/model/base_user.dart';
import 'package:kids_space/model/company.dart';
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
    final loggedCollaborator = _collaboratorController.loggedCollaborator;
    if (loggedCollaborator != null) {
      final companyId = loggedCollaborator.companyId;
      if (companyId != null) {
        final company = _companyController.getCompanyById(companyId);
        if (company != null) {
          _companyController.selectCompany(company);
          Navigator.pushReplacementNamed(context, '/app_bottom_nav');
          return;
        }
      }
      Navigator.pushReplacementNamed(context, '/company_selection');
    } else {
      Navigator.pushReplacementNamed(context, '/company_selection');
    }
  }
}
