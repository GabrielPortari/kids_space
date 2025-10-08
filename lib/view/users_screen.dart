import 'package:flutter/material.dart';

class UsersScreen extends StatefulWidget {
	const UsersScreen({super.key});

	@override
	State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
	final TextEditingController _searchController = TextEditingController();
	final List<String> _allUsers = [
		'Ana Souza',
		'Bruno Lima',
		'Carlos Silva',
		'Daniela Costa',
		'Eduardo Pereira',
		'Fernanda Oliveira',
		'Gabriel Martins',
		'Helena Rocha',
		'Isabela Alves',
		'João Pedro',
	];
	List<String> _filteredUsers = [];

	@override
	void initState() {
		super.initState();
		_filteredUsers = List.from(_allUsers);
		_searchController.addListener(_onSearchChanged);
	}

	void _onSearchChanged() {
		setState(() {
			_filteredUsers = _allUsers
					.where((user) => user.toLowerCase().contains(_searchController.text.toLowerCase()))
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
							child: ListView.builder(
								itemCount: _filteredUsers.length,
								itemBuilder: (context, index) {
									final user = _filteredUsers[index];
									return Card(
										margin: const EdgeInsets.symmetric(vertical: 8),
										child: ListTile(
											title: Text(user),
											leading: const Icon(Icons.person),
											onTap: () {
												// TODO: Implementar ação ao selecionar usuário
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
