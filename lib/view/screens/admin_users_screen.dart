import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/admin_controller.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/model/admin.dart';
import 'package:kids_space/model/address.dart';
import 'package:kids_space/util/localization_service.dart';

final AuthController _authController = GetIt.I<AuthController>();

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final AdminController _adminController = GetIt.I<AdminController>();
  final TextEditingController _searchController = TextEditingController();

  bool get _isMaster => _authController.role == UserRole.master;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _adminController.addListener(_controllerListener);
    _adminController.refreshAdmins();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _adminController.removeListener(_controllerListener);
    super.dispose();
  }

  void _controllerListener() {
    final err = _adminController.lastError;
    if (err != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro ao carregar admins: $err')));
      _adminController.lastError = null;
    }
  }

  void _onSearchChanged() {
    _adminController.searchFilter = _searchController.text.trim();
    if (mounted) setState(() {});
  }

  Future<void> _onRefresh() async {
    await _adminController.refreshAdmins();
  }

  Map<String, dynamic> _toPayloadFromForm(Map<String, String> input) {
    final payload = <String, dynamic>{
      'name': input['name']?.trim(),
      'email': input['email']?.trim().toLowerCase(),
      'document': input['document']?.trim(),
      'contact': input['contact']?.trim(),
    };

    final address = Address(
      address: input['address']?.trim(),
      number: input['number']?.trim(),
      complement: input['complement']?.trim(),
      neighborhood: input['neighborhood']?.trim(),
      city: input['city']?.trim(),
      state: input['state']?.trim(),
      zipcode: input['zipcode']?.trim(),
    );
    final addressJson = address.toJson()
      ..removeWhere((_, value) => value == null || value.toString().isEmpty);
    if (addressJson.isNotEmpty) {
      payload['address'] = addressJson;
    }

    payload.removeWhere(
      (_, value) => value == null || value.toString().isEmpty,
    );
    return payload;
  }

  Future<Map<String, dynamic>?> _showAdminFormDialog({
    required String title,
    Admin? initial,
    bool allowActiveField = true,
  }) async {
    final nameController = TextEditingController(text: initial?.name ?? '');
    final emailController = TextEditingController(text: initial?.email ?? '');
    final documentController = TextEditingController(
      text: initial?.document ?? '',
    );
    final contactController = TextEditingController(
      text: initial?.contact ?? '',
    );
    final addressController = TextEditingController(
      text: initial?.address?.address ?? '',
    );
    final numberController = TextEditingController(
      text: initial?.address?.number ?? '',
    );
    final complementController = TextEditingController(
      text: initial?.address?.complement ?? '',
    );
    final neighborhoodController = TextEditingController(
      text: initial?.address?.neighborhood ?? '',
    );
    final cityController = TextEditingController(
      text: initial?.address?.city ?? '',
    );
    final stateController = TextEditingController(
      text: initial?.address?.state ?? '',
    );
    final zipcodeController = TextEditingController(
      text: initial?.address?.zipcode ?? '',
    );

    bool active = initial?.active ?? true;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) => AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: 560,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nome*'),
                    ),
                    TextField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email*'),
                      keyboardType: TextInputType.emailAddress,
                    ),
                    TextField(
                      controller: documentController,
                      decoration: const InputDecoration(labelText: 'Documento'),
                    ),
                    TextField(
                      controller: contactController,
                      decoration: const InputDecoration(labelText: 'Contato'),
                    ),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(labelText: 'Endereco'),
                    ),
                    TextField(
                      controller: numberController,
                      decoration: const InputDecoration(labelText: 'Numero'),
                    ),
                    TextField(
                      controller: complementController,
                      decoration: const InputDecoration(
                        labelText: 'Complemento',
                      ),
                    ),
                    TextField(
                      controller: neighborhoodController,
                      decoration: const InputDecoration(labelText: 'Bairro'),
                    ),
                    TextField(
                      controller: cityController,
                      decoration: const InputDecoration(labelText: 'Cidade'),
                    ),
                    TextField(
                      controller: stateController,
                      decoration: const InputDecoration(labelText: 'Estado'),
                    ),
                    TextField(
                      controller: zipcodeController,
                      decoration: const InputDecoration(labelText: 'CEP'),
                    ),
                    if (allowActiveField)
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Ativo'),
                        value: active,
                        onChanged: (v) => setDialogState(() => active = v),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: Text(translate('buttons.cancel')),
              ),
              TextButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final email = emailController.text.trim();
                  if (name.isEmpty || email.isEmpty) {
                    ScaffoldMessenger.of(dialogContext).showSnackBar(
                      const SnackBar(
                        content: Text('Nome e email sao obrigatorios.'),
                      ),
                    );
                    return;
                  }

                  Navigator.of(dialogContext).pop({
                    'name': name,
                    'email': email,
                    'document': documentController.text,
                    'contact': contactController.text,
                    'address': addressController.text,
                    'number': numberController.text,
                    'complement': complementController.text,
                    'neighborhood': neighborhoodController.text,
                    'city': cityController.text,
                    'state': stateController.text,
                    'zipcode': zipcodeController.text,
                    'active': active,
                  });
                },
                child: const Text('Salvar'),
              ),
            ],
          ),
        );
      },
    );

    nameController.dispose();
    emailController.dispose();
    documentController.dispose();
    contactController.dispose();
    addressController.dispose();
    numberController.dispose();
    complementController.dispose();
    neighborhoodController.dispose();
    cityController.dispose();
    stateController.dispose();
    zipcodeController.dispose();

    return result;
  }

  Future<void> _onCreateAdmin() async {
    if (!_isMaster) return;
    final form = await _showAdminFormDialog(title: 'Novo admin');
    if (form == null) return;

    final payload = _toPayloadFromForm(
      form.map((k, v) => MapEntry(k, v?.toString() ?? '')),
    );
    payload['active'] = form['active'] == true;

    final created = await _adminController.createAdmin(payload);
    if (!mounted) return;
    if (created != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin criado com sucesso.')),
      );
    }
  }

  Future<void> _onEditAdmin(Admin admin) async {
    final form = await _showAdminFormDialog(
      title: 'Editar admin',
      initial: admin,
    );
    if (form == null || admin.id == null) return;

    final payload = _toPayloadFromForm(
      form.map((k, v) => MapEntry(k, v?.toString() ?? '')),
    );
    payload['active'] = form['active'] == true;

    final updated = await _adminController.updateAdmin(admin.id!, payload);
    if (!mounted) return;
    if (updated != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Admin atualizado com sucesso.')),
      );
    }
  }

  Future<void> _onDeleteAdmin(Admin admin) async {
    if (!_isMaster || admin.id == null) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Excluir admin'),
        content: Text('Deseja excluir ${admin.name ?? 'este admin'}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(translate('buttons.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final ok = await _adminController.deleteAdmin(admin.id!);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Admin excluido com sucesso.' : 'Falha ao excluir admin.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admins do Sistema')),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 900),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              labelText: 'Buscar admin',
                              prefixIcon: const Icon(Icons.search),
                              border: const OutlineInputBorder(),
                              suffixIcon: _searchController.text.isEmpty
                                  ? null
                                  : IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () {
                                        _searchController.clear();
                                        _adminController.searchFilter = '';
                                        setState(() {});
                                      },
                                    ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        DropdownButton<bool?>(
                          value: _adminController.activeFilter,
                          hint: const Text('Status'),
                          items: const [
                            DropdownMenuItem<bool?>(
                              value: null,
                              child: Text('Todos'),
                            ),
                            DropdownMenuItem<bool?>(
                              value: true,
                              child: Text('Ativos'),
                            ),
                            DropdownMenuItem<bool?>(
                              value: false,
                              child: Text('Inativos'),
                            ),
                          ],
                          onChanged: (value) {
                            _adminController.activeFilter = value;
                            _onRefresh();
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _onRefresh,
                        child: AnimatedBuilder(
                          animation: _adminController,
                          builder: (_, __) {
                            if (_adminController.refreshLoading) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final admins = _adminController.filteredAdmins;
                            if (admins.isEmpty) {
                              return ListView(
                                children: const [
                                  SizedBox(height: 120),
                                  Center(
                                    child: Text('Nenhum admin encontrado.'),
                                  ),
                                ],
                              );
                            }

                            return ListView.separated(
                              itemCount: admins.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (_, index) =>
                                  _adminTile(admins[index]),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _isMaster
          ? FloatingActionButton(
              tooltip: 'Criar admin',
              onPressed: _onCreateAdmin,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _adminTile(Admin admin) {
    final isActive = admin.active ?? true;
    return Card(
      child: ListTile(
        onTap: () async {
          if (admin.id == null) return;
          final fetched = await _adminController.getAdminById(admin.id!);
          if (!mounted || fetched == null) return;
          _showDetailsDialog(fetched);
        },
        leading: CircleAvatar(
          backgroundColor: Theme.of(
            context,
          ).colorScheme.primary.withValues(alpha: 0.2),
          child: const Icon(Icons.admin_panel_settings),
        ),
        title: Text(admin.name ?? '-'),
        subtitle: Text('${admin.email ?? '-'}\n${admin.document ?? ''}'),
        isThreeLine: true,
        trailing: Wrap(
          spacing: 8,
          children: [
            Chip(
              label: Text(isActive ? 'Ativo' : 'Inativo'),
              backgroundColor: isActive
                  ? Colors.green.withValues(alpha: 0.12)
                  : Colors.red.withValues(alpha: 0.12),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'edit') {
                  _onEditAdmin(admin);
                } else if (value == 'delete') {
                  _onDeleteAdmin(admin);
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem<String>(
                  value: 'edit',
                  child: Text('Editar'),
                ),
                if (_isMaster)
                  const PopupMenuItem<String>(
                    value: 'delete',
                    child: Text('Excluir'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDetailsDialog(Admin admin) async {
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(admin.name ?? 'Admin'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${admin.email ?? '-'}'),
            Text('Documento: ${admin.document ?? '-'}'),
            Text('Contato: ${admin.contact ?? '-'}'),
            Text('Status: ${(admin.active ?? true) ? 'Ativo' : 'Inativo'}'),
            const SizedBox(height: 8),
            Text('Endereco: ${admin.address?.address ?? '-'}'),
            Text('Numero: ${admin.address?.number ?? '-'}'),
            Text('Complemento: ${admin.address?.complement ?? '-'}'),
            Text('Bairro: ${admin.address?.neighborhood ?? '-'}'),
            Text('Cidade: ${admin.address?.city ?? '-'}'),
            Text('Estado: ${admin.address?.state ?? '-'}'),
            Text('CEP: ${admin.address?.zipcode ?? '-'}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(translate('buttons.ok')),
          ),
        ],
      ),
    );
  }
}
