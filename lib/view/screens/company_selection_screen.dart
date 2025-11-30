import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/model/company.dart';
import 'package:kids_space/view/screens/login_screen.dart';

class CompanySelectionScreen extends StatefulWidget {
	const CompanySelectionScreen({super.key});

	@override
	State<CompanySelectionScreen> createState() => _CompanySelectionScreenState();
}

class _CompanySelectionScreenState extends State<CompanySelectionScreen> {
	final TextEditingController _searchController = TextEditingController();
	final CompanyController _companyController = GetIt.I<CompanyController>();
	List<Company> _filteredCompanies = [];

	@override
	void initState() {
		super.initState();
		_updateFilteredCompanies();
		_searchController.addListener(_onSearchChanged);
	}

	void _onSearchChanged() {
		setState(_updateFilteredCompanies);
	}

	void _updateFilteredCompanies() {
		_filteredCompanies = _companyController.filterCompanies(_searchController.text);
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
						_searchField(),
						const SizedBox(height: 16),
						Expanded(child: _buildCompaniesArea()),
					],
				),
			),
		);
	}

	Widget _searchField() {
		return TextField(
			controller: _searchController,
			decoration: const InputDecoration(
				labelText: 'Buscar empresa',
				prefixIcon: Icon(Icons.search),
				border: OutlineInputBorder(),
			),
		);
	}

	Widget _buildCompaniesArea() {
		if (_searchController.text.isEmpty) {
			return const Center(
				child: Text(
					'Digite para buscar uma empresa',
					style: TextStyle(color: Colors.grey, fontSize: 16),
				),
			);
		}

		if (_filteredCompanies.isEmpty) {
			return const Center(
				child: Text(
					'Nenhuma empresa encontrada',
					style: TextStyle(color: Colors.grey, fontSize: 16),
				),
			);
		}

		return ListView.builder(
			itemCount: _filteredCompanies.length,
			itemBuilder: (context, index) {
				final company = _filteredCompanies[index];
				return _companyTile(company);
			},
		);
	}

	Widget _companyTile(Company company) {
		return Card(
			margin: const EdgeInsets.symmetric(vertical: 8),
			child: ListTile(
				title: Text(company.name),
				leading: const Icon(Icons.business),
				onTap: () {
					_companyController.selectCompany(company);
					Navigator.push(
						context,
						MaterialPageRoute(
							builder: (context) => const LoginScreen(),
						),
					);
				},
			),
		);
	}
}
