import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final List<Map<String, String>> _allUsers = [
    {
      'name': 'Ana Souza',
      'email': 'ana.souza@email.com',
      'phone': '(11) 98765-4321',
      'id': 'a1b2c3d4e5f6g7h8',
    },
    {
      'name': 'Bruno Lima',
      'email': 'bruno.lima@email.com',
      'phone': '(11) 91234-5678',
      'id': 'b2c3d4e5f6g7h8i9',
    },
    {
      'name': 'Carlos Silva',
      'email': 'carlos.silva@email.com',
      'phone': '(11) 99876-5432',
      'id': 'c3d4e5f6g7h8i9j0',
    },
    {
      'name': 'Daniela Costa',
      'email': 'daniela.costa@email.com',
      'phone': '(11) 98712-3456',
      'id': 'd4e5f6g7h8i9j0k1',
    },
    {
      'name': 'Eduardo Pereira',
      'email': 'eduardo.pereira@email.com',
      'phone': '(11) 91298-7654',
      'id': 'e5f6g7h8i9j0k1l2',
    },
    {
      'name': 'Fernanda Oliveira',
      'email': 'fernanda.oliveira@email.com',
      'phone': '(11) 98765-1234',
      'id': 'f6g7h8i9j0k1l2m3',
    },
    {
      'name': 'Gabriel Martins',
      'email': 'gabriel.martins@email.com',
      'phone': '(11) 91234-8765',
      'id': 'g7h8i9j0k1l2m3n4',
    },
    {
      'name': 'Helena Rocha',
      'email': 'helena.rocha@email.com',
      'phone': '(11) 99876-4321',
      'id': 'h8i9j0k1l2m3n4o5',
    },
    {
      'name': 'Isabela Alves',
      'email': 'isabela.alves@email.com',
      'phone': '(11) 98765-4321',
      'id': 'i9j0k1l2m3n4o5p6',
    },
    {
      'name': 'João Pedro',
      'email': 'joao.pedro@email.com',
      'phone': '(11) 91234-5678',
      'id': 'j0k1l2m3n4o5p6q7',
    },
  ];
  late List<Map<String, String>> _filteredUsers;

  @override
  void initState() {
    super.initState();
  _filteredUsers = List<Map<String, String>>.from(_allUsers);
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      _filteredUsers = _allUsers
          .where(
            (user) => user['name']!.toLowerCase().contains(
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
              child: _searchController.text.isEmpty
                  ? Center(
                      child: Text(
                        'Digite para buscar um usuário',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    )
                  : _filteredUsers.isEmpty
                      ? Center(
                          child: Text(
                            'Nenhum usuário encontrado',
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
                                title: Text(user['name'] ?? ''),
                                leading: const Icon(Icons.person),
                                onTap: () {
                                  Navigator.of(context).pushNamed(
                                    '/user_profile_screen',
                                  );
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
}
