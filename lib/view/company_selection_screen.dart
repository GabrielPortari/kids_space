import 'package:flutter/material.dart';
import 'package:kids_space/view/login_screen.dart';

class CompanySelectionScreen extends StatefulWidget {
	const CompanySelectionScreen({super.key});

	@override
	State<CompanySelectionScreen> createState() => _CompanySelectionScreenState();
}

class _CompanySelectionScreenState extends State<CompanySelectionScreen> {
	final TextEditingController _searchController = TextEditingController();
	final List<String> _allCompanies = [
		'Tech Kids',
		'EducaPlay',
		'Brincar & Aprender',
		'Mundo Infantil',
		'Kids Solutions',
		'Espaço Criança',
		'Aprender Brincando',
		'Crescer Feliz',
		'Pequenos Gênios',
		'Play School',
	];
	List<String> _filteredCompanies = [];

	@override
	void initState() {
		super.initState();
		_filteredCompanies = List.from(_allCompanies);
		_searchController.addListener(_onSearchChanged);
	}

	void _onSearchChanged() {
		setState(() {
			_filteredCompanies = _allCompanies
					.where((company) => company.toLowerCase().contains(_searchController.text.toLowerCase()))
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
					title: const Text('Selecionar Empresa'),
				),
				body: Padding(
					padding: const EdgeInsets.all(16.0),
					child: Column(
						children: [
							TextField(
								controller: _searchController,
								decoration: const InputDecoration(
									labelText: 'Buscar empresa',
									prefixIcon: Icon(Icons.search),
									border: OutlineInputBorder(),
								),
							),
							const SizedBox(height: 16),
											Expanded(
												child: _searchController.text.isEmpty
														? Center(
																child: Text(
																	'Digite para buscar uma empresa',
																	style: TextStyle(color: Colors.grey, fontSize: 16),
																),
															)
														: _filteredCompanies.isEmpty
																? Center(
																		child: Text(
																			'Nenhuma empresa encontrada',
																			style: TextStyle(color: Colors.grey, fontSize: 16),
																		),
																	)
																: ListView.builder(
																		itemCount: _filteredCompanies.length,
																		itemBuilder: (context, index) {
																			final company = _filteredCompanies[index];
																			return Card(
																				margin: const EdgeInsets.symmetric(vertical: 8),
																				child: ListTile(
																					title: Text(company),
																					leading: const Icon(Icons.business),
																					onTap: () {
																						Navigator.push(
																							context,
																							MaterialPageRoute(
																								builder: (context) => LoginScreen(companyName: company),
																							),
																						);
																					},
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
