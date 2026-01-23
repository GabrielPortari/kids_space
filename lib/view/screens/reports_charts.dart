import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'package:get_it/get_it.dart';

import '../../controller/attendance_controller.dart';
import '../../controller/child_controller.dart';
import '../../controller/user_controller.dart';
import '../../controller/collaborator_controller.dart';
import '../../controller/company_controller.dart';
import '../../model/attendance.dart';

class ReportsCharts extends StatefulWidget {
  final String selectedType;
  final bool useCards;
  final DateTime? from;
  final DateTime? to;

  const ReportsCharts({Key? key, this.selectedType = 'Todos', this.useCards = true, this.from, this.to}) : super(key: key);

  @override
  State<ReportsCharts> createState() => _ReportsChartsState();
}

class _ReportsChartsState extends State<ReportsCharts> {
  final AttendanceController _attendanceController = GetIt.I<AttendanceController>();
  final ChildController _childController = GetIt.I<ChildController>();
  final UserController _userController = GetIt.I<UserController>();
  final CollaboratorController _collabController = GetIt.I<CollaboratorController>();

  List<Attendance> _events = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void didUpdateWidget(covariant ReportsCharts oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedType != widget.selectedType || oldWidget.from != widget.from || oldWidget.to != widget.to) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
      // determine effective date range based on selected type
      DateTime? effFrom = widget.from;
      DateTime? effTo = widget.to;
      if (widget.selectedType == 'Check-ins (7d)') {
        effTo = DateTime.now();
        effFrom = effTo.subtract(const Duration(days: 7));
      }

      final companyId = GetIt.I<CompanyController>().companySelected?.id;
      if (companyId != null && companyId.isNotEmpty) {
        final list = await _attendanceController.getAttendancesBetween(companyId, from: effFrom, to: effTo);
        setState(() => _events = list);
      } else {
        final all = _attendanceController.events ?? [];
        setState(() => _events = _filterByRange(all, effFrom, effTo));
      }

      // ensure controllers have cached data for name resolution (fire-and-forget)
      final childIds = _events.map((e) => e.childId).whereType<String>().toSet();
      final userIds = _events.map((e) => e.responsibleId).whereType<String>().toSet();
      final collabIds = <String>{}
        ..addAll(_events.map((e) => e.collaboratorCheckedInId).whereType<String>())
        ..addAll(_events.map((e) => e.collaboratorCheckedOutId).whereType<String>());

