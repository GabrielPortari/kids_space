import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/model/collaborator.dart';
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
    //_authController.logout();
    debugPrint('SplashScreen: initState -> starting splash flow');
    _startSplashFlow();
  }

  Future<void> _startSplashFlow() async {
    debugPrint('SplashScreen: _startSplashFlow -> begin');
    await _loadCompanies();
    await _checkLoggedUser();
    debugPrint('SplashScreen: _startSplashFlow -> end');
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
    debugPrint('SplashScreen: _loadCompanies -> loading companies');
    await _companyController.loadCompanies();
    try {
      final count = _companyController.companies.length;
      debugPrint('SplashScreen: _loadCompanies -> loaded $count companies');
    } catch (e) {
      debugPrint('SplashScreen: _loadCompanies -> error reading companies: $e');
    }
  }

  Future<void> _checkLoggedUser() async {
    debugPrint('SplashScreen: _checkLoggedUser -> checking persisted login');
    await _authController.checkLoggedUser();
    final loggedUser = _collaboratorController.loggedCollaborator;
    debugPrint('SplashScreen: _checkLoggedUser -> loggedUser present: ${loggedUser != null}');

    Company? company = _companyController.companySelected;

    if (loggedUser != null) {
      debugPrint('SplashScreen: _checkLoggedUser -> found logged user id=${loggedUser.id} email=${loggedUser.email} userType=${loggedUser.userType} companyId=${loggedUser.companyId}');
      try {
        company = _companyController.companies.firstWhere(
          (c) => c.id == loggedUser.companyId,
        );
        _companyController.selectCompany(company);
        debugPrint('SplashScreen: _checkLoggedUser -> selected company ${company.name} (id=${company.id})');
      } catch (e) {
        debugPrint('SplashScreen: _checkLoggedUser -> no matching company for user: $e');
        company = null;
      }
    }

    debugPrint('SplashScreen: _checkLoggedUser -> delaying for UX');
    await Future.delayed(const Duration(seconds: 3));

    if (loggedUser != null && company != null) {
      if (loggedUser.userType == UserType.admin) {
        debugPrint('SplashScreen: _checkLoggedUser -> navigating to /admin_panel for admin user');
        Navigator.pushReplacementNamed(context, '/admin_panel');
      } else {
        debugPrint('SplashScreen: _checkLoggedUser -> navigating to /app_bottom_nav for collaborator user');
        Navigator.pushReplacementNamed(context, '/app_bottom_nav');
      }
    } else {
      debugPrint('SplashScreen: _checkLoggedUser -> no logged user or no company; navigating to /company_selection');
      Navigator.pushReplacementNamed(context, '/company_selection');
    }
  }
}
