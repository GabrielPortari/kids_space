import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/user_controller.dart';
import 'package:kids_space/model/user.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kids_space/util/string_utils.dart';
import 'package:kids_space/view/screens/profile_screen.dart';
import 'package:kids_space/view/widgets/edit_entity_bottom_sheet.dart';
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
    _onRefresh();
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

  Future<void> _onAddUser() async {
    final fields = [
      FieldDefinition(key: 'name', label: 'Nome', required: true),
      FieldDefinition(key: 'contactEmail', label: 'Email', required: true),
      FieldDefinition(key: 'phone', label: 'Telefone', required: true),
      FieldDefinition(key: 'document', label: 'Documento', required: true),
    ];
    
    final result = await showEditEntityBottomSheet(context: context, title: 'Adicionar usuário', fields: fields,);
    if (result != null) {
      debugPrint('DebuggerLog: UsersScreen.editModal.result -> $result');
      // TODO
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool showAppBar = Navigator.canPop(context);
    final double topSpacing = showAppBar ? 8.0 : 8 + MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('Usuários'), leading: Navigator.canPop(context) ? const BackButton() : null,) : null,
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(height: topSpacing),
                    _searchField(),
                    const SizedBox(height: 16),
                    _userList(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
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
            itemBuilder: (context, index) => _userTile(filtered[index]),
          );
        }),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
      itemCount: 8,
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
    String document = user.document ?? '';
    document.length == 11 ?
      document = document.replaceRange(3, document.length, '.***.***-**') :
      document = document.replaceRange(2, document.length, '.***.***-*');
    return Card(
      key: ValueKey(user.id),
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _userController.selectedUserId = user.id;    
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => 
            ProfileScreen(selectedUser: user))
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                width: 56,
                child: Center(
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha:0.2),
                    child: Text(getInitials(user.name), style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.name ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(document, style: const TextStyle(fontSize: 15, color: Colors.grey)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
