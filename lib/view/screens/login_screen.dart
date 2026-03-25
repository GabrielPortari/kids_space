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
          '/admin_panel',
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
          SnackBar(
            content: Text(
              translate(
                'login.unknown_role',
                defaultText: 'Tipo de usuário desconhecido.',
              ),
            ),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            translate(
              'login.invalid_credentials',
              defaultText: 'Credenciais inválidas',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(translate('login.title', defaultText: 'Login')),
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
                      _buildWelcome(),
                      const SizedBox(height: 24),
                      _emailField(),
                      const SizedBox(height: 16),
                      _passwordField(),
                      const SizedBox(height: 16),
                      _loginButton(),
                      _extraActions(),
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
        errorBuilder: (context, error, stackTrace) =>
            const Icon(Icons.business, size: 80, color: Colors.deepPurple),
      ),
    );
  }

  Widget _buildWelcome() {
    return TextHeaderLarge(
      translate('login.welcome', defaultText: 'Bem-vindo!'),
    );
  }

  Widget _emailField() {
    return AppTextField(
      controller: _emailController,
      labelText: translate('login.email_label', defaultText: 'Email'),
      hintText: translate('login.email_hint', defaultText: 'Digite seu e-mail'),
      keyboardType: TextInputType.emailAddress,
    );
  }

  Widget _passwordField() {
    return AppTextField(
      controller: _passwordController,
      obscureText: true,
      labelText: translate('login.password_label', defaultText: 'Senha'),
      hintText: translate(
        'login.password_hint',
        defaultText: 'Digite sua senha',
      ),
    );
  }

  Widget _loginButton() {
    return AppButton(
      text: translate('login.login_button', defaultText: 'Entrar'),
      onPressed: _loading ? null : _login,
    );
  }

  Widget _extraActions() {
    return Column(
      children: [
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register_company');
              },
              child: Text(
                translate(
                  'login.no_account',
                  defaultText: 'Não tem uma conta? Registrar',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                _showForgotPasswordDialog();
              },
              child: Text(
                translate(
                  'login.forgot_password',
                  defaultText: 'Esqueci minha senha',
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _showForgotPasswordDialog() {
    final _forgotController = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(
          translate(
            'login.forgot_password',
            defaultText: 'Esqueci minha senha',
          ),
        ),
        content: TextField(
          controller: _forgotController,
          decoration: InputDecoration(
            hintText: translate(
              'login.enter_email',
              defaultText: 'Digite seu e-mail',
            ),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: Text(translate('buttons.cancel', defaultText: 'Cancelar')),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(c).pop();
              // No backend endpoint implemented here; just show confirmation.
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    translate(
                      'login.forgot_sent',
                      defaultText:
                          'Se um usuário com esse e-mail existir, instruções foram enviadas.',
                    ),
                  ),
                ),
              );
            },
            child: Text(translate('buttons.ok', defaultText: 'OK')),
          ),
        ],
      ),
    );
  }
}
