import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/util/localization_service.dart';

class RegisterCompanyScreen extends StatefulWidget {
  const RegisterCompanyScreen({Key? key}) : super(key: key);

  @override
  State<RegisterCompanyScreen> createState() => _RegisterCompanyScreenState();
}

class _RegisterCompanyScreenState extends State<RegisterCompanyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _legalNameCtrl = TextEditingController();
  final _cnpjCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _complementCtrl = TextEditingController();
  final _neighborhoodCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _zipcodeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _loading = false;
  bool _passwordVisible = false;

  final AuthController _authController = GetIt.I<AuthController>();

  @override
  void dispose() {
    for (final c in [
      _nameCtrl, _legalNameCtrl, _cnpjCtrl, _addressCtrl, _numberCtrl,
      _complementCtrl, _neighborhoodCtrl, _cityCtrl, _stateCtrl,
      _zipcodeCtrl, _emailCtrl, _contactCtrl, _passwordCtrl,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final ok = await _authController.signupCompany({
      'name': _nameCtrl.text.trim(),
      'legalName': _legalNameCtrl.text.trim(),
      'cnpj': _cnpjCtrl.text.trim(),
      'contact': _contactCtrl.text.trim(),
      'email': _emailCtrl.text.trim(),
      'password': _passwordCtrl.text,
      'address': {
        'address': _addressCtrl.text.trim(),
        'number': _numberCtrl.text.trim(),
        'complement': _complementCtrl.text.trim(),
        'neighborhood': _neighborhoodCtrl.text.trim(),
        'city': _cityCtrl.text.trim(),
        'state': _stateCtrl.text.trim(),
        'zipcode': _zipcodeCtrl.text.trim(),
      },
    });
    if (!mounted) return;
    setState(() => _loading = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate('register.success'))),
      );
      Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(translate('register.failed'))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(translate('register.title')),
        leading: const BackButton(),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 80),
              children: [
                // ── Dados da empresa ─────────────────────────────────────────
                _SectionHeader(label: translate('profile.personal_title')),
                const SizedBox(height: 12),
                _FormCard(
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: InputDecoration(
                        labelText: '${translate('company.name')} *',
                        prefixIcon: const Icon(Icons.business_rounded),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? translate('validation.required')
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _legalNameCtrl,
                      decoration: InputDecoration(
                        labelText: translate('company.legal_name'),
                        prefixIcon: const Icon(Icons.description_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cnpjCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: translate('company.cnpj'),
                        prefixIcon: const Icon(Icons.numbers_rounded),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _contactCtrl,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        labelText: translate('company.contact'),
                        prefixIcon: const Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        labelText: '${translate('company.email')} *',
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? translate('validation.required')
                          : null,
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Endereço ─────────────────────────────────────────────────
                _SectionHeader(label: translate('profile.address_title')),
                const SizedBox(height: 12),
                _FormCard(
                  children: [
                    TextFormField(
                      controller: _addressCtrl,
                      decoration: InputDecoration(
                        labelText: translate('company.address'),
                        prefixIcon: const Icon(Icons.home_outlined),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _numberCtrl,
                            decoration: InputDecoration(
                              labelText: translate('company.number'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 4,
                          child: TextFormField(
                            controller: _complementCtrl,
                            decoration: InputDecoration(
                              labelText: translate('company.complement'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _neighborhoodCtrl,
                      decoration: InputDecoration(
                        labelText: translate('company.neighborhood'),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: TextFormField(
                            controller: _cityCtrl,
                            decoration: InputDecoration(
                              labelText: translate('company.city'),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _stateCtrl,
                            textCapitalization: TextCapitalization.characters,
                            decoration: InputDecoration(
                              labelText: translate('company.state'),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _zipcodeCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: translate('company.zipcode'),
                        prefixIcon: const Icon(Icons.local_post_office_outlined),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ── Acesso ───────────────────────────────────────────────────
                _SectionHeader(label: 'Acesso'),
                const SizedBox(height: 12),
                _FormCard(
                  children: [
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: !_passwordVisible,
                      decoration: InputDecoration(
                        labelText: '${translate('register.password')} *',
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
                        ),
                      ),
                      validator: (v) => (v == null || v.length < 6)
                          ? translate('validation.password_length')
                          : null,
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                FilledButton(
                  onPressed: _loading ? null : _submit,
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
                          translate('register.submit'),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) => Text(
    label.toUpperCase(),
    style: const TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w700,
      color: Color(0xFF9AA3B5),
      letterSpacing: 0.8,
    ),
  );
}

class _FormCard extends StatelessWidget {
  final List<Widget> children;
  const _FormCard({required this.children});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFEEF1F7)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: children,
    ),
  );
}
