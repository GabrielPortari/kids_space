import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/services.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';

final AuthController authController = GetIt.I<AuthController>();
final CollaboratorController _collaboratorController =
    GetIt.I<CollaboratorController>();

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('DebuggerLog: ProfileScreen.initState');
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('DebuggerLog: ProfileScreen.build');
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
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
            onSelected: (value) {
                debugPrint('DebuggerLog: ProfileScreen.menu selected -> $value');
              if (value == 'edit_profile') {
                _onEditProfile();
              }
              if (value == 'logout') {
                _onLogout();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Observer(
          builder: (_) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 24),
                _collaboratorProfileInfo(),
                const SizedBox(height: 24),
                Text(
                  _collaboratorController.loggedCollaborator != null
                      ? _collaboratorController.loggedCollaborator!.name
                      : 'Nome do Colaborador',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Colaborador', //user type
                  style: TextStyle(fontSize: 18, color: Colors.deepPurple),
                ),
                const SizedBox(height: 24),
                _collaboratorProfileCard(),
              ],
            );
          },
        ),
      ),
    );
  }

  _collaboratorProfileInfo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Colors.deepPurple[100],
          child: const Icon(Icons.person, size: 60, color: Colors.deepPurple),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                  debugPrint('DebuggerLog: ProfileScreen.addPhoto tapped');
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

  _collaboratorProfileCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Nome:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  _collaboratorController.loggedCollaborator != null
                      ? _collaboratorController.loggedCollaborator!.name
                      : 'Nome do Colaborador',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Text('Email:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 8),
                Text(
                  _collaboratorController.loggedCollaborator != null
                      ? _collaboratorController.loggedCollaborator!.email
                      : 'email@placeholder.com',
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
                  _collaboratorController.loggedCollaborator != null &&
                          _collaboratorController
                                  .loggedCollaborator!
                                  .phoneNumber !=
                              null
                      ? _collaboratorController.loggedCollaborator!.phoneNumber!
                      : '(11) 1234 5678',
                  style: const TextStyle(fontSize: 16),
                ),
              ],
            ),
            const Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      'ID:',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _collaboratorController.loggedCollaborator != null
                          ? _collaboratorController.loggedCollaborator!.id
                          : 'ID do Colaborador',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(width: 8),
                InkWell(
                  onTap: () async {
                    final id =
                        _collaboratorController.loggedCollaborator?.id ?? '';
                    debugPrint(
                      'DebuggerLog: ProfileScreen.copyId tapped -> $id',
                    );
                    if (id.isNotEmpty) {
                      await Clipboard.setData(ClipboardData(text: id));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'ID copiado para a área de transferência!',
                          ),
                        ),
                      );
                    }
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(Icons.copy, size: 18, color: Colors.grey),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  _onEditProfile() {
    return showDialog(
      context: context,
      builder: (context) {
        debugPrint('DebuggerLog: ProfileScreen.openEditDialog -> collaboratorId=${_collaboratorController.loggedCollaborator?.id ?? 'none'}');
        final nameController = TextEditingController(
          text: _collaboratorController.loggedCollaborator?.name ?? '',
        );
        final emailController = TextEditingController(
          text: _collaboratorController.loggedCollaborator?.email ?? '',
        );
        final phoneController = TextEditingController(
          text: _collaboratorController.loggedCollaborator?.phoneNumber ?? '',
        );
        return AlertDialog(
          title: const Text('Editar perfil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Nome'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(labelText: 'Telefone'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                debugPrint('DebuggerLog: ProfileScreen.editDialog.cancel');
                Navigator.pop(context);
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                debugPrint('DebuggerLog: ProfileScreen.saveProfile -> name=${nameController.text}, email=${emailController.text}, phone=${phoneController.text}');
                // TODO: Salvar alterações (persistir via _collaboratorController)
                Navigator.pop(context);
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  _onLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja deslogar o usuário?'),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('DebuggerLog: ProfileScreen.logout.cancel');
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              debugPrint('DebuggerLog: ProfileScreen.logout.confirm');
              authController.logout();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/company_selection', (route) => false);
            },
            child: const Text('Deslogar'),
          ),
        ],
      ),
    );
  }
}
