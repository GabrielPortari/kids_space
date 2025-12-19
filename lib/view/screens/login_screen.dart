import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/model/collaborator.dart' show UserType;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController = GetIt.I<AuthController>();
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final success = await _authController.login(email, password);
    setState(() => _loading = false);
    if (success) {
      final collabController = GetIt.I<CollaboratorController>();
      final logged = collabController.loggedCollaborator;
      if (logged != null && logged.userType == UserType.admin) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login como administrador. Redirecionando...')),
        );
        Navigator.pushReplacementNamed(context, '/admin_panel');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login realizado!')),
        );
        Navigator.pushReplacementNamed(context, '/app_bottom_nav');
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuário ou senha inválidos!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final company = GetIt.I<CompanyController>().companySelected;
    return Scaffold(
      appBar: AppBar(
        title: Text('Login - ${company?.name ?? "Empresa"}'),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildLogo(),
                    const SizedBox(height: 24),
                    _buildWelcome(company?.name),
                    const SizedBox(height: 32),
                    _emailField(),
                    const SizedBox(height: 16),
                    _passwordField(),
                    const SizedBox(height: 32),
                    _loginButton(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      height: 100,
      child: Image.asset(
        'assets/images/company_logo_placeholder.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => const Icon(Icons.business, size: 80, color: Colors.deepPurple),
      ),
    );
  }

  Widget _buildWelcome(String? companyName) {
    return Text(
      'Bem-vindo à ${companyName ?? "Empresa"}',
      style: Theme.of(context).textTheme.headlineSmall,
      textAlign: TextAlign.center,
    );
  }

  Widget _emailField() {
    return TextField(
      controller: _emailController,
      decoration: const InputDecoration(
        labelText: 'Usuário',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _passwordField() {
    return TextField(
      controller: _passwordController,
      obscureText: true,
      decoration: const InputDecoration(
        labelText: 'Senha',
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _loginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _loading ? null : _login,
        child: _loading
            ? const SizedBox(
                width: 24,
                height: 40,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Entrar'),
      ),
    );
  }
}
