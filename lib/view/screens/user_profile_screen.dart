import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/user_controller.dart';
import 'package:kids_space/model/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserController _userController = GetIt.I<UserController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem<String>(
                value: 'edit_profile',
                child: Text('Editar perfil'),
              ),
              const PopupMenuItem<String>(
                value: 'register_child',
                child: Text('Cadastrar criança'),
              ),
            ],
            onSelected: (value) {
              if (value == 'edit_profile') {
                _onEditProfile();
              } else if (value == 'register_child') {
                _onRegisterChild();
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Observer(builder: (_) {
          final user = _userController.selectedUser;
          return Column(
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
                user?.name ?? 'Nome não encontrado',
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Usuário',
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
                          Text(user?.name ?? '-', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text('Email:', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(user?.email ?? '-', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text('Telefone:', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(user?.phone ?? '-', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text('Documento:', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(user?.document ?? '-', style: const TextStyle(fontSize: 16)),
                        ],
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Text('ID:', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          const SizedBox(width: 8),
                          Text(user?.id ?? '-', style: const TextStyle(fontSize: 16, color: Colors.grey)),
                        ],
                      ),
                    ],
                  ),
                ),
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
                      const Text(
                        'Crianças sob responsabilidade',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Aqui você pode buscar as crianças do usuário se necessário
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  void _onEditProfile() {
    final user = _userController.selectedUser;
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final documentController = TextEditingController(text: user?.document ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar perfil'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Nome')),
              const SizedBox(height: 12),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
              const SizedBox(height: 12),
              TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Telefone')),
              const SizedBox(height: 12),
              TextField(controller: documentController, decoration: const InputDecoration(labelText: 'Documento')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              // Ask for confirmation before saving
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirmar alterações'),
                  content: const Text('Deseja salvar as alterações no perfil?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar')),
                    ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirmar')),
                  ],
                ),
              );
              if (confirm != true) return;

              final user = _userController.selectedUser;
              if (user == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário não encontrado')));
                return;
              }

              final updated = User(
                id: user.id,
                name: nameController.text.trim(),
                email: emailController.text.trim(),
                phone: phoneController.text.trim(),
                document: user.document,
                companyId: user.companyId,
                childrenIds: user.childrenIds,
              );

              _userController.updateUser(updated);
              Navigator.pop(context); // close edit dialog
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil atualizado')));
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _onRegisterChild() {
    final user = _userController.selectedUser;
    final childNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cadastrar criança'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: childNameController, decoration: const InputDecoration(labelText: 'Nome da criança')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () {
              final childName = childNameController.text.trim();
              if (childName.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nome da criança é obrigatório')));
                return;
              }
              final userId = user?.id;
              Navigator.pop(context);
              if (userId == null) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário não selecionado')));
                return;
              }
              // Try to navigate to a child creation route if available, passing responsible user id
              try {
                Navigator.of(context).pushNamed('/child_create', arguments: {'responsibleUserId': userId, 'name': childName});
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Fluxo de cadastro não implementado')));
              }
            },
            child: const Text('Cadastrar'),
          ),
        ],
      ),
    );
  }
}
