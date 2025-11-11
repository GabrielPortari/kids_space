import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/user_controller.dart';
import 'package:kids_space/model/user.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UserController _userController = GetIt.I<UserController>();
  final CompanyController _companyController = GetIt.I<CompanyController>();

  final List<User> _allUsers = [];
  late List<User> _filteredUsers;

  @override
  void initState() {
    super.initState();
    final companyId = _companyController.companySelected?.id;
    if (companyId != null) {
      _allUsers.addAll(_userController.getUsersByCompanyId(companyId));
    } else {
      // No company selected yet — leave user list empty. It will update if user navigates after selection.
    }
    _filteredUsers = List<User>.from(_allUsers);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _filteredUsers = _allUsers
          .where(
            (user) => user.name.toLowerCase().contains(
              _searchController.text.toLowerCase(),
            ),
          )
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Usuários Cadastrados'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Buscar usuário',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _filteredUsers.isEmpty
                  ? Center(
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'Nenhum usuário cadastrado'
                            : 'Nenhum usuário encontrado',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _filteredUsers.length,
                      itemBuilder: (context, index) {
                        final user = _filteredUsers[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(user.name),
                            leading: const Icon(Icons.person),
                            onTap: () {
                              _userController.selectedUserId = user.id;
                              Navigator.of(
                                context,
                              ).pushNamed('/user_profile_screen');
                            },
                          ),
                        );
                      },
                    ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text('Cadastrar novo usuário'),
                onPressed: _onAddUser,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _onAddUser() {
    // TODO: Implementar cadastro de novo usuário
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cadastrar novo usuário'),
          content: const Text('Funcionalidade de cadastro em desenvolvimento.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ],
        );
      },
    );
  }
}
