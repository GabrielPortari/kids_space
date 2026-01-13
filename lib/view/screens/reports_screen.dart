import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/activity_log_controller.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/model/activity_log.dart';
import 'package:kids_space/controller/attendance_controller.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/model/attendance.dart';
import 'package:kids_space/controller/user_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ActivityLogController _controller = GetIt.I<ActivityLogController>();
  final AttendanceController _attendanceController = GetIt.I<AttendanceController>();
  final CompanyController _companyController = GetIt.I<CompanyController>();
  final UserController _userController = GetIt.I<UserController>();
  final CollaboratorController _collabController = GetIt.I<CollaboratorController>();
  DateTime? _from;
  DateTime? _to;
  final DateFormat _fmt = DateFormat('dd/MM/yyyy HH:mm');
  final List<_ReportItem> _items = [];
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    if (_isRefreshing) return;
    _isRefreshing = true;
    try {
      await _controller.loadLogs(from: _from, to: _to);
    // determine companyId (use selected if available)
    String companyId = _companyController.companySelected?.id ?? 'comp1';
    // Build display items by resolving names to avoid many FutureBuilders in list
    _items.clear();
    final activity = _controller.logs.where((l) {
      final ts = l.createdAt;
      if (ts == null) return false;
      if (_from != null && ts.isBefore(_from!)) return false;
      if (_to != null && ts.isAfter(_to!)) return false;
      return true;
    }).toList();


    // Resolve activity items
    for (final l in activity) {
      String? entityName = await _resolveEntityNameAsync(l.entityType, l.entityId);
      String? actorName = await _resolveActorNameAsync(l.actorId);
      _items.add(_ReportItem(
        kind: _ReportKind.activity,
        title: '${l.action.name.toUpperCase()} — ${l.entityType.name}',
        primary: entityName ?? l.entityId,
        secondary: actorName,
        date: l.createdAt ?? DateTime.now(),
        details: l.entityCreatedAt != null ? 'Entidade criada: ${_fmt.format(l.entityCreatedAt!)}' : null,
      ));
    }

    // sort desc
    _items.sort((a, b) => b.date.compareTo(a.date));

    } finally {
      _isRefreshing = false;
      setState(() {});
    }
  }

  Future<void> _pickFrom() async {
    final now = DateTime.now();
    final initial = _from ?? now.subtract(const Duration(days: 7));
    final picked = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (picked != null) setState(() => _from = picked);
  }

  Future<void> _pickTo() async {
    final now = DateTime.now();
    final initial = _to ?? now;
    final picked = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(2000), lastDate: DateTime(2100));
    if (picked != null) setState(() => _to = picked.add(const Duration(hours: 23, minutes: 59, seconds: 59)));
  }

  Widget _buildFilters() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          Row(children: [
            Expanded(child: TextButton(onPressed: _pickFrom, child: Text(_from == null ? 'Data inicial' : DateFormat('dd/MM/yyyy').format(_from!)))),
            const SizedBox(width: 8),
            Expanded(child: TextButton(onPressed: _pickTo, child: Text(_to == null ? 'Data final' : DateFormat('dd/MM/yyyy').format(_to!)))),
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            TextButton(onPressed: () { setState(() { _from = null; _to = null; }); _refresh(); }, child: const Text('Limpar')),
            const SizedBox(width: 8),
            ElevatedButton(onPressed: _refresh, child: const Text('Buscar')),
          ])
        ]),
      ),
    );
  }

  Widget _buildList() {
    if (_items.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Nenhum registro encontrado.')));

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: _items.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (ctx, i) {
        final it = _items[i];
        return _buildItemCard(it);
      },
    );
  }

  Widget _buildItemCard(_ReportItem it) {
    final color = it.kind == _ReportKind.activity ? Colors.blue.shade50 : Colors.green.shade50;
    final icon = it.kind == _ReportKind.activity ? Icons.event_note : (it.checkType == AttendanceType.checkin ? Icons.login : Icons.logout);

    return Card(
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            margin: const EdgeInsets.only(right: 12, top: 4),
            child: CircleAvatar(backgroundColor: Colors.white, child: Icon(icon, size: 20, color: Colors.black54)),
          ),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Flexible(child: Text(it.title, style: const TextStyle(fontWeight: FontWeight.w600))),
              Text(_fmt.format(it.date), style: const TextStyle(color: Colors.black54, fontSize: 12)),
            ]),
            const SizedBox(height: 6),
            if (it.primary != null) Text('Nome/ID: ${it.primary}', style: const TextStyle(color: Colors.black87)),
            if (it.secondary != null) Padding(padding: const EdgeInsets.only(top:4), child: Text('Por: ${it.secondary}', style: const TextStyle(color: Colors.black54))),
            if (it.details != null) Padding(padding: const EdgeInsets.only(top:6), child: Text(it.details!, style: const TextStyle(fontSize: 12, color: Colors.black54))),
          ])),
        ]),
      ),
    );
  }
  
  String? _resolveChildNameSync(String? id) {
    if (id == null) return null;
    final ch = GetIt.I<ChildController>().getChildById(id);
    return ch?.name;
  }

  Future<String?> _resolveActorNameAsync(String? id) async {
    if (id == null) return null;
    final c = await _collabController.getCollaboratorById(id);
    if (c != null) return c.name;
    final u = _userController.getUserById(id);
    if (u != null) return u.name;
    return null;
  }

  Future<String?> _resolveEntityNameAsync(ActivityEntityType type, String? id) async {
    if (id == null) return null;
    switch (type) {
      case ActivityEntityType.company:
        try {
          final comp = _companyController.getCompanyById(id);
          return comp?.fantasyName ?? comp?.corporateName;
        } catch (_) {
          return null;
        }
      case ActivityEntityType.collaborator:
        final c = await _collabController.getCollaboratorById(id);
        return c?.name;
      case ActivityEntityType.user:
        final u = _userController.getUserById(id);
        return u?.name;
      case ActivityEntityType.child:
        final ch = GetIt.I<ChildController>().getChildById(id);
        return ch?.name;
      case ActivityEntityType.other:
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(children: [
          _buildFilters(),
          const SizedBox(height: 12),
          Expanded(child: _buildList()),
        ]),
      ),
    );
  }
}

enum _ReportKind { activity, check }

class _ReportItem {
  final _ReportKind kind;
  final String title;
  final String? primary;
  final String? secondary;
  final DateTime date;
  final String? details;
  final AttendanceType? checkType;

  _ReportItem({required this.kind, required this.title, this.primary, this.secondary, required this.date, this.details, this.checkType});
}