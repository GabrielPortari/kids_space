import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/model/collaborator.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = GetIt.I<AuthController>();
    final CollaboratorController collaboratorController = GetIt.I<CollaboratorController>();
    final Collaborator? loggedCollaborator = collaboratorController.loggedCollaborator;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'edit_profile') {
                showDialog(
                  context: context,
                  builder: (context) {
                    final nameController = TextEditingController(text: loggedCollaborator?.name ?? '');
                    final emailController = TextEditingController(text: loggedCollaborator?.email ?? '');
                    final phoneController = TextEditingController(text: loggedCollaborator?.phoneNumber ?? '');
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
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Cancelar'),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            // TODO: Salvar alterações
                            Navigator.pop(context);
                          },
                          child: const Text('Salvar'),
                        ),
                      ],
                    );
                  },
                );
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
                          authController.logout();
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
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Stack(
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
            ),
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
            Card(
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
                        Text(loggedCollaborator != null ? loggedCollaborator.name : 'Nome do Colaborador', style: const TextStyle(fontSize: 16)),
                      ],
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const Text('Email:', style: TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Text(
                          loggedCollaborator != null ? loggedCollaborator.email : 'email@placeholder.com',
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
                          loggedCollaborator != null && loggedCollaborator.phoneNumber != null ?
                          loggedCollaborator.phoneNumber! : '(11) 1234 5678',
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
                          loggedCollaborator != null ? loggedCollaborator.id : 'ID do Colaborador',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
