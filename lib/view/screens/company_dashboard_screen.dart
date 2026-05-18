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
import 'package:kids_space/view/design_system/app_button.dart';
import 'package:kids_space/view/design_system/app_card.dart';
import 'package:kids_space/view/design_system/app_text.dart';
import 'package:kids_space/view/design_system/app_theme.dart';
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
    final futures = <Future<dynamic>>[
      _childController.refreshChildrenForCompany(companyId),
      _parentController.refreshUsersForCompany(companyId),
      _collaboratorController.refreshCollaboratorsForCompany(companyId),
      _attendanceController.loadActiveCheckinsForCompany(companyId),
      _attendanceController.loadLast10AttendancesForCompany(companyId),
      _attendanceController.loadLastCheckinAndCheckoutForCompany(companyId),
    ];

    try {
      await Future.wait(futures);
    } catch (e) {
      _showError(e);
    }
  }

  void _showError(Object e) {
    if (!mounted) return;
    final msg = e is Exception ? e.toString() : 'Erro interno';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _openAllCompanyAttendances() {
    final companyId = _companyController.company?.id;
    if (companyId == null || companyId.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Company nao carregada.')));
      return;
    }

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
    final screenHeight = mq.size.height - mq.padding.top - kToolbarHeight;
    final listHeight = (screenHeight * 0.36).clamp(180.0, 520.0).toDouble();

    return AnimatedBuilder(
      animation: Listenable.merge([
        _companyController,
        _childController,
        _parentController,
        _attendanceController,
        _collaboratorController,
      ]),
      builder: (_, __) {
        final globalLoading =
            _companyController.isLoading ||
            _childController.refreshLoading ||
            _parentController.refreshLoading ||
            _collaboratorController.refreshLoading ||
            _attendanceController.isLoadingActiveCheckins ||
            _attendanceController.isLoadingLogs ||
            _attendanceController.isLoadingLastCheck;

        return Scaffold(
          appBar: AppBar(title: const Text('Dashboard')),
          body: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 720),
                    child: RefreshIndicator(
                      onRefresh: _onRefresh,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const AlwaysScrollableScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: _companyTotalsCard(globalLoading),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: _checkInAndOutButtons(globalLoading),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0,
                                ),
                                child: _activeChildrenInfoCard(globalLoading),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                  vertical: 8.0,
                                ),
                                child: _presenceLogCard(
                                  listHeight,
                                  globalLoading,
                                ),
                              ),
                              const SizedBox(height: 48),
                            ],
                          ),
                        ),
                      ),
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

  Widget _checkInAndOutButtons(bool globalLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          AppButton(
            enabled: !globalLoading,
            text: translate('home.check_in'),
            icon: const Icon(Icons.login_rounded, color: Colors.white),
            onPressed: globalLoading
                ? null
                : () => showAttendanceModal(context, AttendanceType.checkin),
          ),
          AppButton(
            enabled: !globalLoading,
            text: translate('home.check_out'),
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            onPressed: globalLoading
                ? null
                : () => showAttendanceModal(context, AttendanceType.checkout),
          ),
        ],
      ),
    );
  }

  Widget _companyTotalsCard(bool globalLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AppCard(
        child: Skeletonizer(
          enabled: globalLoading,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextHeaderSmall('Resumo da empresa'),
              const SizedBox(height: 12),
              _totalRow(
                icon: Icons.child_care,
                color: success,
                label: 'Criancas cadastradas',
                value: _childController.children.length,
              ),
              const SizedBox(height: 8),
              _totalRow(
                icon: Icons.people_alt_outlined,
                color: success,
                label: 'Responsaveis cadastrados',
                value: _parentController.parents.length,
              ),
              const SizedBox(height: 8),
              _totalRow(
                icon: Icons.badge_outlined,
                color: success,
                label: 'Colaboradores cadastrados',
                value: _collaboratorController.collaborators.length,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _totalRow({
    required IconData icon,
    required Color color,
    required String label,
    required int value,
  }) {
    return Row(
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: color.withValues(alpha: 0.15),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(child: TextBodyMedium(label)),
        TextHeaderMedium('$value'),
      ],
    );
  }

  Widget _activeChildrenInfoCard(bool globalLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: AppCard(
        child: Skeletonizer(
          enabled: globalLoading,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ChildrensScreen(onlyActive: true),
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextTitle(translate('home.actives')),
                      TextHeaderLarge(
                        '${_attendanceController.activeCheckins.length}',
                      ),
                      TextBodyMedium(translate('home.see_more')),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.login, color: success, size: 20),
                        const SizedBox(width: 6),
                        TextHeaderSmall(translate('home.last_check_in')),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0, top: 2.0),
                      child:
                          (_attendanceController.lastCheckIn?.childSnapshot !=
                                  null &&
                              _attendanceController
                                      .lastCheckIn!
                                      .childSnapshot!['name']
                                  is String)
                          ? TextBodyMedium(
                              '${_attendanceController.lastCheckIn!.childSnapshot!['name']} - ${formatDate_ddMM_HHmm(_attendanceController.lastCheckIn?.checkInTime)}',
                            )
                          : (_childController
                                        .getChildById(
                                          _attendanceController
                                              .lastCheckIn
                                              ?.childId,
                                        )
                                        ?.name !=
                                    null
                                ? TextBodyMedium(
                                    '${_childController.getChildById(_attendanceController.lastCheckIn?.childId)!.name} - ${formatDate_ddMM_HHmm(_attendanceController.lastCheckIn?.checkInTime)}',
                                  )
                                : TextBodyMedium(
                                    translate('home.no_checkins_registered'),
                                  )),
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        Icon(Icons.logout, color: danger, size: 20),
                        const SizedBox(width: 6),
                        TextHeaderSmall(translate('home.last_check_out')),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0, top: 2.0),
                      child:
                          (_attendanceController.lastCheckOut?.childSnapshot !=
                                  null &&
                              _attendanceController
                                      .lastCheckOut!
                                      .childSnapshot!['name']
                                  is String)
                          ? TextBodyMedium(
                              '${_attendanceController.lastCheckOut!.childSnapshot!['name']} - ${formatDate_ddMM_HHmm(_attendanceController.lastCheckOut?.checkOutTime)}',
                            )
                          : (_childController
                                        .getChildById(
                                          _attendanceController
                                              .lastCheckOut
                                              ?.childId,
                                        )
                                        ?.name !=
                                    null
                                ? TextBodyMedium(
                                    '${_childController.getChildById(_attendanceController.lastCheckOut?.childId)!.name} - ${formatDate_ddMM_HHmm(_attendanceController.lastCheckOut?.checkOutTime)}',
                                  )
                                : TextBodyMedium(
                                    translate('home.no_checkouts_registered'),
                                  )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _presenceLogCard(double listHeight, bool globalLoading) {
    final events = _attendanceController.logEvents;

    if (globalLoading) {
      return AppCard(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextHeaderSmall(
                      translate('home.30_last_presence_log'),
                    ),
                  ),
                  TextButton(
                    onPressed: null,
                    child: Text(translate('home.see_more')),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: listHeight,
              child: const SkeletonList(itemCount: 6),
            ),
          ],
        ),
      );
    }

    if (events.isEmpty) {
      return AppCard(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextHeaderSmall(
                      translate('home.30_last_presence_log'),
                    ),
                  ),
                  TextButton(
                    onPressed: _openAllCompanyAttendances,
                    child: Text(translate('home.see_more')),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: listHeight,
              child: Center(
                child: TextBodyMedium(translate('home.no_presence_records')),
              ),
            ),
          ],
        ),
      );
    }

    return AppCard(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 0),
            child: Row(
              children: [
                Expanded(
                  child: TextHeaderSmall(
                    translate('home.30_last_presence_log'),
                  ),
                ),
                TextButton(
                  onPressed: _openAllCompanyAttendances,
                  child: Text(translate('home.see_more')),
                ),
              ],
            ),
          ),
          SizedBox(
            height: listHeight,
            child: Scrollbar(
              thumbVisibility: true,
              controller: _logListController,
              child: ListView.separated(
                controller: _logListController,
                itemCount: events.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, idx) {
                  final event = events[idx];
                  final isCheckin =
                      event.attendanceType == AttendanceType.checkin;
                  final child = _childController.getChildById(event.childId);
                  final childName =
                      (event.childSnapshot != null &&
                          event.childSnapshot!['name'] is String)
                      ? (event.childSnapshot!['name'] as String)
                      : (child?.name ?? '');

                  return ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(
                      4.0,
                      0.0,
                      8.0,
                      0.0,
                    ),
                    leading: CircleAvatar(
                      radius: 20,
                      backgroundColor: isCheckin ? successBg : dangerBg,
                      backgroundImage:
                          (event.childSnapshot != null &&
                              event.childSnapshot!['photoUrl'] is String)
                          ? NetworkImage(
                              event.childSnapshot!['photoUrl'] as String,
                            )
                          : null,
                      child:
                          (event.childSnapshot == null ||
                              event.childSnapshot!['photoUrl'] == null)
                          ? Icon(
                              isCheckin ? Icons.login : Icons.logout,
                              color: isCheckin ? success : danger,
                              size: 18,
                            )
                          : null,
                    ),
                    title: TextBodyMedium(
                      childName,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: TextBodySmall(
                      formatDate_ddMM_HHmm(
                        event.checkInTime ?? event.checkOutTime,
                      ),
                    ),
                    trailing: Chip(
                      label: TextBodySmall(
                        isCheckin
                            ? translate('home.check_in')
                            : translate('home.check_out'),
                        style: TextStyle(
                          color: isCheckin ? successBg : dangerBg,
                        ),
                      ),
                      backgroundColor: isCheckin ? success : danger,
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
