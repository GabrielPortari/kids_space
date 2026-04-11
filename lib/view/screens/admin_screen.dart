import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/util/localization_service.dart';

final AuthController _authController = GetIt.I<AuthController>();

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  bool get _isMaster => _authController.role == UserRole.master;

  Future<void> _confirmLogout(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(translate('admin.exit_title')),
        content: Text(translate('admin.exit_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(translate('buttons.cancel')),
          ),
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _authController.logout();
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            child: Text(translate('admin.logout')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin do Sistema'),
        actions: [
          IconButton(
            tooltip: translate('admin.logout'),
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Selecione uma operacao administrativa',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 16),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.admin_panel_settings),
                    title: const Text('Gerenciar admins do sistema'),
                    subtitle: const Text(
                      'Listar, criar, editar e excluir admins.',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        Navigator.of(context).pushNamed('/admin_users_screen'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.apartment),
                    title: const Text('Admin Management por company'),
                    subtitle: const Text(
                      'Overview, CRUD por company e listagem global de entidades.',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(
                      context,
                    ).pushNamed('/admin_management_screen'),
                  ),
                ),
                if (!_isMaster)
                  const Padding(
                    padding: EdgeInsets.only(top: 8),
                    child: Text(
                      'Perfil admin: acesso ao menu de operacoes sem privilegios de master para exclusao de admins do sistema.',
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
