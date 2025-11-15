import 'package:flutter/material.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/user_controller.dart';
import 'package:kids_space/model/user.dart';
import 'package:flutter/services.dart';
import 'package:kids_space/util/validator_util.dart';

class AddUserDialog extends StatefulWidget {
  final CompanyController companyController;
  final UserController userController;

  const AddUserDialog({required this.companyController, required this.userController, super.key});

  @override
  State<AddUserDialog> createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late final TextEditingController documentController;
  // phoneFormatter removed; we'll format phone in onChanged for flexible masks
  var isSaving = false;
  var isFormValid = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    documentController = TextEditingController();

    // listen to fields to update save button state
    nameController.addListener(_onFieldChanged);
    emailController.addListener(_onFieldChanged);
    phoneController.addListener(_onFieldChanged);
    documentController.addListener(_onFieldChanged);

    // no formatter initialization here; formatting handled in onChanged
  }

  @override
  void dispose() {
    nameController.removeListener(_onFieldChanged);
    emailController.removeListener(_onFieldChanged);
    phoneController.removeListener(_onFieldChanged);
    documentController.removeListener(_onFieldChanged);

    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    documentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cadastrar novo usuário'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Nome'),
                textInputAction: TextInputAction.next,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nome é obrigatório' : null,
                autofocus: true,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null; // optional
                  return v.contains('@') ? null : 'Email inválido';
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Telefone', hintText: '(99) 99999-9999'),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                onChanged: (s) {
                  // Format phone manually so mask adapts immediately
                  final digits = s.replaceAll(RegExp(r'[^0-9]'), '');
                  String formatted;
                  if (digits.length <= 2) {
                    formatted = '(${digits}';
                  } else {
                    final area = digits.substring(0, 2);
                    final rest = digits.substring(2);
                    if (rest.length <= 4) {
                      formatted = '($area) $rest';
                    } else if (rest.length <= 5) {
                      // for 7 total digits etc.
                        formatted = '($area) ${rest.substring(0, 4)}-${rest.substring(4)}';
                    } else if (rest.length <= 8) {
                      // 10-digit total -> 4-4
                      formatted = '($area) ${rest.substring(0, 4)}-${rest.substring(4)}';
                    } else {
                      // 11-digit total -> 5-4
                      formatted = '($area) ${rest.substring(0, 5)}-${rest.substring(5)}';
                    }
                  }
                  if (formatted != phoneController.text) {
                    phoneController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                },
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return null; // optional
                  final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                  if (digits.length == 10 || digits.length == 11) return null;
                  return 'Telefone inválido';
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: documentController,
                decoration: const InputDecoration(labelText: 'Documento (CPF ou RG)', hintText: 'CPF ou RG'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(11),
                ],
                validator: (v) {
                  if (v == null || v.trim().isEmpty) return 'Documento é obrigatório';
                  final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
                  if (digits.length == 11) {
                    return isValidCpf(digits) ? null : 'CPF inválido';
                  }
                  // Accept RG only when it has exactly 9 digits
                  if (digits.length == 9) return null;
                  return 'Documento inválido (9 dígitos RG ou 11 dígitos CPF)';
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: isSaving
              ? null
              : () {
                  Navigator.pop(context, false);
                },
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: (isSaving || !isFormValid)
              ? null
              : () async {
                  // final guard (re-validate before saving)
                  if (!_formKey.currentState!.validate()) return;

                  final name = nameController.text.trim();
                  final email = emailController.text.trim();
                  final phone = phoneController.text.trim();
                  final document = documentController.text.trim();
                  // remove parentheses, dots, spaces and hyphens explicitly
                  final phoneDigits = phone.replaceAll(RegExp(r'[()\.\s-]'), '');
                  final documentDigits = document.replaceAll(RegExp(r'[()\.\s-]'), '');

                  final companyId = widget.companyController.companySelected?.id;
                  if (companyId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Selecione uma empresa antes de cadastrar')));
                    return;
                  }

                  setState(() => isSaving = true);

                  try {
                    final id = DateTime.now().millisecondsSinceEpoch.toString();
                    final user = User(
                      id: id,
                      name: name,
                      email: email,
                      phone: phoneDigits,
                      document: documentDigits,
                      companyId: companyId,
                      childrenIds: [],
                    );
                    debugPrint('DebuggerLog: UsersScreen.createUser -> $id');
                    widget.userController.addUser(user);
                    Navigator.pop(context, true);
                  } catch (e, st) {
                    debugPrint('DebuggerLog: UsersScreen.createUser ERROR $e\n$st');
                    setState(() => isSaving = false);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao criar usuário')));
                  }
                },
          child: Builder(builder: (_) {
            return isSaving
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Salvar');
          }),
        ),
      ],
    );
  }

  void _onFieldChanged() {
    final valid = validateAddUserFields(
      name: nameController.text,
      email: emailController.text,
      phone: phoneController.text,
      document: documentController.text,
    );
    if (valid != isFormValid) {
      setState(() {
        isFormValid = valid;
      });
    }
  }

}
