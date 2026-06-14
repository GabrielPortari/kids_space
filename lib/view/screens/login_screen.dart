import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/util/localization_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _authController = GetIt.I<AuthController>();
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await _authController.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      final route = _authController.role == UserRole.company
          ? '/company_screen'
          : '/app_bottom_nav';
      Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate('login.invalid_credentials'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Logo ────────────────────────────────────────────────
                  Center(
                    child: SizedBox(
                      height: size.height < 600 ? 80 : 120,
                      child: Image.asset(
                        'assets/images/kids_space_logo.jpg',
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.child_care_rounded,
                          size: 72,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ── Título ───────────────────────────────────────────────
                  Text(
                    translate('login.welcome'),
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: const Color(0xFF0F1218),
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    translate('login.title'),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF495267),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // ── Card do formulário ───────────────────────────────────
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEEF1F7)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // E-mail
                          TextFormField(
                            controller: _emailCtrl,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            autocorrect: false,
                            decoration: InputDecoration(
                              labelText: translate('login.email_label'),
                              hintText: translate('login.email_hint'),
                              prefixIcon: const Icon(Icons.email_outlined),
                            ),
                            validator: (v) =>
                                (v == null || v.trim().isEmpty)
                                ? translate('validation.required')
                                : null,
                          ),
                          const SizedBox(height: 16),

                          // Senha
                          TextFormField(
                            controller: _passwordCtrl,
                            obscureText: !_passwordVisible,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _loading ? null : _login(),
                            decoration: InputDecoration(
                              labelText: translate('login.password_label'),
                              hintText: translate('login.password_hint'),
                              prefixIcon: const Icon(Icons.lock_outline_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _passwordVisible
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                ),
                                onPressed: () => setState(
                                  () => _passwordVisible = !_passwordVisible,
                                ),
                                tooltip: _passwordVisible
                                    ? 'Ocultar senha'
                                    : 'Mostrar senha',
                              ),
                            ),
                            validator: (v) =>
                                (v == null || v.isEmpty)
                                ? translate('validation.required')
                                : null,
                          ),
                          const SizedBox(height: 8),

                          // Esqueci a senha
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _showForgotPasswordDialog,
                              style: TextButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: const Size(0, 36),
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(translate('login.forgot_password')),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Botão entrar
                          FilledButton(
                            onPressed: _loading ? null : _login,
                            style: FilledButton.styleFrom(
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: _loading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    translate('login.login_button'),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                ),
                                child: Text(
                                  'ou',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(
                                        color: const Color(0xFF9AA3B5),
                                      ),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton(
                            onPressed: () => Navigator.pushNamed(
                              context,
                              '/register_company',
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 52),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(translate('login.no_account')),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog() {
    final ctrl = TextEditingController();
    showDialog<void>(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(translate('login.forgot_password')),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
            labelText: translate('login.email_label'),
            hintText: translate('login.enter_email'),
            prefixIcon: const Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(c).pop(),
            child: Text(translate('buttons.cancel')),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(c).pop();
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
