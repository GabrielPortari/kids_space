import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/user_controller.dart';
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
  final CompanyController _companyController = GetIt.I.get<CompanyController>();
  final UserController _userController = GetIt.I.get<UserController>();

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _userController.userFilter = _searchController.text.trim();
      if (mounted) setState(() {});
    });
  }

  Future<void> _onRefresh() async {
    final companyId = _companyController.companySelected?.id;
    await _userController.refreshUsersForCompany(companyId);
  }

  void _onAddUser() {
    showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AddUserDialog(companyController: _companyController, userController: _userController),
    ).then((created) {
      if (created == true) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário cadastrado')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Usuários Cadastrados'), automaticallyImplyLeading: false),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _searchField(),
                const SizedBox(height: 16),
                _userList(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddUser,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        labelText: 'Buscar usuário',
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _userController.userFilter = '';
                },
              ),
      ),
    );
  }

  Widget _userList() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async => await _onRefresh(),
        child: Observer(builder: (_) {
          final filtered = _userController.filteredUsers;

          if (_userController.refreshLoading) {
            return _buildSkeletonList();
          }

          if (filtered.isEmpty) {
            return ListView(padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0), children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(_searchController.text.isEmpty ? 'Nenhum usuário cadastrado' : 'Nenhum usuário encontrado', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                ),
              )
            ]);
          }

          return ListView.builder(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            itemCount: filtered.length,
            itemExtent: 80.0,
            itemBuilder: (context, index) => _userTile(filtered[index]),
          );
        }),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
      itemCount: 3,
      itemExtent: 80.0,
      itemBuilder: (context, index) {
        return Skeletonizer(
          enabled: true,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 4),
            child: Center(
              child: ListTile(
                leading: CircleAvatar(radius: 20, backgroundColor: Colors.grey.shade300),
                title: const SizedBox.shrink(),
                subtitle: const SizedBox.shrink(),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _userTile(User user) {
    String document = user.document;
    document.length == 11 ?
      document = document.replaceRange(3, document.length, '.***.***-**') :
      document = document.replaceRange(2, document.length, '.***.***-*');
    return Card(
      key: ValueKey(user.id),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
          child: Text(_getInitials(user.name), style: TextStyle(color: Theme.of(context).colorScheme.primary)),
        ),
        title: Text(user.name),
        subtitle: Text(document),
        onTap: () {
          _userController.selectedUserId = user.id;
          Navigator.of(context).pushNamed('/user_profile_screen');
        },
      ),
    );
  }

  String _getInitials(String? name) {
    if (name == null || name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

}
