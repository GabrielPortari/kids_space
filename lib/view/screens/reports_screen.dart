import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'reports_charts.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  DateTime? _from;
  DateTime? _to;
  final List<String> _reportTypes = [
    'Check-ins (7d)',
    'Check-ins por período',
    'Distribuição por colaborador',
    'Check-ins por hora',
    'Resumo geral',
    'Colaboradores ativos',
  ];
  String _selectedReportType = '';

  

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _to = DateTime(now.year, now.month, now.day, 23, 59, 59);
    _from = _to!.subtract(const Duration(days: 30));
    _selectedReportType = _reportTypes.first;
    _refresh();
  }

  Future<void> _refresh() async {
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Início:'),
                  TextButton(onPressed: _pickFrom, child: Text(_from == null ? 'Data inicial' : DateFormat('dd/MM/yyyy').format(_from!))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Fim:'),
                  TextButton(onPressed: _pickTo, child: Text(_to == null ? 'Data final' : DateFormat('dd/MM/yyyy').format(_to!))),
                ],
              ),
            ),
          ]),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Relatórios')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              _buildFilters(),
              const SizedBox(height: 12),
              // Report type selector
              Row(
                children: [
                  const Text('Tipo: '),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButton<String>(
                      value: _selectedReportType,
                      isExpanded: true,
                      items: _reportTypes.map((t) => DropdownMenuItem(
                        alignment: Alignment.centerLeft,
                        value: t, 
                        child: Text(t))).toList(),
                      onChanged: (v) => setState(() => _selectedReportType = v ?? _selectedReportType),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Charts: pass selected date range; ReportsCharts sizes itself for scrollable container
              ReportsCharts(selectedType: _selectedReportType, useCards: false, from: _from, to: _to),
            ],
          ),
        ),
      ),
    );
  }
}