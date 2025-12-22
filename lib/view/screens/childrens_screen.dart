import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/view/widgets/add_child_dialog.dart';
import 'package:kids_space/service/child_service.dart';

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
          return c.name.toLowerCase().contains(query) || (c.document ?? '').toLowerCase().contains(query);
        }).toList();
        _filteredChildren.sort((a, b) => a.name.compareTo(b.name));
      });
    });
  }

  Future<void> _loadChildren() async {
    final companyId = _companyController.companySelected?.id;
    if (companyId == null) {
      setState(() {
        _allChildren = [];
        _filteredChildren = [];
      });
      return;
    }
    final list = await _childController.getChildrenByCompanyId(companyId);
    list.sort((a, b) => a.name.compareTo(b.name));
    setState(() {
      _allChildren = list;
      _filteredChildren = List.from(_allChildren);
    });
  }

  Future<void> _onRefresh() async {
    await _loadChildren();
  }

  void _onAddChild() {
    final companyId = _companyController.companySelected?.id;
    showDialog<Child>(
      context: context,
      builder: (_) => AddChildDialog(
        companyId: companyId,
        onCreate: (child) {
          ChildService().addChild(child);
        },
      ),
    ).then((created) {
      if (created != null) {
        _loadChildren();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Criança cadastrada')));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crianças cadastradas'), automaticallyImplyLeading: false),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                _searchField(),
                const SizedBox(height: 16),
                _childrenList(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddChild,
        child: const Icon(Icons.add),
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
        child: _allChildren.isEmpty
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

  Widget _childTile(Child child) {
    return Card(
      key: ValueKey(child.id),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.child_care)),
        title: Text(child.name),
        subtitle: Text(child.document ?? ''),
        onTap: () {
          // TODO: navigate to child profile
        },
      ),
    );
  }
}
