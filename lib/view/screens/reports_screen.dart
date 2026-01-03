import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kids_space/service/activity_log_service.dart';
import 'package:kids_space/model/activity_log.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final ActivityLogService _logService = ActivityLogService();
  DateTime? _from;
  DateTime? _to;
  List<ActivityLog> _logs = [];
  final DateFormat _fmt = DateFormat('dd/MM/yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    final logs = await _logService.getLogs(from: _from, to: _to);
    setState(() => _logs = logs);
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
    if (_logs.isEmpty) return const Center(child: Padding(padding: EdgeInsets.all(24), child: Text('Nenhum registro encontrado.')));
    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: _logs.length,
      separatorBuilder: (_, __) => const Divider(),
      itemBuilder: (ctx, i) {
        final l = _logs[i];
        return ListTile(
          title: Text('${l.action.name.toUpperCase()} — ${l.entityType.name}'),
          subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (l.entityId != null) Text('ID: ${l.entityId}'),
            if (l.actorId != null) Text('Por: ${l.actorId}'),
            if (l.entityCreatedAt != null) Text('Entidade criada em: ${_fmt.format(l.entityCreatedAt!)}'),
            if (l.createdAt != null) Text('Registro: ${_fmt.format(l.createdAt!)}'),
          ]),
        );
      },
    );
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