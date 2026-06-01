import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/attendance_controller.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/parent_controller.dart';
import 'package:kids_space/model/attendance.dart';
import 'package:kids_space/util/date_hour_util.dart';
import 'package:kids_space/util/localization_service.dart';
import 'package:kids_space/view/screens/childrens_screen.dart';
import 'package:kids_space/view/screens/company_attendances_screen.dart';
import 'package:kids_space/view/widgets/attendance_modal.dart';
import 'package:kids_space/view/widgets/skeleton_list.dart';
import 'package:skeletonizer/skeletonizer.dart';

class CompanyDashboardScreen extends StatefulWidget {
  const CompanyDashboardScreen({super.key});

  @override
  State<CompanyDashboardScreen> createState() => _CompanyDashboardScreenState();
}

class _CompanyDashboardScreenState extends State<CompanyDashboardScreen> {
  late final ScrollController _scrollController;
  late final ScrollController _logListController;

  final _companyController = GetIt.I.get<CompanyController>();
  final _authController = GetIt.I.get<AuthController>();
  final _collaboratorController = GetIt.I.get<CollaboratorController>();
  final _attendanceController = GetIt.I.get<AttendanceController>();
  final _childController = GetIt.I.get<ChildController>();
  final _parentController = GetIt.I.get<ParentController>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _logListController = ScrollController();
    _onRefresh();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _logListController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    if (_companyController.company == null) {
      if (_collaboratorController.loggedCollaborator == null) {
        try { await _authController.checkLoggedUser(); } catch (_) {}
      }
      final collId = _collaboratorController.loggedCollaborator?.companyId;
      if (collId != null && collId.isNotEmpty) {
        try { await _companyController.loadCompanyNameById(collId); } catch (_) {}
      }
    }
    final companyId = _companyController.company?.id;
    try {
      await Future.wait([
        _childController.refreshChildrenForCompany(companyId),
        _parentController.refreshUsersForCompany(companyId),
        _collaboratorController.refreshCollaboratorsForCompany(companyId),
        if (companyId != null) ...[
          _attendanceController.loadActiveCheckinsForCompany(companyId),
          _attendanceController.loadLast10AttendancesForCompany(companyId),
          _attendanceController.loadLastCheckinAndCheckoutForCompany(companyId),
        ],
      ]);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  void _openAttendances() {
    final companyId = _companyController.company?.id;
    if (companyId == null || companyId.isEmpty) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CompanyAttendancesScreen(
          companyId: companyId,
          companyName: _companyController.company?.name,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final listHeight = ((MediaQuery.sizeOf(context).height -
                MediaQuery.paddingOf(context).top -
                kToolbarHeight) *
            0.36)
        .clamp(180.0, 520.0);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _companyController,
        _childController,
        _parentController,
        _attendanceController,
        _collaboratorController,
      ]),
      builder: (_, __) {
        final loading =
            _companyController.isLoading ||
            _childController.refreshLoading ||
            _parentController.refreshLoading ||
            _collaboratorController.refreshLoading ||
            _attendanceController.isLoadingActiveCheckins ||
            _attendanceController.isLoadingLogs ||
            _attendanceController.isLoadingLastCheck;

        return Scaffold(
          backgroundColor: const Color(0xFFF7F9FC),
          appBar: AppBar(
            title: Text(translate('home.company')),
            leading: const BackButton(),
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ── Totais ────────────────────────────────────────────
                      _TotalsCard(
                        childCount: _childController.children.length,
                        parentCount: _parentController.parents.length,
                        collaboratorCount:
                            _collaboratorController.collaborators.length,
                        loading: loading,
                      ),
                      const SizedBox(height: 12),

                      // ── Botões ────────────────────────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: _DashboardActionButton(
                              label: translate('home.check_in'),
                              icon: Icons.login_rounded,
                              color: const Color(0xFF388E3C),
                              bgColor: const Color(0xFFE8F5E9),
                              enabled: !loading,
                              onTap: () => showAttendanceModal(
                                context,
                                AttendanceType.checkin,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _DashboardActionButton(
                              label: translate('home.check_out'),
                              icon: Icons.logout_rounded,
                              color: const Color(0xFFE65100),
                              bgColor: const Color(0xFFFFF3E0),
                              enabled: !loading,
                              onTap: () => showAttendanceModal(
                                context,
                                AttendanceType.checkout,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // ── Ativos ────────────────────────────────────────────
                      _ActiveSummaryCard(
                        attendanceController: _attendanceController,
                        childController: _childController,
                        loading: loading,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const ChildrensScreen(onlyActive: true),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // ── Log ───────────────────────────────────────────────
                      _LogCard(
                        height: listHeight,
                        loading: loading,
                        events: _attendanceController.logEvents,
                        childController: _childController,
                        logCtrl: _logListController,
                        onSeeMore: _openAttendances,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

// ── Widgets internos ──────────────────────────────────────────────────────────

class _TotalsCard extends StatelessWidget {
  final int childCount;
  final int parentCount;
  final int collaboratorCount;
  final bool loading;

  const _TotalsCard({
    required this.childCount,
    required this.parentCount,
    required this.collaboratorCount,
    required this.loading,
  });

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: loading,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEF1F7)),
        ),
        child: Row(
          children: [
            Expanded(
              child: _StatItem(
                icon: Icons.child_care_rounded,
                color: const Color(0xFFAD1457),
                bg: const Color(0xFFFCE4EC),
                label: 'Crianças',
                value: childCount,
              ),
            ),
            const _VertDivider(),
            Expanded(
              child: _StatItem(
                icon: Icons.people_rounded,
                color: const Color(0xFFE65100),
                bg: const Color(0xFFFFF3E0),
                label: 'Responsáveis',
                value: parentCount,
              ),
            ),
            const _VertDivider(),
            Expanded(
              child: _StatItem(
                icon: Icons.badge_rounded,
                color: const Color(0xFF00838F),
                bg: const Color(0xFFE0F7FA),
                label: 'Colaboradores',
                value: collaboratorCount,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  const _VertDivider();

  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 48,
    color: const Color(0xFFEEF1F7),
    margin: const EdgeInsets.symmetric(horizontal: 8),
  );
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final Color bg;
  final String label;
  final int value;

  const _StatItem({
    required this.icon,
    required this.color,
    required this.bg,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, size: 20, color: color),
      ),
      const SizedBox(height: 6),
      Text(
        '$value',
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: Color(0xFF0F1218),
        ),
      ),
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: Color(0xFF9AA3B5)),
      ),
    ],
  );
}

class _DashboardActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final bool enabled;
  final VoidCallback onTap;

  const _DashboardActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: enabled ? bgColor : const Color(0xFFF7F9FC),
    borderRadius: BorderRadius.circular(12),
    child: InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: enabled ? color.withValues(alpha: 0.3) : const Color(0xFFEEF1F7),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: enabled ? color : const Color(0xFFC4CADA)),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: enabled ? color : const Color(0xFFC4CADA),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _ActiveSummaryCard extends StatelessWidget {
  final AttendanceController attendanceController;
  final ChildController childController;
  final bool loading;
  final VoidCallback onTap;

  const _ActiveSummaryCard({
    required this.attendanceController,
    required this.childController,
    required this.loading,
    required this.onTap,
  });

  String _name(Map<String, dynamic>? snapshot, String? id) {
    if (snapshot?['name'] is String) return snapshot!['name'] as String;
    return childController.getChildById(id)?.name ?? '—';
  }

  @override
  Widget build(BuildContext context) {
    final lastIn = attendanceController.lastCheckIn;
    final lastOut = attendanceController.lastCheckOut;

    return Skeletonizer(
      enabled: loading,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFEEF1F7)),
        ),
        child: Column(
          children: [
            InkWell(
              onTap: onTap,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F0FE),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.child_care_rounded,
                        color: Color(0xFF2962FF), size: 22),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        translate('home.actives'),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A3EB3),
                        ),
                      ),
                    ),
                    Text(
                      '${attendanceController.activeCheckins.length}',
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2962FF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right_rounded,
                        color: Color(0xFF2962FF), size: 20),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _EventRow(
                    icon: Icons.login_rounded,
                    color: const Color(0xFF388E3C),
                    label: translate('home.last_check_in'),
                    name: _name(lastIn?.childSnapshot, lastIn?.childId),
                    time: formatDate_ddMM_HHmm(lastIn?.checkInTime),
                    empty: translate('home.no_checkins_registered'),
                  ),
                  const Divider(height: 20, color: Color(0xFFEEF1F7)),
                  _EventRow(
                    icon: Icons.logout_rounded,
                    color: const Color(0xFFE65100),
                    label: translate('home.last_check_out'),
                    name: _name(lastOut?.childSnapshot, lastOut?.childId),
                    time: formatDate_ddMM_HHmm(lastOut?.checkOutTime),
                    empty: translate('home.no_checkouts_registered'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EventRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String name;
  final String time;
  final String empty;

  const _EventRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.name,
    required this.time,
    required this.empty,
  });

