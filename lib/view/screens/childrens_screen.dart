import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/controller/user_controller.dart';
import 'package:kids_space/model/child.dart';
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
      _childController.childFilter = _searchController.text.trim();
      if (mounted) setState(() {});
    });
  }

  Future<void> _onRefresh() async {
    final companyId = _companyController.companySelected?.id;
    await _childController.refreshChildrenForCompany(companyId);
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
                    _childController.childFilter = '';
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
        child: Observer(builder: (_) {
          final filtered = _childController.filteredChildren;

          if (_childController.refreshLoading) {
            return _buildSkeletonList();
          }

          if (filtered.isEmpty) {
            return ListView(padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0), children: [
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Text(_searchController.text.isEmpty ? 'Nenhuma criança cadastrada' : 'Nenhuma criança encontrada', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                ),
              )
            ]);
          }
          return ListView.builder(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            itemCount: _childController.filteredChildren.length,
            itemBuilder: (context, index) => _childTile(_childController.filteredChildren[index]),
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

  Widget _childTile(Child child) {
    final firstResponsible = child.responsibleUserIds != null && child.responsibleUserIds!.isNotEmpty
        ? _userController.getUserById(child.responsibleUserIds!.first)
        : null;

    return Card(
      key: ValueKey(child.id),
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => 
            ProfileScreen(selectedChild: child))
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
                        if (child.checkedIn ?? false)
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
                    Text('Responsável: ${firstResponsible?.name ?? '-'}', style: const TextStyle(fontSize: 15)),
                    Text('Telefone: ${firstResponsible?.phone ?? '-'}', style: const TextStyle(fontSize: 15, color: Colors.grey)),
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
