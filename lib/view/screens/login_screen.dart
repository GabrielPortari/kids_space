import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/model/base_user.dart';
import 'package:kids_space/view/design_system/app_button.dart';
import 'package:kids_space/view/design_system/app_card.dart';
import 'package:kids_space/view/design_system/app_text.dart';
import 'package:kids_space/view/design_system/app_textfield.dart';
import 'package:kids_space/util/localization_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthController _authController = GetIt.I<AuthController>();
  final CollaboratorController _collaboratorController = GetIt.I<CollaboratorController>();
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final success = await _authController.login(email, password);
    setState(() => _loading = false);
    if (success) {
      
      final logged = _collaboratorController.loggedCollaborator;
      if (logged != null && logged.userType == UserType.companyAdmin) {
        Navigator.pushNamedAndRemoveUntil(context, '/admin_panel', (route) => false);
      } else {
        Navigator.pushNamedAndRemoveUntil(context, '/app_bottom_nav', (route) => false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate('login.invalid_credentials'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final company = GetIt.I<CompanyController>().companySelected;
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('login.title', namedArgs: {'company': company?.fantasyName ?? translate('company.default_name')})),
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
                      _buildWelcome(company?.fantasyName ?? ''),
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
    return TextHeaderLarge(translate('login.welcome', namedArgs: {'company': companyName ?? ''}));
  }

  Widget _emailField() {
    return AppTextField(
      controller: _emailController,
      labelText: translate('login.email_label'),
      hintText: translate('login.email_hint'),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _passwordField() {
    return AppTextField(
      controller: _passwordController,
      obscureText: true,
      labelText: translate('login.password_label'),
      hintText: translate('login.password_hint'),
    );
  }

  Widget _loginButton() {
    return AppButton(
      text: translate('login.login_button'),
      onPressed: _loading ? null : _login
    );
  }
}
