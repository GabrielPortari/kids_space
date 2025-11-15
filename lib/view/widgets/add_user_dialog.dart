import 'package:flutter/material.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/user_controller.dart';
import 'package:kids_space/model/user.dart';

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
  var isSaving = false;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();
    documentController = TextEditingController();
  }

  @override
  void dispose() {
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
                decoration: const InputDecoration(labelText: 'Telefone'),
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: documentController,
                decoration: const InputDecoration(labelText: 'Documento'),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
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
          onPressed: isSaving
              ? null
              : () async {
                  if (!_formKey.currentState!.validate()) return;

                  final name = nameController.text.trim();
                  final email = emailController.text.trim();
                  final phone = phoneController.text.trim();
                  final document = documentController.text.trim();

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
                      phone: phone,
                      document: document,
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
}
