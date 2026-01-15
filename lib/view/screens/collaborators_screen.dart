import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/util/string_utils.dart';
import 'package:kids_space/view/design_system/app_text.dart';
import 'package:kids_space/view/screens/profile_screen.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CollaboratorsScreen extends StatefulWidget {
  const CollaboratorsScreen({super.key});

  @override
  State<CollaboratorsScreen> createState() => _CollaboratorsScreenState();
}

class _CollaboratorsScreenState extends State<CollaboratorsScreen> {
  final CompanyController _companyController = GetIt.I.get<CompanyController>();
  final CollaboratorController _collaboratorController = GetIt.I.get<CollaboratorController>();

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  bool _loading = false;

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
      _collaboratorController.collaboratorFilter = _searchController.text.trim();
      if (mounted) setState(() {});
    });
  }

  Future<void> _onRefresh() async {
    final companyId = _companyController.companySelected?.id;
    await _collaboratorController.refreshCollaboratorsForCompany(companyId);
  }

  void _onTapCollaborator(Collaborator c) async {
    await _collaboratorController.setSelectedCollaborator(c);
    if (!mounted) return;
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ProfileScreen(selectedCollaborator: c)));
  }

  @override
  Widget build(BuildContext context) {
    final bool showAppBar = Navigator.canPop(context);
    final double topSpacing = showAppBar ? 8.0 : 8 + MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('Colaboradores'), leading: Navigator.canPop(context) ? const BackButton() : null,) : null,
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
                    _list(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchField() {
    return TextField(
      controller: _searchController,
      decoration: InputDecoration(
        labelText: 'Buscar colaborador',
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _collaboratorController.collaboratorFilter = '';
                },
              ),
      ),
    );
  }

  Widget _list() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async => await _onRefresh(),
        child: _loading
            ? _buildSkeleton()
            : Observer(builder: (_) {
                final filtered = _collaboratorController.filteredCollaborators;
                if (filtered.isEmpty) {
                  return ListView(padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0), children: [
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Text(_searchController.text.isEmpty ? 'Nenhum colaborador cadastrado' : 'Nenhum colaborador encontrado', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                      ),
                    )
                  ]);
                }
                return ListView.builder(
                  padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _tile(filtered[index]),
                );
              }),
      ),
    );
  }

  Widget _buildSkeleton() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
      itemCount: 6,
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

  Widget _tile(Collaborator c) {
    return Card(
      key: ValueKey(c.id),
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _onTapCollaborator(c),
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
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    child: TextBodyMedium(getInitials(c.name)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextHeaderSmall(c.name ?? '', heavy: true),
                    const SizedBox(height: 4),
                    TextBodyMedium(c.email ?? '', style:TextStyle( color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.8))),
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
