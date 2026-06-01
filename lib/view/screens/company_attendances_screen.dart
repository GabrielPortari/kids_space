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

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    if (hours > 0) return '${hours}h ${minutes}min';
    return '${minutes}min';
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

    final isIn = event.attendanceType == AttendanceType.checkin;

    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        final textTheme = Theme.of(dialogContext).textTheme;
        return Dialog(
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 24,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  color: isIn
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFFFF3E0),
                  padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                  child: Row(
                    children: [
                      Icon(
                        isIn ? Icons.login_rounded : Icons.logout_rounded,
                        color: isIn
                            ? const Color(0xFF388E3C)
                            : const Color(0xFFE65100),
                        size: 22,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Detalhes da presença',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: isIn
                                ? const Color(0xFF1B5E20)
                                : const Color(0xFFBF360C),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded),
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        color: const Color(0xFF495267),
                        tooltip: translate('buttons.cancel'),
                      ),
                    ],
                  ),
                ),

                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _AttendanceDetailRow(
                          icon: Icons.child_care_rounded,
                          label: translate('attendance.child_label'),
                          value: resolvedChildName,
                        ),
                        _AttendanceDetailRow(
                          icon: isIn
                              ? Icons.login_rounded
                              : Icons.logout_rounded,
                          label: translate('attendance.type_label'),
                          value: _labelForType(event.attendanceType),
                          valueColor: isIn
                              ? const Color(0xFF388E3C)
                              : const Color(0xFFE65100),
                        ),

                        if (event.checkInTime != null) ...[
                          const SizedBox(height: 16),
                          const _AttendanceDetailSection(label: 'Check-in'),
                          _AttendanceDetailRow(
                            icon: Icons.access_time_rounded,
                            label: 'Horário',
                            value: _formatDateTime(event.checkInTime),
                          ),
                          _AttendanceDetailRow(
                            icon: Icons.person_rounded,
                            label: translate('attendance.responsible_label'),
                            value: responsibleCheckInName,
                          ),
                          if (collaboratorCheckInName != '-')
                            _AttendanceDetailRow(
                              icon: Icons.badge_rounded,
                              label: translate('attendance.collaborator_label'),
                              value: collaboratorCheckInName,
                            ),
                        ],

                        if (event.checkOutTime != null) ...[
                          const SizedBox(height: 16),
                          const _AttendanceDetailSection(label: 'Check-out'),
                          _AttendanceDetailRow(
                            icon: Icons.access_time_rounded,
                            label: 'Horário',
                            value: _formatDateTime(event.checkOutTime),
                          ),
                          _AttendanceDetailRow(
                            icon: Icons.person_rounded,
                            label: translate('attendance.responsible_label'),
                            value: responsibleCheckOutName,
                          ),
                          if (collaboratorCheckOutName != '-')
                            _AttendanceDetailRow(
                              icon: Icons.badge_rounded,
                              label: translate('attendance.collaborator_label'),
                              value: collaboratorCheckOutName,
                            ),
                        ],

                        if (event.timeCheckedInSeconds != null) ...[
                          const SizedBox(height: 8),
                          _AttendanceDetailRow(
                            icon: Icons.timer_rounded,
                            label: 'Tempo total',
                            value: _formatDuration(
                              event.timeCheckedInSeconds!,
                            ),
                          ),
                        ],

                        if (event.notes?.trim().isNotEmpty == true) ...[
                          const SizedBox(height: 16),
                          const _AttendanceDetailSection(
                            label: 'Observações',
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7F9FC),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFEEF1F7),
                              ),
                            ),
                            child: Text(
                              event.notes!.trim(),
                              style: textTheme.bodyMedium,
                            ),
                          ),
                        ],

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Footer
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(color: Color(0xFFEEF1F7)),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      child: Text(translate('buttons.ok')),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final events = _attendanceController.companyEvents;
    final filteredEvents = _filteredEvents(events);

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        title: Text(
          widget.companyName?.trim().isNotEmpty == true
              ? '${translate('reports.title')} — ${widget.companyName}'
              : translate('reports.title'),
        ),
        leading: const BackButton(),
      ),
      body: _attendanceController.isLoadingCompanyEvents
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search field
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Buscar por nome da criança ou ID',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchQuery.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.close_rounded, size: 18),
                              onPressed: () => _searchController.clear(),
                            ),
                    ),
                  ),
                ),

                // Count chip
                if (filteredEvents.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '${filteredEvents.length} registro${filteredEvents.length == 1 ? '' : 's'}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9AA3B5),
                        ),
                      ),
                    ),
                  ),

                // List
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: _load,
                    child: events.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(
                                height: MediaQuery.sizeOf(context).height * 0.5,
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.inbox_rounded,
                                          size: 56, color: Color(0xFFC4CADA)),
                                      const SizedBox(height: 12),
                                      Text(
                                        translate('home.no_presence_records'),
                                        style: const TextStyle(
                                          color: Color(0xFF9AA3B5),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          )
                        : filteredEvents.isEmpty
                        ? ListView(
                            children: [
                              SizedBox(
                                height: MediaQuery.sizeOf(context).height * 0.45,
                                child: const Center(
                                  child: Text(
                                    'Nenhum registro encontrado.',
                                    style: TextStyle(color: Color(0xFF9AA3B5)),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                            itemCount: filteredEvents.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (_, i) {
                              final event = filteredEvents[i];
                              final isIn =
                                  event.attendanceType == AttendanceType.checkin;
                              final childName =
                                  _resolveChildName(event.childId);
                              final when = formatDate_ddMM_HHmm(
                                event.checkInTime ?? event.checkOutTime,
                              );
                              final typeLabel = isIn
                                  ? translate('home.check_in')
                                  : translate('home.check_out');

                              return Material(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                child: InkWell(
                                  onTap: () =>
                                      _showAttendanceDetails(event, childName),
                                  borderRadius: BorderRadius.circular(12),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: const Color(0xFFEEF1F7),
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: isIn
                                              ? const Color(0xFFE8F5E9)
                                              : const Color(0xFFFFF3E0),
                                          child: Icon(
                                            isIn
                                                ? Icons.login_rounded
                                                : Icons.logout_rounded,
                                            size: 18,
                                            color: isIn
                                                ? const Color(0xFF388E3C)
                                                : const Color(0xFFE65100),
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                childName,
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  fontWeight: FontWeight.w600,
                                                  color: Color(0xFF0F1218),
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Text(
                                                when,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF9AA3B5),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: isIn
                                                ? const Color(0xFFE8F5E9)
                                                : const Color(0xFFFFF3E0),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: Text(
                                            typeLabel,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: isIn
                                                  ? const Color(0xFF388E3C)
                                                  : const Color(0xFFE65100),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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

class _AttendanceDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _AttendanceDetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9AA3B5)),
          const SizedBox(width: 10),
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: const TextStyle(fontSize: 13, color: Color(0xFF9AA3B5)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: valueColor ?? const Color(0xFF0F1218),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceDetailSection extends StatelessWidget {
  final String label;

  const _AttendanceDetailSection({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
          color: const Color(0xFF495267),
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
