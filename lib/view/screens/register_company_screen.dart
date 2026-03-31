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
  final _nameController = TextEditingController();
  final _legalNameController = TextEditingController();
  final _cnpjController = TextEditingController();
  final _addressController = TextEditingController();
  final _numberController = TextEditingController();
  final _complementController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipcodeController = TextEditingController();
  final _emailController = TextEditingController();
  final _contactController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;

  final AuthController _authController = GetIt.I<AuthController>();

  @override
  void dispose() {
    _nameController.dispose();
    _legalNameController.dispose();
    _cnpjController.dispose();
    _addressController.dispose();
    _numberController.dispose();
    _complementController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipcodeController.dispose();
    _emailController.dispose();
    _contactController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final payload = {
      'name': _nameController.text.trim(),
      'legalName': _legalNameController.text.trim(),
      'cnpj': _cnpjController.text.trim(),
      'contact': _contactController.text.trim(),
      'email': _emailController.text.trim(),
      'password': _passwordController.text,
      'address': {
        'address': _addressController.text.trim(),
        'number': _numberController.text.trim(),
        'complement': _complementController.text.trim(),
        'neighborhood': _neighborhoodController.text.trim(),
        'city': _cityController.text.trim(),
        'state': _stateController.text.trim(),
        'zipcode': _zipcodeController.text.trim(),
      },
    };
    final ok = await _authController.signupCompany(payload);
    setState(() => _loading = false);
    if (ok) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(translate('register.success'))));
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(translate('register.failed'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(translate('register.title'))),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: translate('company.name'),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? translate('validation.required')
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _legalNameController,
                        decoration: InputDecoration(
                          labelText: translate('company.legal_name'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _cnpjController,
                        decoration: InputDecoration(
                          labelText: translate('company.cnpj'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: translate('company.address'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _numberController,
                              decoration: InputDecoration(
                                labelText: translate('company.number'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 4,
                            child: TextFormField(
                              controller: _complementController,
                              decoration: InputDecoration(
                                labelText: translate('company.complement'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _neighborhoodController,
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
                              controller: _cityController,
                              decoration: InputDecoration(
                                labelText: translate('company.city'),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _stateController,
                              decoration: InputDecoration(
                                labelText: translate('company.state'),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _zipcodeController,
                        decoration: InputDecoration(
                          labelText: translate('company.zipcode'),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _contactController,
                        decoration: InputDecoration(
                          labelText: translate('company.contact'),
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: translate('company.email'),
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) => (v == null || v.isEmpty)
                            ? translate('validation.required')
                            : null,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: translate('register.password'),
                        ),
                        obscureText: true,
                        validator: (v) => (v == null || v.length < 6)
                            ? translate('validation.password_length')
                            : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _loading ? null : _submit,
                        child: _loading
                            ? const SizedBox(
                                height: 16,
                                width: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(translate('register.submit')),
                      ),
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
}
