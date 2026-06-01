import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import '../../controller/auth_controller.dart';
import 'package:kids_space/util/localization_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  final AuthController _authController = GetIt.I<AuthController>();
  late final AnimationController _animCtrl;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _animCtrl.forward();
    _startSplashFlow();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _startSplashFlow() async {
    await _authController.loadFromStorage();
    final hasSession = _authController.idToken != null;
    if (!hasSession) {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    final valid = await _authController.ensureSessionValid();
    if (!valid) {
      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (c) => AlertDialog(
          title: Text(translate('splash.session_expired_title')),
          content: Text(translate('splash.session_expired_message')),
          actions: [
            FilledButton(
              onPressed: () {
                Navigator.of(c).pop();
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (_) => false);
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

  Future<void> _checkLoggedUser() async {
    await _authController.checkLoggedUser();
    if (!mounted) return;
    final route = _authController.role == UserRole.company
        ? '/company_screen'
        : _authController.role == UserRole.collaborator
        ? '/app_bottom_nav'
        : '/login';
    Navigator.pushReplacementNamed(context, route);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: scheme.primary,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo container com sombra suave sobre fundo primário
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 32,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Image.asset(
                  'assets/images/kids_space_logo.jpg',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.child_care_rounded,
                    size: 64,
                    color: scheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // App name
              Text(
                'Kids Space',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Gestão de presença infantil',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.75),
                ),
              ),
              const SizedBox(height: 48),

              // Loading indicator branco sobre fundo primário
              SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
