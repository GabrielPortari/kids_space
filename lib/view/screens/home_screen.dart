import 'package:flutter/material.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/attendance_controller.dart';
import 'package:kids_space/controller/user_controller.dart';
import 'package:kids_space/model/attendance.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/util/date_hour_util.dart';
import 'package:kids_space/util/localization_service.dart';
import 'package:kids_space/view/screens/profile_screen.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kids_space/view/design_system/app_card.dart';
import 'package:kids_space/view/design_system/app_button.dart';
import 'package:kids_space/view/design_system/app_text.dart';
import 'package:kids_space/view/design_system/app_theme.dart';

final CompanyController _companyController = GetIt.I<CompanyController>();
final UserController _userController = GetIt.I<UserController>();
final CollaboratorController _collaboratorController = GetIt.I<CollaboratorController>();
final AttendanceController _attendanceController = GetIt.I<AttendanceController>();
final ChildController _childController = GetIt.I<ChildController>();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ScrollController _scrollController;
  late final ScrollController _logListController;

  @override
  void initState() {
    super.initState();
    debugPrint('DebuggerLog: HomeScreen.initState');
    _scrollController = ScrollController();
    _logListController = ScrollController();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _logListController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    debugPrint('DebuggerLog: HomeScreen._onRefresh called');
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final screenHeight = mq.size.height - mq.padding.top - kToolbarHeight;
    final listHeight = (screenHeight * 0.36).clamp(180.0, 520.0).toDouble();

    return SafeArea(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 720),
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
                          child: _infoCompanyCard(),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: _checkInAndOutButtons(),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: _activeChildrenInfoCard(),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: _presenceLogCard(listHeight),
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
  }

  Widget _presenceLogCard(double listHeight) {
    return Observer(
      builder: (_) {
        final events = _attendanceController.logEvents;
        final limited = events.take(30).toList();

        return AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 4.0,
                ),
                child: TextHeaderSmall(
                  translate('home.30_last_presence_log'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: listHeight,
                child: limited.isEmpty
                      ? Center(
                              child: TextBodyMedium(
                                translate('home.no_presence_records'),
                              ),
                        )
                      : Scrollbar(
                          controller: _logListController,
                          thumbVisibility: true,
                          child: ListView.separated(
                            controller: _logListController,
                            primary: false,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: limited.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, idx) {
                              final event = limited[idx];
                              final isCheckin = event.attendanceType == AttendanceType.checkin;
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
                                  _childController.getChildById(event.childId ?? '')?.name ?? '',
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: TextBodySmall(
                                  '${formatDate(event.checkinTime ?? event.checkoutTime ?? DateTime.now())} • ${formatTime(event.checkinTime ?? event.checkoutTime ?? DateTime.now())}',
                                ),
                                trailing: Chip(
                                  label: TextBodySmall(
                                    isCheckin ? translate('home.check_in') : translate('home.check_out'),
                                    style: TextStyle(
                                      color: isCheckin ? successBg : dangerBg,
                                    ),
                                  ),
                                  backgroundColor: isCheckin ? success : danger,
                                ),
                                onTap: () => debugPrint('DebuggerLog: HomeScreen.log tapped index=$idx childId=${event.childId}'),
                              );
                            },
                          ),
                        ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _loadData() async {
    final companyId = _companyController.companySelected?.id;
    if (companyId != null) {
      debugPrint('DebuggerLog: HomeScreen._loadData START for $companyId');
      await _userController.refreshUsersForCompany(companyId);
      await _childController.refreshChildrenForCompany(companyId);
      debugPrint('DebuggerLog: HomeScreen._loadData DONE');
    }
  }

  Widget _infoCompanyCard() {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: AppCard(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => 
                ProfileScreen(selectedCollaborator: _collaboratorController.loggedCollaborator))
              );
              debugPrint('DebuggerLog: HomeScreen.navigate -> /profile, arguments: ${_collaboratorController.loggedCollaborator}');
            },
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: AssetImage(
                    _companyController.companySelected?.logoUrl ?? 'assets/images/company_logo_placeholder.png',
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextHeaderMedium(
                        _companyController.companySelected?.fantasyName ?? translate('home.company_name'),
                      ),
                      const SizedBox(height: 2),
                      TextBodyMedium(translate('home.collaborator_name', namedArgs: {
                          'name_placeholder': _collaboratorController.loggedCollaborator?.name ?? '-',
                        })),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _checkInAndOutButtons() {
    return Observer(
      builder: (_) {
        return Skeletonizer(
          enabled: !_attendanceController.allLoaded,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AppButton(
                        text: translate('home.check_in'),
                        icon: Icon(Icons.login_rounded, color: Colors.white),
                        onPressed: () {
                          debugPrint('DebuggerLog: HomeScreen.checkIn button pressed');
                        },
                        ),
                      AppButton(
                        text: translate('home.check_out'),
                        icon: Icon(Icons.logout_rounded, color: Colors.white),
                        onPressed: () {
                          debugPrint('DebuggerLog: HomeScreen.checkOut button pressed');
                        },
                      ),
                    ],
                  ),
                ),
        );
      },
    );
  }

  Widget _activeChildrenInfoCard() {
    return Observer(
      builder: (_) {
        return Skeletonizer(
          enabled:
              _attendanceController.isLoadingActiveCheckins ||
              _attendanceController.isLoadingLastCheck,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AppCard(
              child: Row(
                children: [
                  Builder(
                    builder: (context) => GestureDetector(
                      onTap: () {
                        debugPrint('HomeScreen.navigate -> /all_active_children');
                        Navigator.of(context).pushNamed('/all_active_children');
                      },
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextTitle(
                              translate('home.actives'),
                            ),
                            TextHeaderLarge(
                              '${_attendanceController.activeCheckins?.length ?? 0}',
                            ),
                            TextBodyMedium(
                              translate('home.see_more'),
                            ),
                          ],
                        ),
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
                            TextHeaderSmall(
                              translate('home.last_check_in'),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 32.0, top: 2.0),
                          child: _attendanceController.lastCheckIn != null
                              ? Row(
                                  children: [
                                    TextBodyMedium(
                                      _childController.getChildById(_attendanceController.lastCheckIn?.childId ?? '')?.name ?? (_attendanceController.lastCheckIn?.childId ?? '-'),
                                    ),
                                    const SizedBox(width: 8),
                                    TextBodyMedium(
                                      formatTime(_attendanceController.lastCheckIn?.checkinTime ?? _attendanceController.lastCheckIn?.checkoutTime ?? DateTime.now()),
                                    ),
                                  ],
                                )
                              : Text(translate('home.no_checkins_registered')),
                        ),
                        const Divider(height: 20),
                        Row(
                          children: [
                            Icon(Icons.logout, color: danger, size: 20),
                            const SizedBox(width: 6),
                            TextHeaderSmall(
                              translate('home.last_check_out'),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 32.0, top: 2.0),
                          child: _attendanceController.lastCheckOut != null
                              ? Row(
                                  children: [
                                    TextBodyMedium(
                                                                     _childController.getChildById(_attendanceController.lastCheckOut?.childId ?? '')?.name ?? (_attendanceController.lastCheckOut?.childId ?? '-'),
                                    ),
                                    const SizedBox(width: 8),
                                    TextBodyMedium(
                                      formatTime(_attendanceController.lastCheckOut?.checkoutTime ?? _attendanceController.lastCheckOut?.checkinTime ?? DateTime.now()),
                                    ),
                                  ],
                                )
                              : Text(translate('home.no_checkouts_registered')),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
