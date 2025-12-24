import 'package:flutter/material.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/check_event_controller.dart';
import 'package:kids_space/model/check_event.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/util/date_hour_util.dart';
import 'package:kids_space/util/localization_service.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kids_space/view/design_system/app_card.dart';
import 'package:kids_space/view/design_system/app_button.dart';
import 'package:kids_space/view/design_system/app_text.dart';
import 'package:kids_space/view/design_system/app_theme_colors.dart';

final CompanyController _companyController = GetIt.I<CompanyController>();
final CollaboratorController _collaboratorController =
    GetIt.I<CollaboratorController>();
final CheckEventController _checkEventController =
    GetIt.I<CheckEventController>();

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    debugPrint('DebuggerLog: HomeScreen.initState');
    _scrollController = ScrollController();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
        final events = _checkEventController.logEvents;
        final limited = events.take(30).toList();

        return Skeletonizer(
          enabled: _checkEventController.isLoadingLog,
          child: AppCard(
            elevation: 3,
            borderRadius: BorderRadius.circular(12),
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 4.0,
                  ),
                  child: Text(
                    translate('home.30_last_presence_log'),
                    style: AppText.headerSmall(context),
                  ),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  height: listHeight,
                  child: limited.isEmpty
                      ? Center(
                              child: Text(
                                translate('home.no_presence_records'),
                                style: AppText.bodyMedium(context).copyWith(color: paragraph.withOpacity(0.6)),
                              ),
                        )
                      : Scrollbar(
                          thumbVisibility: true,
                          child: ListView.separated(
                            primary: false,
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: limited.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (context, idx) {
                              final event = limited[idx];
                              final isCheckin = event.checkType == CheckType.checkIn;
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
                                title: Text(
                                  event.child.name,
                                  style: AppText.bodyMedium(context).copyWith(fontWeight: FontWeight.w600, fontSize: 15),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                subtitle: Text(
                                  '${formatDate(event.timestamp)} • ${formatTime(event.timestamp)}',
                                  style: AppText.bodySmall(context).copyWith(color: paragraph.withOpacity(0.6)),
                                ),
                                trailing: Chip(
                                  label: Text(
                                    isCheckin ? translate('home.check_in') : translate('home.check_out'),
                                    style: AppText.caption(context).copyWith(color: Colors.white, fontSize: 12),
                                  ),
                                  backgroundColor: isCheckin ? success : danger,
                                ),
                                onTap: () => debugPrint('DebuggerLog: HomeScreen.log tapped index=$idx child=${event.child.name}'),
                              );
                            },
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

  Future<void> _loadData() async {
    final companyId = _companyController.companySelected?.id;
    if (companyId != null) {
      debugPrint('DebuggerLog: HomeScreen._loadData START for $companyId');
      await Future.wait([
        _checkEventController.loadEvents(companyId),
        _checkEventController.loadLastCheckinAndOut(companyId),
        _checkEventController.loadActiveCheckins(companyId),
        _checkEventController.loadLog(companyId, limit: 30),
      ]);
      debugPrint('DebuggerLog: HomeScreen._loadData DONE');
    }
  }

  Widget _infoCompanyCard() {
    return Observer(
      builder: (_) => Skeletonizer(
        enabled: _checkEventController.isLoadingEvents,
        child: Builder(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: AppCard(
                elevation: 4,
                borderRadius: BorderRadius.circular(16),
                padding: const EdgeInsets.all(16.0),
                onTap: () {
                  debugPrint('DebuggerLog: HomeScreen.navigate -> /profile');
                  Navigator.of(context).pushNamed('/profile');
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: illSecondary.withOpacity(0.12),
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
                          Text(
                            _companyController.companySelected?.name ?? translate('home.company_name'),
                            style: AppText.headerMedium(context).copyWith(fontSize: 20),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            translate('home.collaborator_name', namedArgs: {
                              'name_placeholder': _collaboratorController.loggedCollaborator?.name ?? '-',
                            }),
                            style: AppText.bodyMedium(context).copyWith(color: illSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _checkInAndOutButtons() {
    return Observer(
      builder: (_) {
        return Skeletonizer(
          enabled: !_checkEventController.allLoaded,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      AppButton(
                        onPressed: () {
                          debugPrint('DebuggerLog: HomeScreen.checkIn button pressed');
                        },
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                            children: [
                            Icon(Icons.login, color: buttonText),
                            const SizedBox(width: 8),
                            Text(translate('home.check_in'), style: AppText.button(context).copyWith(fontSize: 16)),
                          ],
                        ),
                      ),
                      AppButton(
                        onPressed: () {
                          debugPrint('DebuggerLog: HomeScreen.checkOut button pressed');
                        },
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                            children: [
                            Icon(Icons.logout, color: buttonText),
                            const SizedBox(width: 8),
                            Text(translate('home.check_out'), style: AppText.button(context).copyWith(fontSize: 16)),
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

  Widget _activeChildrenInfoCard() {
    return Observer(
      builder: (_) {
        return Skeletonizer(
          enabled:
              _checkEventController.isLoadingActiveCheckins ||
              _checkEventController.isLoadingLastCheck,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: AppCard(
              elevation: 3,
              borderRadius: BorderRadius.circular(12),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
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
                            Text(
                              translate('home.actives'),
                              textAlign: TextAlign.center,
                              style: AppText.title(context).copyWith(fontSize: 22),
                            ),
                            Text(
                              '${_checkEventController.activeCheckins?.length ?? 0}',
                              textAlign: TextAlign.center,
                              style: AppText.headerLarge(context).copyWith(fontSize: 56, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              translate('home.see_more'),
                              textAlign: TextAlign.center,
                              style: AppText.bodyMedium(context).copyWith(),
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
                            Text(
                              translate('home.last_check_in'),
                              style: AppText.bodyMedium(context).copyWith(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 32.0, top: 2.0),
                          child: _checkEventController.lastCheckIn != null
                              ? Row(
                                  children: [
                                    Text(
                                      _checkEventController.lastCheckIn?.child.name ?? '-',
                                      style: AppText.bodyMedium(context),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      formatTime(_checkEventController.lastCheckIn?.timestamp ?? DateTime.now()),
                                      style: AppText.bodyMedium(context).copyWith(color: paragraph.withOpacity(0.6)),
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
                            Text(
                              translate('home.last_check_out'),
                              style: AppText.bodyMedium(context).copyWith(fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 32.0, top: 2.0),
                          child: _checkEventController.lastCheckOut != null
                              ? Row(
                                  children: [
                                    Text(
                                      _checkEventController.lastCheckOut?.child.name ?? '-',
                                      style: AppText.bodyMedium(context),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      formatTime(_checkEventController.lastCheckOut?.timestamp ?? DateTime.now()),
                                      style: AppText.bodyMedium(context).copyWith(color: paragraph.withOpacity(0.6)),
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
