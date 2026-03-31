import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../controller/auth_controller.dart';
import 'package:kids_space/util/localization_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthController _authController = GetIt.I<AuthController>();

  @override
  void initState() {
    super.initState();
    _startSplashFlow();
  }

  Future<void> _startSplashFlow() async {
    // Verifica sessão ao iniciar: se inválida, desloga e direciona para seleção de company
    final valid = await _authController.ensureSessionValid();
    if (!valid) {
      try {
        await _authController.logout();
      } catch (_) {}
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (c) => AlertDialog(
          title: Text(translate('splash.session_expired_title')),
          content: Text(translate('splash.session_expired_message')),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(c).pop();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              },
              child: Text(translate('buttons.ok')),
            ),
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
            Text('Kids Space'),
            const SizedBox(height: 16),
            const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Future<void> _checkLoggedUser() async {
    await _authController.checkLoggedUser();
    if (!mounted) return;
    final role = _authController.role;
    if (role == UserRole.company) {
      Navigator.pushReplacementNamed(context, '/admin_panel');
      return;
    }
    if (role == UserRole.collaborator) {
      Navigator.pushReplacementNamed(context, '/app_bottom_nav');
      return;
    }
    Navigator.pushReplacementNamed(context, '/login');
  }
}
