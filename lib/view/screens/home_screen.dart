import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/attendance_controller.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/model/attendance.dart';
import 'package:kids_space/util/date_hour_util.dart';
import 'package:kids_space/util/localization_service.dart';
import 'package:kids_space/view/screens/company_attendances_screen.dart';
import 'package:kids_space/view/screens/profile_screen.dart';
import 'package:kids_space/view/screens/childrens_screen.dart';
import 'package:kids_space/view/widgets/attendance_modal.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:kids_space/view/widgets/skeleton_list.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ScrollController _scrollController;
  late final ScrollController _logListController;
  final _companyController = GetIt.I.get<CompanyController>();
  final _authController = GetIt.I.get<AuthController>();
  final _collaboratorController = GetIt.I.get<CollaboratorController>();
  final _attendanceController = GetIt.I.get<AttendanceController>();
  final _childController = GetIt.I.get<ChildController>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _logListController = ScrollController();
    _onRefresh();
  }

  @override
  void dispose() {
    _attendanceController.removeListener(_attendanceListener);
    _scrollController.dispose();
    _logListController.dispose();
    super.dispose();
  }

  void _attendanceListener() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _onRefresh() async {
    if (_companyController.company == null) {
      if (_collaboratorController.loggedCollaborator == null) {
        try {
          await _authController.checkLoggedUser();
        } catch (_) {}
      }
      final collId = _collaboratorController.loggedCollaborator?.companyId;
      if (collId != null && collId.isNotEmpty) {
        try {
          await _companyController.loadCompanyNameById(collId);
        } catch (_) {}
      }
    }
    final String? companyId = _companyController.company?.id;
    final futures = <Future>[
      _childController.refreshChildrenForCompany(companyId),
    ];
    if (companyId != null && companyId.isNotEmpty) {
      futures.addAll([
        _attendanceController.loadActiveCheckinsForCompany(companyId),
        _attendanceController.loadLast10AttendancesForCompany(companyId),
        _attendanceController.loadLastCheckinAndCheckoutForCompany(companyId),
      ]);
    }
    try {
      await Future.wait(futures);
    } catch (e) {
      _showError(e);
    }
  }

  void _showError(Object e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e is Exception ? e.toString() : 'Erro interno')),
    );
  }

  void _openAllCompanyAttendances() {
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
    final mq = MediaQuery.of(context);
    final listHeight = ((mq.size.height - mq.padding.top - kToolbarHeight) *
            0.36)
        .clamp(180.0, 520.0);

    return AnimatedBuilder(
      animation: Listenable.merge([
        _companyController,
        _childController,
        _attendanceController,
        _collaboratorController,
      ]),
      builder: (context, _) {
        final loading =
            _companyController.isLoading ||
            _childController.refreshLoading ||
            _attendanceController.isLoadingActiveCheckins ||
            _attendanceController.isLoadingLogs ||
            _attendanceController.isLoadingLastCheck;

        return SafeArea(
          child: Center(
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
                      _CollaboratorCard(
                        companyName: _companyController.company?.name,
                        collaboratorName:
                            _collaboratorController.loggedCollaborator?.name,
                        logoUrl: _companyController.company?.logoUrl,
                        loading: loading,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProfileScreen(
                              selectedCollaborator:
                                  _collaboratorController.loggedCollaborator,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _CheckInOutButtons(
                        enabled: !loading,
                        onCheckin: () =>
                            showAttendanceModal(context, AttendanceType.checkin),
                        onCheckout: () =>
                            showAttendanceModal(context, AttendanceType.checkout),
                      ),
                      const SizedBox(height: 12),
                      _ActiveChildrenCard(
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
                      _PresenceLogCard(
                        height: listHeight,
                        loading: loading,
                        events: _attendanceController.logEvents,
                        childController: _childController,
                        logListController: _logListController,
                        onSeeMore: _openAllCompanyAttendances,
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

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _CollaboratorCard extends StatelessWidget {
  final String? companyName;
  final String? collaboratorName;
  final String? logoUrl;
  final bool loading;
  final VoidCallback? onTap;

  const _CollaboratorCard({
    required this.companyName,
    required this.collaboratorName,
    required this.logoUrl,
    required this.loading,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Skeletonizer(
      enabled: loading,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEF1F7)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: scheme.primaryContainer,
                backgroundImage:
                    logoUrl != null ? NetworkImage(logoUrl!) : null,
                child: logoUrl == null
                    ? Icon(Icons.business_rounded, color: scheme.primary, size: 28)
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      companyName ?? '—',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0F1218),
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      collaboratorName != null
                          ? 'Colaborador: $collaboratorName'
                          : '—',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9AA3B5),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFFC4CADA),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CheckInOutButtons extends StatelessWidget {
  final bool enabled;
  final VoidCallback onCheckin;
  final VoidCallback onCheckout;

  const _CheckInOutButtons({
    required this.enabled,
    required this.onCheckin,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            label: translate('home.check_in'),
            icon: Icons.login_rounded,
            color: const Color(0xFF388E3C),
            bgColor: const Color(0xFFE8F5E9),
            enabled: enabled,
            onTap: onCheckin,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionButton(
            label: translate('home.check_out'),
            icon: Icons.logout_rounded,
            color: const Color(0xFFE65100),
            bgColor: const Color(0xFFFFF3E0),
            enabled: enabled,
            onTap: onCheckout,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final bool enabled;
  final VoidCallback onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
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
            mainAxisSize: MainAxisSize.min,
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
}

class _ActiveChildrenCard extends StatelessWidget {
  final AttendanceController attendanceController;
  final ChildController childController;
  final bool loading;
  final VoidCallback onTap;

  const _ActiveChildrenCard({
    required this.attendanceController,
    required this.childController,
    required this.loading,
    required this.onTap,
  });

  String _lastEventName(Map<String, dynamic>? snapshot, String? childId) {
    if (snapshot != null && snapshot['name'] is String) {
      return snapshot['name'] as String;
    }
    return childController.getChildById(childId)?.name ?? '—';
  }

  @override
  Widget build(BuildContext context) {
    final lastIn = attendanceController.lastCheckIn;
    final lastOut = attendanceController.lastCheckOut;
    final activeCount = attendanceController.activeCheckins.length;

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
            // Contador de ativos
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
                      '$activeCount',
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

            // Últimos check-in e checkout
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _LastEventRow(
                    icon: Icons.login_rounded,
                    color: const Color(0xFF388E3C),
                    label: translate('home.last_check_in'),
                    name: _lastEventName(lastIn?.childSnapshot, lastIn?.childId),
                    time: formatDate_ddMM_HHmm(lastIn?.checkInTime),
                    empty: translate('home.no_checkins_registered'),
                  ),
                  const Divider(height: 20, color: Color(0xFFEEF1F7)),
                  _LastEventRow(
                    icon: Icons.logout_rounded,
                    color: const Color(0xFFE65100),
                    label: translate('home.last_check_out'),
                    name: _lastEventName(lastOut?.childSnapshot, lastOut?.childId),
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

class _LastEventRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final String name;
  final String time;
  final String empty;

  const _LastEventRow({
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
      crossAxisAlignment: CrossAxisAlignment.center,
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
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9AA3B5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                hasData ? name : empty,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: hasData
                      ? const Color(0xFF0F1218)
                      : const Color(0xFFC4CADA),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        if (hasData)
          Text(
            time,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF9AA3B5),
            ),
          ),
      ],
    );
  }
}

class _PresenceLogCard extends StatelessWidget {
  final double height;
  final bool loading;
  final List events;
  final ChildController childController;
  final ScrollController logListController;
  final VoidCallback onSeeMore;

  const _PresenceLogCard({
    required this.height,
    required this.loading,
    required this.events,
    required this.childController,
    required this.logListController,
    required this.onSeeMore,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
                const Icon(Icons.history_rounded,
                    size: 18, color: Color(0xFF9AA3B5)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    translate('home.30_last_presence_log'),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F1218),
                    ),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.inbox_rounded,
                            size: 48, color: const Color(0xFFC4CADA)),
                        const SizedBox(height: 8),
                        Text(
                          translate('home.no_presence_records'),
                          style: const TextStyle(
                            color: Color(0xFF9AA3B5),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    controller: logListController,
                    padding: EdgeInsets.zero,
                    itemCount: events.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: Color(0xFFEEF1F7)),
                    itemBuilder: (_, i) {
                      final event = events[i] as Attendance;
                      final isCheckin =
                          event.attendanceType == AttendanceType.checkin;
                      final childName =
                          (event.childSnapshot?['name'] is String)
                          ? event.childSnapshot!['name'] as String
                          : childController.getChildById(event.childId)?.name ??
                                '';

                      return ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: CircleAvatar(
                          radius: 20,
                          backgroundColor: isCheckin
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFFFF3E0),
                          child: Icon(
                            isCheckin
                                ? Icons.login_rounded
                                : Icons.logout_rounded,
                            size: 16,
                            color: isCheckin
                                ? const Color(0xFF388E3C)
                                : const Color(0xFFE65100),
                          ),
                        ),
                        title: Text(
                          childName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          formatDate_ddMM_HHmm(
                            event.checkInTime ?? event.checkOutTime,
                          ),
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
                            color: isCheckin
                                ? const Color(0xFFE8F5E9)
                                : const Color(0xFFFFF3E0),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            isCheckin
                                ? translate('home.check_in')
                                : translate('home.check_out'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isCheckin
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
}
