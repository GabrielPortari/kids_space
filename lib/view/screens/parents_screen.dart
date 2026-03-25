import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/parent_controller.dart';
import 'package:kids_space/model/parent.dart';
import 'package:kids_space/model/address.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kids_space/util/string_utils.dart';
import 'package:kids_space/view/screens/profile_screen.dart';
import 'package:kids_space/view/widgets/edit_entity_bottom_sheet.dart';
import 'package:kids_space/view/widgets/skeleton_list.dart';
import 'package:kids_space/util/localization_service.dart';

class ParentsScreen extends StatefulWidget {
  const ParentsScreen({super.key});

  @override
  State<ParentsScreen> createState() => _ParentsScreenState();
}

class _ParentsScreenState extends State<ParentsScreen> {
  final CompanyController _companyController = GetIt.I.get<CompanyController>();
  final ParentController _parentController = GetIt.I.get<ParentController>();

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
      _parentController.userFilter = _searchController.text.trim();
      if (mounted) setState(() {});
    });
  }

  Future<void> _onRefresh() async {
    final companyId = _companyController.company?.id;
    await _parentController.refreshUsersForCompany(companyId);
  }

  Future<void> _onAddUser() async {
    // Personal data fields aligned with Parent model and Address
    final dataFields = [
      FieldDefinition(
        key: 'name',
        initialValue: null,
        label: translate('profile.name', defaultText: 'Name'),
        required: true,
      ),
      FieldDefinition(
        key: 'email',
        initialValue: null,
        label: translate('profile.email', defaultText: 'Email'),
        type: FieldType.email,
      ),
      FieldDefinition(
        key: 'phone',
        initialValue: null,
        label: translate('profile.phone', defaultText: 'Phone'),
        type: FieldType.phone,
        required: true,
      ),
      FieldDefinition(
        key: 'document',
        initialValue: null,
        label: translate('profile.document', defaultText: 'Document'),
        type: FieldType.number,
        required: true,
      ),
      FieldDefinition(
        key: 'address',
        initialValue: null,
        label: translate('profile.address', defaultText: 'Address'),
      ),
      FieldDefinition(
        key: 'addressNumber',
        initialValue: null,
        label: translate(
          'profile.address_number',
          defaultText: 'Address Number',
        ),
      ),
      FieldDefinition(
        key: 'addressComplement',
        initialValue: null,
        label: translate(
          'profile.address_complement',
          defaultText: 'Address Complement',
        ),
      ),
      FieldDefinition(
        key: 'neighborhood',
        initialValue: null,
        label: translate('profile.neighborhood', defaultText: 'Neighborhood'),
      ),
      FieldDefinition(
        key: 'city',
        initialValue: null,
        label: translate('profile.city', defaultText: 'City'),
      ),
      FieldDefinition(
        key: 'state',
        initialValue: null,
        label: translate('profile.state', defaultText: 'State'),
      ),
      FieldDefinition(
        key: 'zipCode',
        initialValue: null,
        label: translate('profile.zip_code', defaultText: 'Zip Code'),
      ),
    ];

    final personalData = await showEditEntityBottomSheet(
      context: context,
      title: translate(
        'profile.personal_title',
        defaultText: 'Personal Information',
      ),
      fields: dataFields,
    );
    if (personalData == null) return; // cancelled

    final addr = Address(
      address: personalData['address']?.toString(),
      number: personalData['addressNumber']?.toString(),
      complement: personalData['addressComplement']?.toString(),
      neighborhood: personalData['neighborhood']?.toString(),
      city: personalData['city']?.toString(),
      state: personalData['state']?.toString(),
      zipcode: personalData['zipCode']?.toString(),
    );

    final newParent = Parent(
      name: personalData['name']?.toString(),
      email: personalData['email']?.toString(),
      document: personalData['document']?.toString(),
      contact: personalData['phone']?.toString(),
      address: addr,
      companyId: _companyController.company?.id,
    );

    await _parentController.createUser(newParent);
  }

  @override
  Widget build(BuildContext context) {
    final bool showAppBar = Navigator.canPop(context);
    final double topSpacing = showAppBar
        ? 8.0
        : 8 + MediaQuery.of(context).padding.top;

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(translate('parents.title', defaultText: 'Parents')),
              leading: Navigator.canPop(context) ? const BackButton() : null,
            )
          : null,
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
        labelText: translate('parents.search', defaultText: 'Search Parents'),
        prefixIcon: const Icon(Icons.search),
        border: const OutlineInputBorder(),
        suffixIcon: _searchController.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _parentController.userFilter = '';
                },
              ),
      ),
    );
  }

  Widget _userList() {
    return Expanded(
      child: RefreshIndicator(
        onRefresh: () async => await _onRefresh(),
        child: Observer(
          builder: (_) {
            final filtered = _parentController.filteredUsers;

            if (_parentController.refreshLoading) {
              return _buildSkeletonList();
            }

            if (filtered.isEmpty) {
              return ListView(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        _searchController.text.isEmpty
                            ? translate(
                                'parents.empty',
                                defaultText: 'No parents found',
                              )
                            : translate(
                                'parents.not_found',
                                defaultText: 'No parents match your search',
                              ),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
              itemCount: filtered.length,
              itemBuilder: (context, index) => _userTile(filtered[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkeletonList() {
    return const SkeletonList(itemCount: 8);
  }

  Widget _userTile(Parent user) {
    String document = user.document ?? '';
    if (document.length >= 11) {
      document = document.replaceRange(3, document.length, '.***.***-**');
    } else if (document.length >= 2) {
      document = document.replaceRange(2, document.length, '.***.***-*');
    }
    return Card(
      key: ValueKey(user.id),
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          _parentController.selectedUserId = user.id;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProfileScreen(selectedUser: user),
            ),
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
                    backgroundColor: Theme.of(
                      context,
                    ).colorScheme.primary.withValues(alpha: 0.2),
                    child: Text(
                      getInitials(user.name),
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      document,
                      style: const TextStyle(fontSize: 15, color: Colors.grey),
                    ),
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
