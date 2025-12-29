import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/model/collaborator.dart' show UserType;
import 'package:kids_space/view/design_system/app_button.dart';
import 'package:kids_space/view/design_system/app_card.dart';
import 'package:kids_space/view/design_system/app_text.dart';
import 'package:kids_space/view/design_system/app_textfield.dart';

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
        Navigator.pushNamedAndRemoveUntil(context, '/admin_panel', (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/app_bottom_nav', (route) => false);
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
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: AppCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildLogo(),
                      const SizedBox(height: 24),
                      _buildWelcome(company?.name),
                      const SizedBox(height: 24),
                      _emailField(),
                      const SizedBox(height: 16),
                      _passwordField(),
                      const SizedBox(height: 16),
                      _loginButton(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
    return TextHeaderLarge('Bem-vindo${companyName != null ? " à $companyName" : ""}!');
  }

  Widget _emailField() {
    return AppTextField(
      controller: _emailController,
      labelText: 'E-mail',
      hintText: 'Digite seu e-mail',
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _passwordField() {
    return AppTextField(
      controller: _passwordController,
      obscureText: true,
      labelText: 'Senha',
      hintText: 'Digite sua senha',
    );
  }

  Widget _loginButton() {
    return AppButton(
      text: 'Entrar',
      onPressed: _loading ? null : _login
    );
  }
}
