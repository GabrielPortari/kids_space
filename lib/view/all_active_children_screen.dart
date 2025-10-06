import 'package:flutter/material.dart';
class AllActiveChildrenScreen extends StatefulWidget {
	const AllActiveChildrenScreen({super.key});

	@override
	State<AllActiveChildrenScreen> createState() => _AllActiveChildrenScreenState();
}

class _AllActiveChildrenScreenState extends State<AllActiveChildrenScreen> {
	final TextEditingController _searchController = TextEditingController();
	final List<Map<String, String>> _allChildren = [
		{
			'childName': 'Lucas Silva',
			'responsibleName': 'Ana Silva',
			'phone': '(11) 91234-5678',
		},
		{
			'childName': 'Maria Souza',
			'responsibleName': 'Carlos Souza',
			'phone': '(11) 99876-5432',
		},
		{
			'childName': 'João Pereira',
			'responsibleName': 'Fernanda Pereira',
			'phone': '(11) 98765-4321',
		},
		{
			'childName': 'Beatriz Lima',
			'responsibleName': 'Paulo Lima',
			'phone': '(11) 91111-2222',
		},
		{
			'childName': 'Rafael Costa',
			'responsibleName': 'Juliana Costa',
			'phone': '(11) 93333-4444',
		},
		{
			'childName': 'Sofia Martins',
			'responsibleName': 'Roberto Martins',
			'phone': '(11) 95555-6666',
		},
		{
			'childName': 'Pedro Alves',
			'responsibleName': 'Patrícia Alves',
			'phone': '(11) 97777-8888',
		},
		{
			'childName': 'Larissa Rocha',
			'responsibleName': 'Marcelo Rocha',
			'phone': '(11) 99999-0000',
		},
		{
			'childName': 'Gabriel Mendes',
			'responsibleName': 'Simone Mendes',
			'phone': '(11) 90000-1111',
		},
		{
			'childName': 'Camila Torres',
			'responsibleName': 'Eduardo Torres',
			'phone': '(11) 92222-3333',
		},
		{
			'childName': 'Felipe Barros',
			'responsibleName': 'Aline Barros',
			'phone': '(11) 94444-5555',
		},
		{
			'childName': 'Isabela Ramos',
			'responsibleName': 'Gustavo Ramos',
			'phone': '(11) 96666-7777',
		},
	];
	List<Map<String, String>> _filteredChildren = [];

		@override
		void initState() {
			super.initState();
			_allChildren.sort((a, b) => (a['childName'] ?? '').compareTo(b['childName'] ?? ''));
			_filteredChildren = List.from(_allChildren);
			_searchController.addListener(_onSearchChanged);
		}

			void _onSearchChanged() {
				setState(() {
					final query = _searchController.text.toLowerCase();
					_filteredChildren = _allChildren.where((child) {
						final childName = (child['childName'] ?? '').toLowerCase();
						final responsibleName = (child['responsibleName'] ?? '').toLowerCase();
						return childName.contains(query) || responsibleName.contains(query);
					}).toList();
					_filteredChildren.sort((a, b) => (a['childName'] ?? '').compareTo(b['childName'] ?? ''));
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
			appBar: AppBar(title: const Text('Todas as crianças ativas')),
			body: Padding(
				padding: const EdgeInsets.all(16.0),
				child: Column(
					children: [
						TextField(
							controller: _searchController,
							decoration: const InputDecoration(
								labelText: 'Buscar criança',
								prefixIcon: Icon(Icons.search),
								border: OutlineInputBorder(),
							),
						),
						const SizedBox(height: 16),
									Expanded(
										child: ListView.builder(
											itemCount: _filteredChildren.length,
											itemBuilder: (context, index) {
												final child = _filteredChildren[index];
												return Card(
													elevation: 2,
													shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
													child: Padding(
														padding: const EdgeInsets.all(12.0),
														child: Row(
															crossAxisAlignment: CrossAxisAlignment.start,
															children: [
																const Icon(Icons.child_care, color: Colors.deepPurple, size: 32),
																const SizedBox(width: 12),
																Expanded(
																	child: Column(
																		crossAxisAlignment: CrossAxisAlignment.start,
																		children: [
																			Text(
																				child['childName'] ?? '',
																				style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
																				overflow: TextOverflow.ellipsis,
																			),
																			const SizedBox(height: 4),
																			Text(
																				'Responsável: ${child['responsibleName'] ?? ''}',
																				style: const TextStyle(fontSize: 15),
																			),
																			Text(
																				'Telefone: ${child['phone'] ?? ''}',
																				style: const TextStyle(fontSize: 15, color: Colors.grey),
																			),
																		],
																	),
																),
															],
														),
													),
												);
											},
										),
									),
					],
				),
			),
		);
	}
}
