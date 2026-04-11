import 'package:flutter/material.dart';

class AdminManagementScreen extends StatelessWidget {
  const AdminManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Management')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text(
                'Escolha uma operacao',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              const Text(
                'As operacoes foram separadas em telas menores para evitar mistura de CRUD, listas e overview na mesma pagina.',
              ),
              const SizedBox(height: 16),
              _AdminMenuCard(
                icon: Icons.dashboard_outlined,
                title: 'Overview da empresa',
                subtitle:
                    'Consulta o resumo da company e os contadores principais.',
                routeName: '/admin_management_overview_screen',
              ),
              _AdminMenuCard(
                icon: Icons.group_outlined,
                title: 'Collaborators',
                subtitle: 'Criar, atualizar, remover e listar collaborators.',
                routeName: '/admin_management_collaborators_screen',
              ),
              _AdminMenuCard(
                icon: Icons.family_restroom_outlined,
                title: 'Parents',
                subtitle: 'Criar, atualizar, remover e listar responsáveis.',
                routeName: '/admin_management_parents_screen',
              ),
              _AdminMenuCard(
                icon: Icons.child_care_outlined,
                title: 'Children',
                subtitle: 'Criar, atualizar, remover e listar crianças.',
                routeName: '/admin_management_children_screen',
              ),
              _AdminMenuCard(
                icon: Icons.event_available_outlined,
                title: 'Attendances',
                subtitle:
                    'Criar check-in, atualizar, remover e listar registros.',
                routeName: '/admin_management_attendances_screen',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminMenuCard extends StatelessWidget {
  const _AdminMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.routeName,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final String routeName;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => Navigator.of(context).pushNamed(routeName),
      ),
    );
  }
}
