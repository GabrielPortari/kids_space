import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/model/collaborator.dart';

AuthController get _authController => GetIt.I<AuthController>();
CollaboratorController get _collaboratorController => GetIt.I<CollaboratorController>();

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Switched to MobX: UI uses `Observer` to react to controller changes.

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          _buildPopupMenu(context),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Observer(builder: (_) {
          final Collaborator? loggedCollaborator = _collaboratorController.loggedCollaborator;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),
              _buildAvatarSection(),
              const SizedBox(height: 24),
              Text(
                loggedCollaborator != null ? loggedCollaborator.name : 'Nome do Colaborador',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Colaborador', //user type
                style: TextStyle(fontSize: 18, color: Colors.deepPurple),
              ),
              const SizedBox(height: 24),
              _buildInfoCard(loggedCollaborator),
            ],
          );
        }),
      ),
    );
  }

  Future<void> _showEditProfileDialog(BuildContext context) async {
    final loggedCollaborator = _collaboratorController.loggedCollaborator; // keep for backwards compat
    await showDialog(
      context: context,
      builder: (context) => EditProfileDialog(loggedCollaborator: loggedCollaborator),
    );
  }

  Widget _buildPopupMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      onSelected: (value) async {
        if (value == 'edit_profile') {
          await _showEditProfileDialog(context);
        }
        if (value == 'logout') {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Sair'),
              content: const Text('Deseja deslogar o usuário?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () {
                    _authController.logout();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/company_selection',
                      (route) => false,
                    );
                  },
                  child: const Text('Deslogar'),
                ),
              ],
            ),
          );
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem<String>(
          value: 'edit_profile',
          child: Text('Editar perfil'),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Text('Deslogar'),
        ),
      ],
    );
  }

  Widget _buildAvatarSection() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.deepPurple[100],
          child: const Icon(
            Icons.person,
            size: 60,
            color: Colors.deepPurple,
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                // TODO: Implementar ação para adicionar foto
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(
                  Icons.add_a_photo,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(Collaborator? loggedCollaborator) {
    final local = loggedCollaborator ?? _collaboratorController.loggedCollaborator;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Nome:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(local != null ? local.name : 'Nome do Colaborador', style: const TextStyle(fontSize: 16)),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Email:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  local != null ? local.email : 'email@placeholder.com',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const Divider(),
                Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Telefone:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  local != null && local.phoneNumber != null ? local.phoneNumber! : '(11) 1234 5678',
                style: const TextStyle(fontSize: 16)),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  'ID:',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(width: 8),
                Text(
                  local != null ? local.id : 'ID do Colaborador',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfileDialog extends StatefulWidget {
  final Collaborator? loggedCollaborator;
  const EditProfileDialog({super.key, this.loggedCollaborator});

  @override
  State<EditProfileDialog> createState() => _EditProfileDialogState();
}

class _EditProfileDialogState extends State<EditProfileDialog> {
  late final TextEditingController nameController;
  late final TextEditingController emailController;
  late final TextEditingController phoneController;
  late MaskTextInputFormatter phoneFormatter;

  late final String initialName;
  late final String initialEmail;
  late final String initialPhone;

  bool isChanged = false;
  bool isPhoneValid = true;
  bool isEmailValid = false;

  @override
  void initState() {
    super.initState();
    initialName = widget.loggedCollaborator?.name ?? '';
    initialEmail = widget.loggedCollaborator?.email ?? '';
    initialPhone = widget.loggedCollaborator?.phoneNumber ?? '';

    nameController = TextEditingController(text: initialName);
    emailController = TextEditingController(text: initialEmail);
    phoneController = TextEditingController(text: initialPhone);

    final initialPhoneClean = initialPhone.replaceAll(RegExp(r'[^0-9]'), '');
    phoneFormatter = MaskTextInputFormatter(
      mask: (initialPhoneClean.length <= 10) ? '(##) ####-####' : '(##) #####-####',
      filter: {"#": RegExp(r'[0-9]')},
    );

    isEmailValid = initialEmail.trim().isNotEmpty && RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(initialEmail.trim());
    isPhoneValid = initialPhoneClean.isEmpty || (initialPhoneClean.length >= 10 && initialPhoneClean.length <= 15);
    isChanged = false;
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  bool computeChanged() {
    return nameController.text.trim() != initialName || emailController.text.trim() != initialEmail || phoneController.text.trim() != initialPhone;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Editar perfil'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
              onChanged: (_) => setState(() => isChanged = computeChanged()),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null || value.trim().isEmpty) return 'Email obrigatório.';
                final ok = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim());
                return ok ? null : 'Email inválido.';
              },
              onChanged: (v) => setState(() {
                isEmailValid = v.trim().isNotEmpty && RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());
                isChanged = computeChanged();
              }),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: phoneController,
              inputFormatters: [phoneFormatter],
              decoration: const InputDecoration(labelText: 'Telefone'),
              keyboardType: TextInputType.phone,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) {
                if (value == null) return null;
                final cleaned = value.replaceAll(RegExp(r'[^0-9]'), '');
                if (cleaned.isEmpty) return null; // allow empty
                if (cleaned.length < 10) return 'Telefone inválido. Insira ao menos 10 dígitos.';
                if (cleaned.length > 15) return 'Telefone inválido. Insira no máximo 15 dígitos.';
                return null;
              },
              onChanged: (v) {
                final cleaned = v.replaceAll(RegExp(r'[^0-9]'), '');
                setState(() {
                  if (cleaned.length <= 10) {
                    phoneFormatter.updateMask(mask: '(##) ####-####');
                  } else {
                    phoneFormatter.updateMask(mask: '(##) #####-####');
                  }
                  isPhoneValid = cleaned.isEmpty || (cleaned.length >= 10 && cleaned.length <= 15);
                  isChanged = computeChanged();
                });
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        ElevatedButton(
          onPressed: (!isChanged || !isPhoneValid || !isEmailValid) ? null : () async {
            final updated = Collaborator(
              id: widget.loggedCollaborator?.id ?? '',
              name: nameController.text.trim(),
              email: emailController.text.trim(),
              companyId: widget.loggedCollaborator?.companyId ?? '',
              phoneNumber: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
            );
            await _collaboratorController.setLoggedCollaborator(updated);
            if (mounted) Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil atualizado')));
          },
          child: const Text('Salvar'),
        ),
      ],
    );
  }
}
