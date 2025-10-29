import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../controller/auth_controller.dart';
import '../controller/company_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController _authController = GetIt.I<AuthController>();
  final CompanyController _companyController = GetIt.I<CompanyController>();

  @override
  void initState() {
    super.initState();
    _loadCompanies();
    _checkLoggedUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.child_care, size: 80, color: Colors.deepPurple),
            const SizedBox(height: 24),
            Text(
              'Kids Space',
              style: Theme.of(context).textTheme.headlineMedium,
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
    await Future.delayed(const Duration(seconds: 3));
    if (await _authController.checkLoggedUser()) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/company_selection');
    }
  }

}
