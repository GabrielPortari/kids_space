import 'package:flutter/material.dart';
import '../widgets/admin_tile_helpers.dart';
import '../../model/admin_tile_model.dart';
import '../widgets/admin_tile.dart';

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
    AdminTileModel(type: AdminTileType.reports, icon: Icons.insert_chart),
    AdminTileModel(type: AdminTileType.configurations, icon: Icons.settings),
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
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 2,
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
      ),
    );
  }
 
}
