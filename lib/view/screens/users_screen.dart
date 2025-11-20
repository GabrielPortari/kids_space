import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/user_controller.dart';
import 'package:kids_space/model/mock/model_mock.dart';
import 'package:kids_space/model/user.dart';
import 'package:kids_space/view/widgets/add_user_dialog.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:skeletonizer/skeletonizer.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}



class _UsersScreenState extends State<UsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  final UserController _userController = GetIt.I<UserController>();
  final CompanyController _companyController = GetIt.I<CompanyController>();

  @override
  void initState() {
    super.initState();
    final companyId = _companyController.companySelected?.id;
    debugPrint('DebuggerLog: UsersScreen.initState -> companyId=$companyId');
    
    // populate controller observable list for the current company (keeps same ObservableList instance)
    _userController.refreshUsersForCompany(companyId);
    // keep a simple listener to trigger rebuilds when search text changes
    _searchController.addListener(_onSearchChanged);
  }

  Timer? _debounce;
  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _userController.userFilter = _searchController.text.trim().toLowerCase();
    });
    debugPrint('DebuggerLog: UsersScreen._onSearchChanged -> "${_searchController.text}"');
    setState(() {});
  }

  Future<void> _onRefresh() async {
    final companyId = _companyController.companySelected?.id;
    debugPrint('DebuggerLog: UsersScreen._onRefresh -> companyId=$companyId');
    await _userController.refreshUsersForCompany(companyId);
  }

  @override
  void dispose() {
    debugPrint('DebuggerLog: UsersScreen.dispose');
    _debounce?.cancel();
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
              child: RefreshIndicator(
                onRefresh: () async {
                  await _onRefresh();
                },
                child: Observer(builder: (_) {
                  final all = _userController.users;
                  final nameSearched = _searchController.text.trim().toLowerCase();
                  final filtered = nameSearched.isEmpty
                      ? all
                      : all.where((u) {
                          final nameMatch = u.name.toLowerCase().contains(nameSearched);
                          final docMatch = u.document.toLowerCase().contains(nameSearched);
                          return nameMatch || docMatch;
                        }).toList();

                  debugPrint('DebuggerLog: UsersScreen.Observer -> total=${all.length} filtered=${filtered.length} filter="$nameSearched"');
                  if (_userController.refreshLoading) {
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Skeletonizer(
                          enabled: true,
                          child: Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Bone.text(words: 3),
                              leading: const Icon(Icons.person),
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return ListView.builder(
                      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                      itemCount: filtered.isEmpty ? 1 : filtered.length,
                      itemBuilder: (context, index) {
                        if (filtered.isEmpty) {
                          return Center(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24.0),
                              child: Text(
                                _searchController.text.isEmpty
                                    ? 'Nenhum usuário cadastrado'
                                    : 'Nenhum usuário encontrado',
                                style: const TextStyle(color: Colors.grey, fontSize: 16),
                              ),
                            ),
                          );
                        }
                        final user = filtered[index];
                        debugPrint('DebuggerLog: UsersScreen.onTap itemBuilder -> index=$index id=${user.id}');
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(user.name),
                            leading: const Icon(Icons.person),
                            onTap: () {
                              debugPrint('DebuggerLog: UsersScreen.onTap -> userId=${user.id}');
                              _userController.selectedUserId = user.id;
                              Navigator.of(context).pushNamed('/user_profile_screen');
                            },
                          ),
                        );
                      },
                    );
                  }
                }),
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
    debugPrint('DebuggerLog: UsersScreen.onAddUser pressed');

    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddUserDialog(
        companyController: _companyController,
        userController: _userController,
      ),
    ).then((created) {
      if (created == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário cadastrado')));
      }
    });
  }
}
