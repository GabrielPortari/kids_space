import 'dart:async';

import 'package:flutter/material.dart';
// Using ChangeNotifier (CollaboratorController) so AnimatedBuilder is used instead
// import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/util/date_hour_util.dart';
import 'package:kids_space/util/localization_service.dart';
import 'package:kids_space/view/screens/profile_screen.dart';
import 'package:kids_space/view/widgets/edit_entity_bottom_sheet.dart';
import 'package:kids_space/view/widgets/person_list_tile.dart';
import 'package:kids_space/view/widgets/skeleton_list.dart';

class CollaboratorsScreen extends StatefulWidget {
  const CollaboratorsScreen({super.key});

  @override
  State<CollaboratorsScreen> createState() => _CollaboratorsScreenState();
}

class _CollaboratorsScreenState extends State<CollaboratorsScreen> {
  final CompanyController _companyController = GetIt.I.get<CompanyController>();
  final CollaboratorController _collaboratorController = GetIt.I
      .get<CollaboratorController>();

  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _onRefresh();
    _collaboratorController.addListener(_controllerListener);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _collaboratorController.removeListener(_controllerListener);
    super.dispose();
  }

  void _controllerListener() {
    final err = _collaboratorController.lastError;
    if (err != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar colaboradores: $err')),
      );
      // clear lastError to avoid repeated snackbars
      _collaboratorController.lastError = null;
    }
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _collaboratorController.collaboratorFilter = _searchController.text
          .trim();
      if (mounted) setState(() {});
    });
  }

  Future<void> _onRefresh() async {
    final companyId = _companyController.company?.id;
    await _collaboratorController.refreshCollaboratorsForCompany(companyId);
  }

  void _onTapCollaborator(Collaborator c) async {
    if (!mounted) return;
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ProfileScreen(selectedCollaborator: c)),
    );
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
              title: const Text('Colaboradores'),
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
                    _list(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddCollaborator,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _onAddCollaborator() async {
    // Step 1: personal data
    final dataFields = [
      FieldDefinition(
        key: 'name',
        initialValue: null,
        label: 'Nome*',
        required: true,
      ),
      FieldDefinition(
        key: 'birthDate',
        initialValue: null,
        label: 'Data de Nascimento',
        type: FieldType.date,
      ),
      FieldDefinition(
        key: 'email',
        initialValue: null,
        label: 'Email*',
        type: FieldType.email,
        required: true,
      ),
      FieldDefinition(
        key: 'phone',
        initialValue: null,
        label: 'Telefone',
        type: FieldType.phone,
      ),
      FieldDefinition(
        key: 'document',
        initialValue: null,
        label: 'Documento*',
        type: FieldType.number,
        required: true,
      ),
      FieldDefinition(key: 'address', initialValue: null, label: 'Endereço'),
      FieldDefinition(
        key: 'addressNumber',
        initialValue: null,
        label: 'Número',
      ),
      FieldDefinition(
        key: 'addressComplement',
        initialValue: null,
        label: 'Complemento',
      ),
      FieldDefinition(key: 'neighborhood', initialValue: null, label: 'Bairro'),
      FieldDefinition(key: 'city', initialValue: null, label: 'Cidade'),
      FieldDefinition(key: 'state', initialValue: null, label: 'Estado'),
      FieldDefinition(key: 'zipCode', initialValue: null, label: 'CEP'),
    ];

    final personalData = await showEditEntityBottomSheet(
      context: context,
      title: 'Dados pessoais',
      fields: dataFields,
    );
    if (personalData == null) return; // cancelled

    String? normalizeBirthDate(dynamic v) {
      if (v == null) return null;
      final s = v.toString();
      // dd/MM/yyyy -> ISO
      if (s.contains('/')) {
        final iso = formatDateToIsoString(s);
        if (iso != null) return iso;
      }
      // Try parse ISO-like
      try {
        final dt = DateTime.parse(s);
        return dt.toIso8601String();
      } catch (_) {}
      // Try dd-MM-yyyy
      final parts = s.split('-');
      if (parts.length == 3) {
        try {
          final d = int.parse(parts[0]);
          final m = int.parse(parts[1]);
          final y = int.parse(parts[2]);
          return DateTime(y, m, d).toIso8601String();
        } catch (_) {}
      }
      return s;
    }

    final Map<String, dynamic> payload = {
      'name': personalData['name']?.toString(),
      'email': personalData['email']?.toString(),
      'birthDate': normalizeBirthDate(personalData['birthDate']),
      'document': personalData['document']?.toString(),
      'contact': personalData['phone']?.toString(),
    };

    // build nested address object when any address field is provided
    final addr = <String, dynamic>{};
    if (personalData['address'] != null &&
        personalData['address'].toString().isNotEmpty) {
      addr['address'] = personalData['address']?.toString();
    }
    if (personalData['addressNumber'] != null &&
        personalData['addressNumber'].toString().isNotEmpty) {
      addr['number'] = personalData['addressNumber']?.toString();
    }
    if (personalData['addressComplement'] != null &&
        personalData['addressComplement'].toString().isNotEmpty) {
      addr['complement'] = personalData['addressComplement']?.toString();
    }
    if (personalData['neighborhood'] != null &&
        personalData['neighborhood'].toString().isNotEmpty) {
      addr['neighborhood'] = personalData['neighborhood']?.toString();
    }
    if (personalData['city'] != null &&
        personalData['city'].toString().isNotEmpty) {
      addr['city'] = personalData['city']?.toString();
    }
    if (personalData['state'] != null &&
        personalData['state'].toString().isNotEmpty) {
      addr['state'] = personalData['state']?.toString();
    }
    if (personalData['zipCode'] != null &&
        personalData['zipCode'].toString().isNotEmpty) {
      addr['zipCode'] = personalData['zipCode']?.toString();
    }

    if (addr.isNotEmpty) payload['address'] = addr;

    // show loading dialog
    if (mounted) setState(() {});
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );
    Collaborator? created;
    try {
      debugPrint('Creating collaborator with payload: $payload');
      created = await _collaboratorController.create(payload);
    } finally {
      // dismiss loading
      Navigator.of(context, rootNavigator: true).pop();
      if (mounted) setState(() {});
    }

    if (created != null) {
      await _onRefresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(translate('collaborators.created'))),
        );
      }
    } else {
      final err = _collaboratorController.lastError;
      final msg = err != null && err.isNotEmpty
          ? err
          : translate('collaborators.create_error');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
      }
      // clear the lastError after showing it once
      _collaboratorController.lastError = null;
    }
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
        child: AnimatedBuilder(
          animation: _collaboratorController,
          builder: (_, __) {
            if (_collaboratorController.refreshLoading) {
              return _buildSkeleton();
            }
            final filtered = _collaboratorController.filteredCollaborators;
            if (filtered.isEmpty) {
              return ListView(
                padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
                children: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Text(
                        _searchController.text.isEmpty
                            ? 'Nenhum colaborador cadastrado'
                            : 'Nenhum colaborador encontrado',
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
              itemBuilder: (context, index) => _tile(filtered[index]),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSkeleton() => const SkeletonList(itemCount: 8);

  Widget _tile(Collaborator c) => Padding(
    key: ValueKey(c.id),
    padding: const EdgeInsets.only(bottom: 8),
    child: PersonListTile(
      name: c.name,
      subtitle: c.email ?? c.document,
      onTap: () => _onTapCollaborator(c),
    ),
  );
}
