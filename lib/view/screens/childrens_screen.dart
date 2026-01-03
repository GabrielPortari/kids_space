import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/user.dart';
import 'package:kids_space/util/string_utils.dart';
import 'package:kids_space/view/design_system/app_text.dart';
import 'package:kids_space/view/design_system/app_theme.dart';
import 'package:kids_space/view/screens/profile_screen.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ChildrensScreen extends StatefulWidget {
  const ChildrensScreen({super.key});

  @override
  State<ChildrensScreen> createState() => _ChildrensScreenState();
}

class _ChildrensScreenState extends State<ChildrensScreen> {
  final CompanyController _companyController = GetIt.I.get<CompanyController>();
  final ChildController _childController = GetIt.I.get<ChildController>();

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  List<Child> _allChildren = [];
  List<Child> _filteredChildren = [];
  late Map<String, List<User>> _childrenResponsibles = {};
  bool _refreshLoading = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    // initial load
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadChildren());
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
      final query = _searchController.text.trim().toLowerCase();
      setState(() {
        _filteredChildren = _allChildren.where((c) {
          final childName = (c.name ?? '').toLowerCase();
          final responsibles = _childrenResponsibles[c.id] ?? [];
          final responsibleName = responsibles.isNotEmpty ? (responsibles.first.name ?? '').toLowerCase() : '';
          return childName.contains(query) || responsibleName.contains(query);
        }).toList();
        _filteredChildren.sort((a, b) {
          if ((a.isActive ?? false) && !(b.isActive ?? false)) return -1;
          if ((!(a.isActive ?? false)) && (b.isActive ?? false)) return 1;
          return (a.name ?? '').compareTo(b.name ?? '');
        });
      });
    });
  }

  Future<void> _loadChildren() async {
    final companyId = _companyController.companySelected?.id;
    if (companyId == null) {
      setState(() {
        _allChildren = [];
        _filteredChildren = [];
        _childrenResponsibles = {};
      });
      return;
    }
    setState(() => _refreshLoading = true);
    final list = await _childController.getChildrenByCompanyId(companyId);
    list.sort((a, b) {
      if ((a.isActive ?? false) && !(b.isActive ?? false)) return -1;
      if ((!(a.isActive ?? false)) && (b.isActive ?? false)) return 1;
      return (a.name ?? '').compareTo(b.name ?? '');
    });
    setState(() {
      _allChildren = list;
      _filteredChildren = List.from(_allChildren);
      _childrenResponsibles = _childController.getChildrenWithResponsibles(_allChildren);
      _refreshLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    await _loadChildren();
  }

  @override
  Widget build(BuildContext context) {
    final bool showAppBar = Navigator.canPop(context);
    final double topSpacing = showAppBar ? 8.0 : 8 + MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: showAppBar ? AppBar(title: const Text('Crianças'), leading: Navigator.canPop(context) ? const BackButton() : null,) : null,
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
                    _childrenList(),
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
        labelText: 'Buscar criança',
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  setState(() {
                    _filteredChildren = List.from(_allChildren);
                  });
                },
              ),
      ),
    );
  }

  Widget _childrenList() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async => await _onRefresh(),
        child: _refreshLoading
            ? _buildSkeletonList()
            : _allChildren.isEmpty
                ? ListView(
                    padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                    children: const [
                      Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 24.0), child: Text('Nenhuma criança cadastrada', style: TextStyle(color: Colors.grey, fontSize: 16))))
                    ],
                  )
                : _filteredChildren.isEmpty
                    ? ListView(
                        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                        children: const [
                          Center(child: Padding(padding: EdgeInsets.symmetric(vertical: 24.0), child: Text('Nenhuma criança encontrada', style: TextStyle(color: Colors.grey, fontSize: 16))))
                        ],
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                        itemCount: _filteredChildren.length,
                        itemBuilder: (context, index) => _childTile(_filteredChildren[index]),
                      ),
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

  Widget _childTile(Child child) {
    final responsibles = _childrenResponsibles[child.id] ?? [];
    final responsible = responsibles.isNotEmpty ? responsibles.first : null;
    return Card(
      key: ValueKey(child.id),
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          if (responsible != null) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => 
              ProfileScreen(selectedUser: responsible))
            );
          }
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
                    backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                    child: TextBodyMedium(getInitials(child.name)),
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
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (child.isActive ?? false)
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
                    Text('Responsável: ${responsible?.name ?? ''}', style: const TextStyle(fontSize: 15)),
                    Text('Telefone: ${responsible?.phone ?? ''}', style: const TextStyle(fontSize: 15, color: Colors.grey)),
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
