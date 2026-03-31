import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/attendance_controller.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/model/attendance.dart';
import 'package:kids_space/util/date_hour_util.dart';
import 'package:kids_space/util/localization_service.dart';
import 'package:kids_space/view/screens/profile_screen.dart';
import 'package:kids_space/view/screens/childrens_screen.dart';
import 'package:kids_space/view/widgets/attendance_modal.dart';
import 'package:kids_space/view/design_system/app_card.dart';
import 'package:kids_space/view/design_system/app_button.dart';
import 'package:kids_space/view/design_system/app_text.dart';
import 'package:kids_space/view/design_system/app_theme.dart';
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
  final _collaboratorController = GetIt.I.get<CollaboratorController>();
  final _attendanceController = GetIt.I.get<AttendanceController>();
  final _childController = GetIt.I.get<ChildController>();

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _logListController = ScrollController();
    _onRefresh();
    // Listen to AttendanceController (ChangeNotifier) to refresh UI
    _attendanceController.addListener(_attendanceListener);
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
    final String? companyId = _companyController.company?.id;

    // Ensure company is loaded: try collaborator's company if available.
    if (_companyController.company == null) {
      final collId = _collaboratorController.loggedCollaborator?.companyId;
      if (collId != null && collId.isNotEmpty) {
        try {
          await _companyController.loadCompanyById(collId);
        } catch (e) {
          // ignore - fallback to loadMyCompany
        }
      } else {
        try {
          await _companyController.loadMyCompany();
        } catch (_) {}
      }
    }

    // Always try to refresh children for the current company and
    // pull attendance data when a company is selected.
    final futures = <Future>[];
    futures.add(_childController.refreshChildrenForCompany(companyId));

    if (companyId != null && companyId.isNotEmpty) {
      futures.add(
        _attendanceController.loadActiveCheckinsForCompany(companyId),
      );
      futures.add(
        _attendanceController.loadLast10AttendancesForCompany(companyId),
      );
      futures.add(
        _attendanceController.loadLastCheckinAndCheckoutForCompany(companyId),
      );
    }

    try {
      await Future.wait(futures);
    } catch (e) {
      // Surface a user-friendly error and keep the UI responsive.
      _showError(e);
    }
  }

  void _showError(Object e) {
    if (!mounted) return;
    final msg = e is Exception ? e.toString() : 'Erro interno';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenHeight = mq.size.height - mq.padding.top - kToolbarHeight;
    final listHeight = (screenHeight * 0.36).clamp(180.0, 520.0).toDouble();
    return Observer(
      builder: (_) {
        final globalLoading =
            _companyController.isLoading ||
            _childController.refreshLoading ||
            _attendanceController.isLoadingActiveCheckins ||
            _attendanceController.isLoadingLogs ||
            _attendanceController.isLoadingLastCheck;

        return SafeArea(
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
                              padding: const EdgeInsets.all(8.0),
                              child: _infoCompanyCard(globalLoading),
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
        );
      },
    );
  }

  Widget _presenceLogCard(double listHeight, bool globalLoading) {
    final events = _attendanceController.logEvents;

    if (globalLoading) {
      return AppCard(
        child: SizedBox(
          height: listHeight,
          child: const SkeletonList(itemCount: 6),
        ),
      );
    }

    if (events.isEmpty) {
      return AppCard(
        child: SizedBox(
          height: listHeight,
          child: Center(
            child: TextBodyMedium(translate('home.no_presence_records')),
          ),
        ),
      );
    }

    return AppCard(
      child: SizedBox(
        height: listHeight,
        child: Scrollbar(
          thumbVisibility: true,
          controller: _logListController,
          child: ListView.separated(
            controller: _logListController,
            itemCount: events.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, idx) {
              final event = events[idx];
              final isCheckin = event.attendanceType == AttendanceType.checkin;
              final child = _childController.getChildById(event.childId);
              final childName = child?.name ?? '';

              return ListTile(
                contentPadding: const EdgeInsets.fromLTRB(4.0, 0.0, 8.0, 0.0),
                leading: CircleAvatar(
                  radius: 20,
                  backgroundColor: isCheckin ? successBg : dangerBg,
                  child: Icon(
                    isCheckin ? Icons.login : Icons.logout,
                    color: isCheckin ? success : danger,
                    size: 18,
                  ),
                ),
                title: TextBodyMedium(
                  childName,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: TextBodySmall(
                  formatDate_ddMM_HHmm(event.checkInTime ?? event.checkOutTime),
                ),
                trailing: Chip(
                  label: TextBodySmall(
                    isCheckin
                        ? translate('home.check_in')
                        : translate('home.check_out'),
                    style: TextStyle(color: isCheckin ? successBg : dangerBg),
                  ),
                  backgroundColor: isCheckin ? success : danger,
                ),
                onTap: null,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _infoCompanyCard(bool globalLoading) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: AppCard(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ProfileScreen(
                selectedCollaborator:
                    _collaboratorController.loggedCollaborator,
              ),
            ),
          );
        },
        child: Skeletonizer(
          enabled: globalLoading,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 32,
                backgroundImage: _companyController.company?.logoUrl != null
                    ? NetworkImage(_companyController.company!.logoUrl!)
                    : const AssetImage(
                            'assets/images/company_logo_placeholder.png',
                          )
                          as ImageProvider,
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextHeaderMedium(_companyController.company?.name ?? '-'),
                    const SizedBox(height: 2),
                    TextBodyMedium(
                      translate(
                        'home.collaborator_name',
                        namedArgs: {
                          'name_placeholder':
                              _collaboratorController
                                  .loggedCollaborator
                                  ?.name ??
                              '-',
                        },
                      ),
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
                          _childController
                                  .getChildById(
                                    _attendanceController.lastCheckIn?.childId,
                                  )
                                  ?.name !=
                              null
                          ? TextBodyMedium(
                              '${_childController.getChildById(_attendanceController.lastCheckIn?.childId)!.name} - ${formatDate_ddMM_HHmm(_attendanceController.lastCheckIn?.checkInTime)}',
                            )
                          : TextBodyMedium(
                              translate('home.no_checkins_registered'),
                            ),
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
                          _childController
                                  .getChildById(
                                    _attendanceController.lastCheckOut?.childId,
                                  )
                                  ?.name !=
                              null
                          ? TextBodyMedium(
                              '${_childController.getChildById(_attendanceController.lastCheckOut?.childId)!.name} - ${formatDate_ddMM_HHmm(_attendanceController.lastCheckOut?.checkOutTime)}',
                            )
                          : TextBodyMedium(
                              translate('home.no_checkouts_registered'),
                            ),
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
}
