import 'package:flutter/material.dart';

class AdminPanelScreen extends StatefulWidget {
	const AdminPanelScreen({Key? key}) : super(key: key);

	@override
	State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
	final TextEditingController _searchController = TextEditingController();
	String _query = '';

	final List<_AdminTile> _tiles = [
		_AdminTile(title: 'Usuários', subtitle: 'Gerenciar responsáveis', icon: Icons.person),
		_AdminTile(title: 'Crianças', subtitle: 'Ver / editar crianças', icon: Icons.child_care),
		_AdminTile(title: 'Empresas', subtitle: 'Configurações da empresa', icon: Icons.apartment),
		_AdminTile(title: 'Eventos', subtitle: 'Check-in / Check-out', icon: Icons.event),
		_AdminTile(title: 'Colaboradores', subtitle: 'Equipe / atendentes', icon: Icons.group),
		_AdminTile(title: 'Relatórios', subtitle: 'Histórico e exportação', icon: Icons.bar_chart),
	];

	@override
	void dispose() {
		_searchController.dispose();
		super.dispose();
	}

	void _openTile(_AdminTile tile) {
		ScaffoldMessenger.of(context).showSnackBar(
			SnackBar(content: Text('Abrindo: ${tile.title}')),
		);
		// Aqui você pode navegar para a tela correspondente
		// Navigator.of(context).pushNamed('/users');
	}

	void _onFabPressed() {
		showModalBottomSheet<void>(
			context: context,
			builder: (context) => SafeArea(
				child: Padding(
					padding: const EdgeInsets.all(16.0),
					child: Column(
						mainAxisSize: MainAxisSize.min,
						crossAxisAlignment: CrossAxisAlignment.start,
						children: [
							const Text('Criar novo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
							const SizedBox(height: 12),
							ListTile(
								leading: const Icon(Icons.person_add),
								title: const Text('Adicionar usuário'),
								onTap: () {
									Navigator.of(context).pop();
									ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adicionar usuário')));
								},
							),
							ListTile(
								leading: const Icon(Icons.person_add_alt_1),
								title: const Text('Adicionar criança'),
								onTap: () {
									Navigator.of(context).pop();
									ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Adicionar criança')));
								},
							),
						],
					),
				),
			),
		);
	}

	@override
	Widget build(BuildContext context) {
		final filtered = _tiles.where((t) => t.title.toLowerCase().contains(_query.toLowerCase())).toList();

		return Scaffold(
			appBar: AppBar(
				title: const Text('Painel Admin'),
				centerTitle: true,
				elevation: 0,
			),
			body: SafeArea(
				child: Padding(
					padding: const EdgeInsets.all(16.0),
					child: Column(
						children: [
							TextField(
								controller: _searchController,
								decoration: InputDecoration(
									hintText: 'Buscar',
									prefixIcon: const Icon(Icons.search),
									suffixIcon: _query.isNotEmpty
											? IconButton(
													icon: const Icon(Icons.clear),
													onPressed: () {
														_searchController.clear();
														setState(() => _query = '');
													},
												)
											: null,
									border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.0)),
								),
								onChanged: (v) => setState(() => _query = v),
							),
							const SizedBox(height: 16),
							Expanded(
								child: GridView.count(
									crossAxisCount: MediaQuery.of(context).size.width > 800 ? 3 : 2,
									mainAxisSpacing: 12,
									crossAxisSpacing: 12,
									childAspectRatio: 1.2,
									children: filtered.map((tile) {
										return InkWell(
											onTap: () => _openTile(tile),
											borderRadius: BorderRadius.circular(12),
											child: Container(
												decoration: BoxDecoration(
													color: Theme.of(context).cardColor,
													borderRadius: BorderRadius.circular(12),
													boxShadow: [
														BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6, offset: const Offset(0, 2)),
													],
												),
												padding: const EdgeInsets.all(16),
												child: Column(
													crossAxisAlignment: CrossAxisAlignment.start,
													children: [
														CircleAvatar(
															radius: 20,
															backgroundColor: Theme.of(context).primaryColor.withOpacity(0.12),
															child: Icon(tile.icon, color: Theme.of(context).primaryColor),
														),
														const SizedBox(height: 12),
														Text(tile.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
														const SizedBox(height: 6),
														Text(tile.subtitle, style: TextStyle(color: Colors.grey[600])),
														const Spacer(),
														Row(
															mainAxisAlignment: MainAxisAlignment.end,
															children: const [Icon(Icons.arrow_forward_ios, size: 14)],
														)
													],
												),
											),
										);
									}).toList(),
								),
							),
						],
					),
				),
			),
			floatingActionButton: FloatingActionButton(
				onPressed: _onFabPressed,
				child: const Icon(Icons.add),
				tooltip: 'Criar',
			),
		);
	}
}

class _AdminTile {
	final String title;
	final String subtitle;
	final IconData icon;

	const _AdminTile({required this.title, required this.subtitle, required this.icon});
}

