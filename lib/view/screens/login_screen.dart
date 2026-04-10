import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/auth_controller.dart';
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
  bool _loading = false;

  void _login() async {
    setState(() => _loading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final success = await _authController.login(email, password);
    setState(() => _loading = false);
    if (success) {
      final role = _authController.role;
      if (role == UserRole.company) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/company_screen',
          (route) => false,
        );
      } else if (role == UserRole.admin || role == UserRole.master) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/admin_screen',
          (route) => false,
        );
      } else if (role == UserRole.collaborator) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/app_bottom_nav',
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(translate('login.unknown_role'))),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate('login.invalid_credentials'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(translate('login.title'))),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: AppCard(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildLogo(),
                        const SizedBox(height: 24),
                        _buildWelcome(),
                        const SizedBox(height: 24),
                        _emailField(),
                        const SizedBox(height: 16),
                        _passwordField(),
                        const SizedBox(height: 24),
                        _loginButton(),
                        const SizedBox(height: 8),
                        _registerButton(),
                        const SizedBox(height: 16),
                        _extraActions(),
                      ],
                    ),
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
      height: 180,
      child: Image.asset(
        'assets/images/kids_space_logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.business, size: 18, color: Colors.deepPurple),
      ),
    );
  }

  Widget _buildWelcome() {
    return TextHeaderLarge(translate('login.welcome'));
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
      style: ElevatedButton.styleFrom(minimumSize: const Size(200, 40)),
      onPressed: _loading ? null : _login,
    );
  }

  Widget _registerButton() {
    final colorScheme = Theme.of(context).colorScheme;

    return AppButton(
      text: translate('login.no_account'),
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(200, 40),
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.primary),
      ),
      onPressed: () => Navigator.pushNamed(context, '/register'),
    );
  }

  Widget _extraActions() {
    return Column(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                _showForgotPasswordDialog();
              },
              child: Text(translate('login.forgot_password')),
            ),
          ],
        ),
      ],
    );
  }

  void _showForgotPasswordDialog() {
    final forgotController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(translate('login.forgot_password')),
        content: TextField(
          controller: forgotController,
          decoration: InputDecoration(hintText: translate('login.enter_email')),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: Text(translate('buttons.cancel')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(c).pop();
              // No backend endpoint implemented here; just show confirmation.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(translate('login.forgot_sent'))),
              );
            },
            child: Text(translate('buttons.ok')),
          ),
        ],
      ),
    );
  }
}