      // fetch children and users (they update their caches internally)
      final childFs = childIds.map((id) => _childController.fetchChildById(id)).toList();
      final userFs = userIds.map((id) => _userController.fetchUserById(id)).toList();
      // fetch collaborators and insert into collaborators list if fetched
      final collabFs = collabIds.map((id) => _collabController.getCollaboratorById(id)).toList();
      await Future.wait([...childFs, ...userFs]);
      final collabs = await Future.wait(collabFs);
      for (final c in collabs) {
        if (c == null) continue;
        final exists = _collabController.collaborators.any((x) => x.id == c.id);
        if (!exists) _collabController.collaborators.add(c);
      }
  }
  List<Attendance> _filterByRange(List<Attendance> all, DateTime? from, DateTime? to) {
    if (from == null && to == null) return all;
    final start = from ?? DateTime(1970);
    final end = to ?? DateTime.now();
    return all.where((a) {
      final c = a.createdAt ?? a.checkinTime ?? DateTime(1970);
      return !c.isBefore(start) && !c.isAfter(end);
    }).toList();
  }

  Duration? _durationFor(Attendance a) {
    final inT = a.checkinTime;
    final outT = a.checkoutTime;
    if (inT == null) return null;
    if (outT == null) return DateTime.now().difference(inT);
    return outT.difference(inT);
  }

  @override
  Widget build(BuildContext context) {
    if (_attendanceController.isLoadingEvents) return const Center(child: CircularProgressIndicator());

    final events = _events;

    // 1. List attendances textual
    final attendanceTiles = events.map((a) {
      final childName = _childController.getChildById(a.childId)?.name ?? a.childId ?? '-';
      final responsibleName = a.responsibleId != null ? (_userController.getUserById(a.responsibleId!)?.name ?? a.responsibleId) : '-';
      final checkedInBy = _collabName(a.collaboratorCheckedInId) ?? a.collaboratorCheckedInId ?? '-';
      final checkedOutBy = _collabName(a.collaboratorCheckedOutId) ?? a.collaboratorCheckedOutId ?? '-';
      final dur = _durationFor(a);
      final durStr = dur == null ? '-' : _formatDuration(dur);
      return ListTile(
        title: Text(childName),
        subtitle: Text('Check-in: ${_fmt(a.checkinTime)}  •  Check-out: ${_fmt(a.checkoutTime)}\nResponsável: $responsibleName  •  In: $checkedInBy  Out: $checkedOutBy  •  Permanência: $durStr'),
      );
    }).toList();

    // 2. Compute min/max/avg durations per event
    final durations = events.map(_durationFor).whereType<Duration>().toList();
    Duration? minD, maxD, avgD;
    if (durations.isNotEmpty) {
      durations.sort((a, b) => a.compareTo(b));
      minD = durations.first;
      maxD = durations.last;
      final total = durations.fold<int>(0, (s, d) => s + d.inSeconds);
      avgD = Duration(seconds: (total / durations.length).round());
    }

    // 3. Collaborator stats
    final Map<String, int> collabCheckins = {};
    final Map<String, int> collabCheckouts = {};
    for (final a in events) {
      final inId = a.collaboratorCheckedInId;
      final outId = a.collaboratorCheckedOutId;
      if (inId != null) collabCheckins[inId] = (collabCheckins[inId] ?? 0) + 1;
      if (outId != null) collabCheckouts[outId] = (collabCheckouts[outId] ?? 0) + 1;
    }

    // 4. Child stats
    final Map<String, int> childCounts = {};
    for (final a in events) {
      final cid = a.childId;
      if (cid != null) childCounts[cid] = (childCounts[cid] ?? 0) + 1;
    }

    // 5. Checkins by hour
    final Map<int, int> hourly = Map.fromIterable(List.generate(24, (i) => i), key: (i) => i as int, value: (_) => 0);
    for (final a in events) {
      final h = a.checkinTime?.hour;
      if (h != null) hourly[h] = (hourly[h] ?? 0) + 1;
    }

    // choose UI based on selected report type
    final List<Widget> contentWidgets = [];
    if (widget.selectedType == 'Check-ins (7d)' || widget.selectedType == 'Check-ins por período') {
      contentWidgets.addAll([
        const SizedBox(height: 8),
        const Text('Atendimentos (lista)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...attendanceTiles,
      ]);
    } else if (widget.selectedType == 'Distribuição por colaborador') {
      contentWidgets.addAll([
        const SizedBox(height: 8),
        const Text('Colaboradores (checkins / checkouts)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...collabCheckins.entries.map((e) => ListTile(title: Text(_collabName(e.key) ?? e.key), subtitle: Text('Checkins: ${e.value}  •  Checkouts: ${collabCheckouts[e.key] ?? 0}'))),
      ]);
    } else if (widget.selectedType == 'Check-ins por hora') {
      contentWidgets.addAll([
        const SizedBox(height: 8),
        const Text('Checkins por horário', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        SizedBox(height: 200, child: _HourlyLineChart(hourlyCounts: hourly)),
      ]);
    } else if (widget.selectedType == 'Resumo geral') {
      final total = events.length;
      final uniqueChildren = childCounts.length;
      contentWidgets.addAll([
        const SizedBox(height: 8),
        const Text('Resumo geral', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Total de atendimentos: $total  •  Crianças únicas: $uniqueChildren'),
        const SizedBox(height: 12),
        const Text('Tempo de permanência (min / max / média)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Mínimo: ${minD == null ? '-' : _formatDuration(minD)}  •  Máximo: ${maxD == null ? '-' : _formatDuration(maxD)}  •  Média: ${avgD == null ? '-' : _formatDuration(avgD)}'),
        const SizedBox(height: 12),
        SizedBox(height: 180, child: _DurationLineChart(durationsByDate: _aggregateDurationsByDate(events, widget.from, widget.to))),
      ]);
    } else if (widget.selectedType == 'Colaboradores ativos') {
      contentWidgets.addAll([
        const SizedBox(height: 8),
        const Text('Colaboradores ativos (com atividade)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...collabCheckins.entries.where((e) => e.value > 0).map((e) => ListTile(title: Text(_collabName(e.key) ?? e.key), subtitle: Text('Checkins: ${e.value}  •  Checkouts: ${collabCheckouts[e.key] ?? 0}'))),
      ]);
    } else {
      // fallback: show summary
      contentWidgets.addAll([
        const SizedBox(height: 8),
        const Text('Resumo', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text('Total de atendimentos: ${events.length}'),
      ]);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: contentWidgets);
  }

  String _fmt(DateTime? d) => d == null ? '-' : DateFormat('dd/MM HH:mm').format(d);

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes % 60;
    return '${h}h ${m}m';
  }

  String? _collabName(String? id) {
    if (id == null) return null;
    try {
      final col = _collabController.collaborators.firstWhere((c) => c.id == id);
      return col.name;
    } catch (_) {
      return id;
    }
  }

  Map<DateTime, double> _aggregateDurationsByDate(List<Attendance> events, DateTime? from, DateTime? to) {
    final Map<String, List<Duration>> byDate = {};
    final start = from ?? DateTime.now().subtract(const Duration(days: 6));
    final end = to ?? DateTime.now();
    for (final a in events) {
      final c = a.createdAt ?? a.checkinTime;
      if (c == null) continue;
      if (c.isBefore(start) || c.isAfter(end)) continue;
      final key = DateFormat('yyyy-MM-dd').format(DateTime(c.year, c.month, c.day));
      final dur = _durationFor(a);
      if (dur != null) {
        byDate.putIfAbsent(key, () => []).add(dur);
      }
    }
    final Map<DateTime, double> avgByDate = {};
    byDate.forEach((k, list) {
      final total = list.fold<int>(0, (s, d) => s + d.inSeconds);
      final avgSec = total ~/ list.length;
      final dt = DateTime.parse(k);
      avgByDate[dt] = avgSec.toDouble();
    });
    return avgByDate;
  }
}

class _DurationLineChart extends StatelessWidget {
  final Map<DateTime, double> durationsByDate;
  const _DurationLineChart({Key? key, required this.durationsByDate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (durationsByDate.isEmpty) return const Center(child: Text('Sem dados'));
    final sorted = durationsByDate.keys.toList()..sort();
    final spots = <FlSpot>[];
    for (var i = 0; i < sorted.length; i++) {
      spots.add(FlSpot(i.toDouble(), durationsByDate[sorted[i]]! / 60.0)); // minutes
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: LineChart(LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
            final idx = value.toInt();
            if (idx < 0 || idx >= sorted.length) return const SizedBox.shrink();
            return Text(DateFormat('dd/MM').format(sorted[idx]), style: const TextStyle(fontSize: 10));
          }, reservedSize: 36)),
        ),
        lineBarsData: [LineChartBarData(spots: spots, isCurved: true, barWidth: 3, color: Theme.of(context).colorScheme.primary)],
      )),
    );
  }
}

class _HourlyLineChart extends StatelessWidget {
  final Map<int, int> hourlyCounts;
  const _HourlyLineChart({Key? key, required this.hourlyCounts}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final keys = hourlyCounts.keys.toList()..sort();
    final spots = keys.map((k) => FlSpot(k.toDouble(), (hourlyCounts[k] ?? 0).toDouble())).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: LineChart(LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true)),
          bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (value, meta) {
            final idx = value.toInt();
            if (!keys.contains(idx)) return const SizedBox.shrink();
            return Text('${idx}h', style: const TextStyle(fontSize: 10));
          }, reservedSize: 36)),
        ),
        lineBarsData: [LineChartBarData(spots: spots, isCurved: true, barWidth: 3, color: Theme.of(context).colorScheme.primary)],
      )),
    );
  }
}