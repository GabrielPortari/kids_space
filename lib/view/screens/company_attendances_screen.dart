import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/attendance_controller.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/parent_controller.dart';
import 'package:kids_space/model/attendance.dart';
import 'package:kids_space/util/date_hour_util.dart';
import 'package:kids_space/util/localization_service.dart';

class CompanyAttendancesScreen extends StatefulWidget {
  const CompanyAttendancesScreen({
    super.key,
    required this.companyId,
    this.companyName,
  });

  final String companyId;
  final String? companyName;

  @override
  State<CompanyAttendancesScreen> createState() =>
      _CompanyAttendancesScreenState();
}

class _CompanyAttendancesScreenState extends State<CompanyAttendancesScreen> {
  final AttendanceController _attendanceController = GetIt.I
      .get<AttendanceController>();
  final ChildController _childController = GetIt.I.get<ChildController>();
  final ParentController _parentController = GetIt.I.get<ParentController>();
  final CollaboratorController _collaboratorController = GetIt.I
      .get<CollaboratorController>();
  final TextEditingController _searchController = TextEditingController();
  final Map<String, String> _childNamesById = {};

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _attendanceController.addListener(_listener);
    _searchController.addListener(_onSearchChanged);
    _load();
  }

  @override
  void dispose() {
    _attendanceController.removeListener(_listener);
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _listener() {
    if (!mounted) return;
    setState(() {});
  }

  void _onSearchChanged() {
    final next = _searchController.text.trim();
    if (next == _searchQuery) return;
    setState(() => _searchQuery = next);
  }

  Future<void> _load() async {
    try {
      await _attendanceController.loadAllAttendancesForCompany(
        widget.companyId,
      );
      await _hydrateChildNames(_attendanceController.companyEvents);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  Future<void> _hydrateChildNames(List<Attendance> events) async {
    final idsToFetch = <String>{};
    for (final e in events) {
      final id = e.childId;
      if (id == null || id.isEmpty) continue;
      // prefer snapshot name when available
      if (e.childSnapshot != null && e.childSnapshot!['name'] is String) {
        _childNamesById[id] = (e.childSnapshot!['name'] as String).trim();
        continue;
      }
      if (_childNamesById[id]?.isNotEmpty == true) continue;
      final cached = _childController.getChildById(id)?.name;
      if (cached != null && cached.trim().isNotEmpty) {
        _childNamesById[id] = cached.trim();
        continue;
      }
      idsToFetch.add(id);
    }

    for (final id in idsToFetch) {
      final fetched = await _childController.getChildNameById(id);
      if (fetched != null && fetched.trim().isNotEmpty) {
        _childNamesById[id] = fetched.trim();
      }
    }

    if (mounted) setState(() {});
  }

  String _resolveChildName(String? childId) {
    if (childId == null || childId.isEmpty) return '-';
    final byMap = _childNamesById[childId];
    if (byMap != null && byMap.trim().isNotEmpty) return byMap;
    final cached = _childController.getChildById(childId)?.name;
    if (cached != null && cached.trim().isNotEmpty) return cached.trim();
    return '-';
  }

  List<Attendance> _filteredEvents(List<Attendance> events) {
    final query = _searchQuery.trim();
    if (query.isEmpty) return events;

    final queryLower = query.toLowerCase();
    return events.where((event) {
      final matchesId = (event.id ?? '') == query;
      final matchesChildId = (event.childId ?? '') == query;
      final childName = _resolveChildName(event.childId).toLowerCase();
      final matchesChildName = childName.contains(queryLower);
      return matchesId || matchesChildId || matchesChildName;
    }).toList();
  }

  String _labelForType(AttendanceType? type) {
    if (type == AttendanceType.checkin) return translate('home.check_in');
    if (type == AttendanceType.checkout) return translate('home.check_out');
    return '-';
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) return '-';
    return formatDate_ddMM_HHmm(value);
  }

  Future<void> _showAttendanceDetails(
    Attendance event,
    String childName,
  ) async {
    final names = await Future.wait<String?>([
      event.childId != null && childName == '-'
          ? _childController.getChildNameById(event.childId!)
          : Future.value(childName),
      event.parentIdWhoCheckedInId != null
          ? (event.responsibleCheckedInSnapshot != null &&
                    event.responsibleCheckedInSnapshot!['name'] is String
                ? Future.value(
                    event.responsibleCheckedInSnapshot!['name'] as String,
                  )
                : _parentController.getParentNameById(
                    event.parentIdWhoCheckedInId!,
                  ))
          : Future.value(null),
      event.parentIdWhoCheckedOutId != null
          ? (event.responsibleCheckedOutSnapshot != null &&
                    event.responsibleCheckedOutSnapshot!['name'] is String
                ? Future.value(
                    event.responsibleCheckedOutSnapshot!['name'] as String,
                  )
                : _parentController.getParentNameById(
                    event.parentIdWhoCheckedOutId!,
                  ))
          : Future.value(null),
      event.collaboratorWhoCheckedInId != null
          ? (event.collaboratorCheckedInSnapshot != null &&
                    event.collaboratorCheckedInSnapshot!['name'] is String
                ? Future.value(
                    event.collaboratorCheckedInSnapshot!['name'] as String,
                  )
                : _collaboratorController.getCollaboratorNameById(
                    event.collaboratorWhoCheckedInId!,
                  ))
          : Future.value(null),
      event.collaboratorWhoCheckedOutId != null
          ? (event.collaboratorCheckedOutSnapshot != null &&
                    event.collaboratorCheckedOutSnapshot!['name'] is String
                ? Future.value(
                    event.collaboratorCheckedOutSnapshot!['name'] as String,
                  )
                : _collaboratorController.getCollaboratorNameById(
                    event.collaboratorWhoCheckedOutId!,
                  ))
          : Future.value(null),
    ]);

    final resolvedChildName = (names[0]?.trim().isNotEmpty == true)
        ? names[0]!.trim()
        : '-';
    final responsibleCheckInName = (names[1]?.trim().isNotEmpty == true)
        ? names[1]!.trim()
        : '-';
    final responsibleCheckOutName = (names[2]?.trim().isNotEmpty == true)
        ? names[2]!.trim()
        : '-';
    final collaboratorCheckInName = (names[3]?.trim().isNotEmpty == true)
        ? names[3]!.trim()
        : '-';
    final collaboratorCheckOutName = (names[4]?.trim().isNotEmpty == true)
        ? names[4]!.trim()
        : '-';

    final details = <MapEntry<String, String>>[
      MapEntry('ID', event.id ?? '-'),
      MapEntry('Tipo', _labelForType(event.attendanceType)),
      MapEntry('Criado em', _formatDateTime(event.createdAt)),
      MapEntry('Atualizado em', _formatDateTime(event.updatedAt)),
      MapEntry('Company ID', event.companyId ?? '-'),
      MapEntry('Child ID', event.childId ?? '-'),
      MapEntry('Nome da criança', resolvedChildName),
      MapEntry('Responsible check-in ID', event.parentIdWhoCheckedInId ?? '-'),
      MapEntry('Responsible check-in nome', responsibleCheckInName),
      MapEntry(
        'Responsible check-out ID',
        event.parentIdWhoCheckedOutId ?? '-',
      ),
      MapEntry('Responsible check-out nome', responsibleCheckOutName),
      MapEntry(
        'Collaborator check-in ID',
        event.collaboratorWhoCheckedInId ?? '-',
      ),
      MapEntry('Collaborator check-in nome', collaboratorCheckInName),
      MapEntry(
        'Collaborator check-out ID',
        event.collaboratorWhoCheckedOutId ?? '-',
      ),
      MapEntry('Collaborator check-out nome', collaboratorCheckOutName),
      MapEntry('Check-in', _formatDateTime(event.checkInTime)),
      MapEntry('Check-out', _formatDateTime(event.checkOutTime)),
      MapEntry(
        'Tempo em segundos',
        event.timeCheckedInSeconds?.toString() ?? '-',
      ),
      MapEntry(
        'Observacoes',
        event.notes?.trim().isNotEmpty == true ? event.notes!.trim() : '-',
      ),
    ];

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Detalhes do attendance'),
        content: SizedBox(
          width: 560,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: details
                  .map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text('${d.key}: ${d.value}'),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(translate('buttons.ok')),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = _attendanceController.companyEvents;
    final filteredEvents = _filteredEvents(events);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.companyName?.trim().isNotEmpty == true
              ? 'Attendances - ${widget.companyName}'
              : 'Attendances da company',
        ),
      ),
      body: _attendanceController.isLoadingCompanyEvents
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Buscar por nome da crianca ou ID completo',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => _searchController.clear(),
                            ),
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: events.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.5,
                                child: Center(
                                  child: Text(
                                    translate('home.no_presence_records'),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : filteredEvents.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.45,
                                child: const Center(
                                  child: Text('Nenhum attendance encontrado.'),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.only(
                              top: 8.0,
                              left: 8.0,
                              right: 8.0,
                            ),
                            itemCount: filteredEvents.length,
                            itemBuilder: (_, index) {
                              final event = filteredEvents[index];
                              final isCheckin =
                                  event.attendanceType ==
                                  AttendanceType.checkin;
                              final childName = _resolveChildName(
                                event.childId,
                              );
                              final when = formatDate_ddMM_HHmm(
                                event.checkInTime ?? event.checkOutTime,
                              );
                              final typeLabel = isCheckin
                                  ? translate('home.check_in')
                                  : translate('home.check_out');

                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12.0,
                                  vertical: 6.0,
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16.0,
                                    vertical: 8.0,
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: isCheckin
                                        ? Colors.green.withValues(alpha: 0.14)
                                        : Colors.red.withValues(alpha: 0.14),
                                    child: Icon(
                                      isCheckin ? Icons.login : Icons.logout,
                                      color: isCheckin
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                  title: Text(childName),
                                  subtitle: Text('$typeLabel · $when'),
                                  onTap: () =>
                                      _showAttendanceDetails(event, childName),
                                ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            ),
    );
  }
}
