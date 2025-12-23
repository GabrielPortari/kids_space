import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/auth_controller.dart';
import '../../util/admin_tile_helpers.dart';
import '../../model/admin_tile_model.dart';
import '../widgets/admin_tile.dart';

final AuthController _authController = GetIt.I<AuthController>();

class AdminPanelScreen extends StatefulWidget {
  const AdminPanelScreen({Key? key}) : super(key: key);

  @override
  State<AdminPanelScreen> createState() => _AdminPanelScreenState();
}

class _AdminPanelScreenState extends State<AdminPanelScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<AdminTileModel> _adminItems = const [
    AdminTileModel(type: AdminTileType.company, icon: Icons.business),
    AdminTileModel(type: AdminTileType.responsible, icon: Icons.person),
    AdminTileModel(type: AdminTileType.child, icon: Icons.child_care),
    AdminTileModel(type: AdminTileType.collaborator, icon: Icons.group),
  ];


  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Painel Admin'),
        centerTitle: true,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton(
        tooltip: 'Sair',
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Sair'),
              content: const Text('Deseja deslogar o usuário?'),
              actions: [
                TextButton(
                  onPressed: () {
                    debugPrint('DebuggerLog: AdminPanelScreen.logout.cancel');
                    Navigator.pop(context);
                  },
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () async {
                    debugPrint('DebuggerLog: AdminPanelScreen.logout.confirm');
                    await _authController.logout();
                    Navigator.of(context).pushNamedAndRemoveUntil('/company_selection', (route) => false);
                  },
                  child: const Text('Deslogar'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.logout),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 720),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: GridView.count(
                crossAxisCount: 1,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 4,
                children: _adminItems.map((model) {
                  return AdminTile(
                    model: model,
                    onTap: (){
                      Navigator.pushNamed(context, getNavigationRoute(model.type));
                    }
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
 
}
