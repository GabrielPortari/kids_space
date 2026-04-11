import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/admin_management_controller.dart';
import 'package:kids_space/model/attendance.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/model/parent.dart';

enum AdminManagementEntityType { collaborators, parents, children, attendances }

class AdminManagementEntityScreen extends StatefulWidget {
  const AdminManagementEntityScreen({super.key, required this.entityType});

  final AdminManagementEntityType entityType;

  @override
  State<AdminManagementEntityScreen> createState() =>
      _AdminManagementEntityScreenState();
}

class _AdminManagementEntityScreenState
    extends State<AdminManagementEntityScreen> {
  final AdminManagementController _controller =
      GetIt.I<AdminManagementController>();

  final TextEditingController _companyIdController = TextEditingController();
  final TextEditingController _resourceIdController = TextEditingController();
  late final TextEditingController _payloadController;

  @override
  void initState() {
    super.initState();
    _payloadController = TextEditingController(text: _defaultPayload);
    _controller.addListener(_controllerListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerListener);
    _companyIdController.dispose();
    _resourceIdController.dispose();
    _payloadController.dispose();
    super.dispose();
  }

  String get _entityTitle {
    switch (widget.entityType) {
      case AdminManagementEntityType.collaborators:
        return 'Collaborators';
      case AdminManagementEntityType.parents:
        return 'Parents';
      case AdminManagementEntityType.children:
        return 'Children';
      case AdminManagementEntityType.attendances:
        return 'Attendances';
    }
  }

  String get _entityDescription {
    switch (widget.entityType) {
      case AdminManagementEntityType.collaborators:
        return 'CRUD e listagem de collaborators por company.';
      case AdminManagementEntityType.parents:
        return 'CRUD e listagem de responsáveis por company.';
      case AdminManagementEntityType.children:
        return 'CRUD e listagem de children por company.';
      case AdminManagementEntityType.attendances:
        return 'CRUD e listagem de attendances por company.';
    }
  }

  String get _defaultPayload {
    switch (widget.entityType) {
      case AdminManagementEntityType.collaborators:
        return '{\n  "name": "",\n  "email": "",\n  "document": "",\n  "contact": ""\n}';
      case AdminManagementEntityType.parents:
        return '{\n  "name": "",\n  "document": "",\n  "email": "",\n  "contact": "",\n  "address": {},\n  "children": []\n}';
      case AdminManagementEntityType.children:
        return '{\n  "name": "",\n  "parents": [],\n  "document": "",\n  "email": "",\n  "contact": ""\n}';
      case AdminManagementEntityType.attendances:
        return '{\n  "childId": "",\n  "responsibleIdWhoCheckedInId": "",\n  "notes": ""\n}';
    }
  }

  void _controllerListener() {
    final err = _controller.lastError;
    if (err != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $err')));
      _controller.lastError = null;
    }
  }

  Map<String, dynamic>? _parsePayloadOrNull() {
    final raw = _payloadController.text.trim();
    if (raw.isEmpty) return <String, dynamic>{};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payload precisa ser um JSON objeto.')),
      );
      return null;
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('JSON invalido no payload.')),
      );
      return null;
    }
  }

  String? _validateCompanyId() {
    final companyId = _companyIdController.text.trim();
    if (companyId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informe o companyId.')));
      return null;
    }
    return companyId;
  }

  String? _validateResourceId() {
    final id = _resourceIdController.text.trim();
    if (id.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informe o ID do recurso.')));
      return null;
    }
    return id;
  }

  Future<void> _loadAllByEntity() async {
    switch (widget.entityType) {
      case AdminManagementEntityType.collaborators:
        await _controller.loadAllCollaborators();
        break;
      case AdminManagementEntityType.parents:
        await _controller.loadAllParents();
        break;
      case AdminManagementEntityType.children:
        await _controller.loadAllChildren();
        break;
      case AdminManagementEntityType.attendances:
        await _controller.loadAllAttendances();
        break;
    }
  }

  Future<void> _createByEntity() async {
    final companyId = _validateCompanyId();
    if (companyId == null) return;
    final payload = _parsePayloadOrNull();
    if (payload == null) return;

    final created = switch (widget.entityType) {
      AdminManagementEntityType.collaborators =>
        await _controller.createCollaborator(companyId, payload),
      AdminManagementEntityType.parents => await _controller.createParent(
        companyId,
        payload,
      ),
      AdminManagementEntityType.children => await _controller.createChild(
        companyId,
        payload,
      ),
      AdminManagementEntityType.attendances =>
        await _controller.createAttendanceCheckin(companyId, payload),
    };

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          created != null
              ? 'Operacao de criacao concluida.'
              : 'Nao foi possivel concluir a criacao.',
        ),
      ),
    );
  }

  Future<void> _updateByEntity() async {
    final companyId = _validateCompanyId();
    if (companyId == null) return;
    final resourceId = _validateResourceId();
    if (resourceId == null) return;
    final payload = _parsePayloadOrNull();
    if (payload == null) return;

    final updated = switch (widget.entityType) {
      AdminManagementEntityType.collaborators =>
        await _controller.updateCollaborator(companyId, resourceId, payload),
      AdminManagementEntityType.parents => await _controller.updateParent(
        companyId,
        resourceId,
        payload,
      ),
      AdminManagementEntityType.children => await _controller.updateChild(
        companyId,
        resourceId,
        payload,
      ),
      AdminManagementEntityType.attendances =>
        await _controller.updateAttendance(companyId, resourceId, payload),
    };

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          updated != null
              ? 'Operacao de atualizacao concluida.'
              : 'Nao foi possivel concluir a atualizacao.',
        ),
      ),
    );
  }

  Future<void> _deleteByEntity() async {
    final companyId = _validateCompanyId();
    if (companyId == null) return;
    final resourceId = _validateResourceId();
    if (resourceId == null) return;

    final ok = switch (widget.entityType) {
      AdminManagementEntityType.collaborators =>
        await _controller.deleteCollaborator(companyId, resourceId),
      AdminManagementEntityType.parents => await _controller.deleteParent(
        companyId,
        resourceId,
      ),
      AdminManagementEntityType.children => await _controller.deleteChild(
        companyId,
        resourceId,
      ),
      AdminManagementEntityType.attendances =>
        await _controller.deleteAttendance(companyId, resourceId),
    };

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok ? 'Registro removido com sucesso.' : 'Registro nao encontrado.',
        ),
      ),
    );
  }

  Widget _overviewCard() {
    final data = _controller.companyOverview;
    if (data == null) {
      return const Text('Nenhum overview carregado.');
    }

    int countFrom(String key) {
      final value = data[key];
      if (value is List) return value.length;
      return 0;
    }

    final companyRaw = data['company'];
    final companyName = companyRaw is Map<String, dynamic>
        ? companyRaw['name']?.toString() ?? '-'
        : '-';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Empresa: $companyName'),
            const SizedBox(height: 8),
            Text('Collaborators: ${countFrom('collaborators')}'),
            Text('Parents: ${countFrom('parents')}'),
            Text('Children: ${countFrom('children')}'),
            Text('Attendances: ${countFrom('attendances')}'),
          ],
        ),
      ),
    );
  }

  Widget _allListWidget() {
    switch (widget.entityType) {
      case AdminManagementEntityType.collaborators:
        return _simpleList<Collaborator>(
          _controller.allCollaborators,
          (c) => '${c.name ?? '-'} (${c.email ?? '-'})',
        );
      case AdminManagementEntityType.parents:
        return _simpleList<Parent>(
          _controller.allParents,
          (p) => '${p.name ?? '-'} (${p.email ?? '-'})',
        );
      case AdminManagementEntityType.children:
        return _simpleList<Child>(
          _controller.allChildren,
          (c) => '${c.name ?? '-'} (${c.email ?? '-'})',
        );
      case AdminManagementEntityType.attendances:
        return _simpleList<Attendance>(
          _controller.allAttendances,
          (a) => '${a.id ?? '-'} | child: ${a.childId ?? '-'}',
        );
    }
  }

  Widget _simpleList<T>(List<T> data, String Function(T item) toLine) {
    if (data.isEmpty) {
      return const Text('Nenhum registro carregado.');
    }
    return SizedBox(
      height: 220,
      child: ListView.separated(
        itemCount: data.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (_, index) =>
            ListTile(dense: true, title: Text(toLine(data[index]))),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_entityTitle)),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _entityDescription,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _companyIdController,
                    decoration: const InputDecoration(
                      labelText: 'companyId',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: _controller.loading
                            ? null
                            : _loadAllByEntity,
                        child: const Text('GET all da entidade'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _resourceIdController,
                    decoration: const InputDecoration(
                      labelText: 'resourceId (para update/delete)',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _payloadController,
                    minLines: 7,
                    maxLines: 12,
                    decoration: const InputDecoration(
                      labelText: 'Payload JSON (create/update)',
                      border: OutlineInputBorder(),
                      alignLabelWithHint: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ElevatedButton(
                        onPressed: _controller.loading ? null : _createByEntity,
                        child: const Text('POST criar'),
                      ),
                      ElevatedButton(
                        onPressed: _controller.loading ? null : _updateByEntity,
                        child: const Text('PATCH atualizar'),
                      ),
                      ElevatedButton(
                        onPressed: _controller.loading ? null : _deleteByEntity,
                        child: const Text('DELETE remover'),
                      ),
                      OutlinedButton(
                        onPressed: _controller.loading
                            ? null
                            : _loadAllByEntity,
                        child: const Text('GET listar'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _allListWidget(),
                  const SizedBox(height: 16),
                  _overviewCard(),
                  if (_controller.loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AdminCompanyOverviewScreen extends StatefulWidget {
  const AdminCompanyOverviewScreen({super.key});

  @override
  State<AdminCompanyOverviewScreen> createState() =>
      _AdminCompanyOverviewScreenState();
}

class _AdminCompanyOverviewScreenState
    extends State<AdminCompanyOverviewScreen> {
  final AdminManagementController _controller =
      GetIt.I<AdminManagementController>();
  final TextEditingController _companyIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(_controllerListener);
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerListener);
    _companyIdController.dispose();
    super.dispose();
  }

  void _controllerListener() {
    final err = _controller.lastError;
    if (err != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Erro: $err')));
      _controller.lastError = null;
    }
  }

  String? _validateCompanyId() {
    final companyId = _companyIdController.text.trim();
    if (companyId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Informe o companyId.')));
      return null;
    }
    return companyId;
  }

  Future<void> _loadOverview() async {
    final companyId = _validateCompanyId();
    if (companyId == null) return;
    await _controller.loadCompanyOverview(companyId);
  }

  Widget _overviewCard() {
    final data = _controller.companyOverview;
    if (data == null) {
      return const Padding(
        padding: EdgeInsets.only(top: 16),
        child: Text('Nenhum overview carregado.'),
      );
    }

    int countFrom(String key) {
      final value = data[key];
      if (value is List) return value.length;
      return 0;
    }

    final companyRaw = data['company'];
    final companyName = companyRaw is Map<String, dynamic>
        ? companyRaw['name']?.toString() ?? '-'
        : '-';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Empresa: $companyName'),
            const SizedBox(height: 8),
            Text('Collaborators: ${countFrom('collaborators')}'),
            Text('Parents: ${countFrom('parents')}'),
            Text('Children: ${countFrom('children')}'),
            Text('Attendances: ${countFrom('attendances')}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Overview da empresa')),
      body: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) => SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Carregue o resumo da company sem misturar com operacoes de CRUD.',
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _companyIdController,
                    decoration: const InputDecoration(
                      labelText: 'companyId',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _controller.loading ? null : _loadOverview,
                    child: const Text('GET overview da company'),
                  ),
                  const SizedBox(height: 16),
                  _overviewCard(),
                  if (_controller.loading)
                    const Padding(
                      padding: EdgeInsets.only(top: 16),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