  @override
  Widget build(BuildContext context) {
    final hasData = name.isNotEmpty && name != '—';
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: const TextStyle(fontSize: 11, color: Color(0xFF9AA3B5))),
              Text(
                hasData ? name : empty,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: hasData ? const Color(0xFF0F1218) : const Color(0xFFC4CADA),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (hasData)
          Text(time,
              style: const TextStyle(fontSize: 12, color: Color(0xFF9AA3B5))),
      ],
    );
  }
}

class _LogCard extends StatelessWidget {
  final double height;
  final bool loading;
  final List events;
  final ChildController childController;
  final ScrollController logCtrl;
  final VoidCallback onSeeMore;

  const _LogCard({
    required this.height,
    required this.loading,
    required this.events,
    required this.childController,
    required this.logCtrl,
    required this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: const Color(0xFFEEF1F7)),
    ),
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 0),
          child: Row(
            children: [
              const Icon(Icons.history_rounded, size: 18, color: Color(0xFF9AA3B5)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  translate('home.30_last_presence_log'),
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
              TextButton(
                onPressed: loading ? null : onSeeMore,
                child: Text(translate('home.see_more')),
              ),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFEEF1F7)),
        SizedBox(
          height: height,
          child: loading
              ? const SkeletonList(itemCount: 6)
              : events.isEmpty
              ? Center(
                  child: Text(
                    translate('home.no_presence_records'),
                    style: const TextStyle(color: Color(0xFF9AA3B5)),
                  ),
                )
              : ListView.separated(
                  controller: logCtrl,
                  padding: EdgeInsets.zero,
                  itemCount: events.length,
                  separatorBuilder: (_, __) =>
                      const Divider(height: 1, color: Color(0xFFEEF1F7)),
                  itemBuilder: (_, i) {
                    final e = events[i] as Attendance;
                    final isIn = e.attendanceType == AttendanceType.checkin;
                    final name = e.childSnapshot?['name'] is String
                        ? e.childSnapshot!['name'] as String
                        : childController.getChildById(e.childId)?.name ?? '';
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      leading: CircleAvatar(
                        radius: 20,
                        backgroundColor: isIn
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFF3E0),
                        child: Icon(
                          isIn ? Icons.login_rounded : Icons.logout_rounded,
                          size: 16,
                          color: isIn
                              ? const Color(0xFF388E3C)
                              : const Color(0xFFE65100),
                        ),
                      ),
                      title: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      subtitle: Text(
                        formatDate_ddMM_HHmm(e.checkInTime ?? e.checkOutTime),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9AA3B5),
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: isIn
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF3E0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isIn
                              ? translate('home.check_in')
                              : translate('home.check_out'),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isIn
                                ? const Color(0xFF388E3C)
                                : const Color(0xFFE65100),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    ),
  );
}
