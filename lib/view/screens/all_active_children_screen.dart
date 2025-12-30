import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/user.dart';
import 'package:kids_space/util/string_utils.dart';
import 'package:kids_space/view/design_system/app_theme.dart';

class AllActiveChildrenScreen extends StatefulWidget {
  const AllActiveChildrenScreen({super.key});

  @override
  State<AllActiveChildrenScreen> createState() =>
      _AllActiveChildrenScreenState();
}

class _AllActiveChildrenScreenState extends State<AllActiveChildrenScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ChildController _childController = GetIt.I<ChildController>();
  final CompanyController _companyController = GetIt.I<CompanyController>();

  List<Child> _allChildren = [];
  List<Child> _filteredChildren = [];

  late Map<String, List<User>> _childrenResponsibles;

  @override
  void initState() {
    super.initState();
    _loadActiveChildrenWithResponsibles();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      final query = _searchController.text.toLowerCase();
      _filteredChildren = _allChildren.where((child) {
        final childName = child.name?.toLowerCase() ?? '';
        final responsibles = _childrenResponsibles[child.id] ?? [];
        final responsibleName = responsibles.isNotEmpty
            ? responsibles.first.name?.toLowerCase() ?? ''
            : '';
        return childName.contains(query) || responsibleName.contains(query);
      }).toList();
      _filteredChildren.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
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
        title: const Text('Todas as crianças ativas'),
      ),
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
                    _searchField(),
                    const SizedBox(height: 16),
                    _childrenList(),
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
      decoration: const InputDecoration(
        labelText: 'Buscar criança',
        prefixIcon: Icon(Icons.search),
        border: OutlineInputBorder(),
      ),
    );
  }

  Widget _childrenList() {
    return Expanded(
      child: _allChildren.isEmpty
          ? const Center(child: Text('Nenhuma criança ativa'))
          : _filteredChildren.isEmpty
          ? const Center(child: Text('Nenhuma criança encontrada'))
          : ListView.builder(
              itemCount: _filteredChildren.length,
              itemBuilder: (context, index) {
                final child = _filteredChildren[index];
                final responsibles = _childrenResponsibles[child.id] ?? [];
                final responsible = responsibles.isNotEmpty
                    ? responsibles.first
                    : null;
                return _childCard(child, responsible);
              },
            ),
    );
  }

  Widget _childCard(Child child, User? responsible) {
    return Card(
      key: ValueKey(child.id),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  child: Text(
                    getInitials(child.name),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        child.name ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),

                      Container(
                        margin: const EdgeInsets.only(left: 8),
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: success,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Responsável: ${responsible?.name ?? ''}',
                    style: const TextStyle(fontSize: 15),
                  ),
                  Text(
                    'Telefone: ${responsible?.phone ?? ''}',
                    style: const TextStyle(fontSize: 15, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _loadActiveChildrenWithResponsibles() {
    final companyId = _companyController.companySelected?.id;
    if (companyId != null) {
      _allChildren = _childController.activeCheckedInChildren(companyId);
      _allChildren.sort((a, b) => (a.name ?? '').compareTo(b.name ?? ''));
      _filteredChildren = List.from(_allChildren);
      _childrenResponsibles = _childController.getChildrenWithResponsibles(
        _allChildren,
      );
    } else {
      _allChildren = [];
      _filteredChildren = [];
      _childrenResponsibles = {};
    }
  }
}
