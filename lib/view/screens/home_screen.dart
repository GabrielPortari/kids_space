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
      child: Center(
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
    );
  }

  Widget _presenceLogCard(double listHeight) {
    return Observer(
      builder: (_) {
        final events = _checkEventController.logEvents;
        final limited = events.take(30).toList();

        return Skeletonizer(
          enabled: _checkEventController.isLoadingLog,
          child: Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
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
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: listHeight,
                    child: limited.isEmpty
                        ? Center(
                            child: Text(
                              translate('home.no_presence_records'),
                              style: const TextStyle(color: Colors.grey),
                            ),
                          )
                        : Scrollbar(
                            thumbVisibility: true,
                            child: ListView.separated(
                              primary: false,
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: limited.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (context, idx) {
                                final event = limited[idx];
                                final isCheckin =
                                    event.checkType == CheckType.checkIn;
                                return ListTile(
                                  contentPadding: const EdgeInsets.fromLTRB(
                                    4.0,
                                    0.0,
                                    8.0,
                                    0.0,
                                  ),
                                  leading: CircleAvatar(
                                    radius: 20,
                                    backgroundColor: isCheckin
                                        ? Colors.green[50]
                                        : Colors.red[50],
                                    child: Icon(
                                      isCheckin ? Icons.login : Icons.logout,
                                      color: isCheckin
                                          ? Colors.green
                                          : Colors.red,
                                      size: 18,
                                    ),
                                  ),
                                  title: Text(
                                    event.child.name,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  subtitle: Text(
                                    '${formatDate(event.timestamp)} • ${formatTime(event.timestamp)}',
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  trailing: Chip(
                                    label: Text(
                                      isCheckin
                                          ? translate('home.check_in')
                                          : translate('home.check_out'),
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                      ),
                                    ),
                                    backgroundColor: isCheckin
                                        ? Colors.green
                                        : Colors.red,
                                  ),
                                  onTap: () => debugPrint(
                                    'DebuggerLog: HomeScreen.log tapped index=$idx child=${event.child.name}',
                                  ),
                                );
                              },
                            ),
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
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    debugPrint('DebuggerLog: HomeScreen.navigate -> /profile');
                    Navigator.of(context).pushNamed('/profile');
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: Colors.deepPurple[50],
                          backgroundImage: AssetImage(
                            _companyController.companySelected?.logoUrl ??
                                'assets/images/company_logo_placeholder.png',
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _companyController.companySelected?.name ??
                                    translate('home.company_name'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
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
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.deepPurple,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    debugPrint(
                      'DebuggerLog: HomeScreen.checkIn button pressed',
                    );
                    // Ação de check-in
                  },
                  icon: const Icon(Icons.login, color: Colors.white),
                  label: Text(
                    translate('home.check_in'),
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 16),
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    debugPrint(
                      'DebuggerLog: HomeScreen.checkOut button pressed',
                    );
                    // Ação de check-out
                  },
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: Text(
                    translate('home.check_out'),
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    textStyle: const TextStyle(fontSize: 16),
                    backgroundColor: Colors.deepPurple,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
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

  Widget _activeChildrenInfoCard() {
    return Observer(
      builder: (_) {
        return Skeletonizer(
          enabled:
              _checkEventController.isLoadingActiveCheckins ||
              _checkEventController.isLoadingLastCheck,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () {
                          debugPrint(
                            'HomeScreen.navigate -> /all_active_children',
                          );
                          Navigator.of(
                            context,
                          ).pushNamed('/all_active_children');
                        },
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                translate('home.actives'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                '${_checkEventController.activeCheckins?.length ?? 0}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple,
                                ),
                              ),
                              Text(
                                translate('home.see_more'),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.deepPurple,
                                ),
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
                              const Icon(
                                Icons.login,
                                color: Colors.green,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                translate('home.last_check_in'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 32.0,
                              top: 2.0,
                            ),
                            child: _checkEventController.lastCheckIn != null
                                ? Row(
                                    children: [
                                      Text(
                                        _checkEventController
                                                .lastCheckIn
                                                ?.child
                                                .name ??
                                            '-',
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        formatTime(
                                          _checkEventController
                                                  .lastCheckIn
                                                  ?.timestamp ??
                                              DateTime.now(),
                                        ),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
                                    translate('home.no_checkins_registered'),
                                  ),
                          ),
                          const Divider(height: 20),
                          Row(
                            children: [
                              const Icon(
                                Icons.logout,
                                color: Colors.red,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                translate('home.last_check_out'),
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              left: 32.0,
                              top: 2.0,
                            ),
                            child: _checkEventController.lastCheckOut != null
                                ? Row(
                                    children: [
                                      Text(
                                        _checkEventController
                                                .lastCheckOut
                                                ?.child
                                                .name ??
                                            '-',
                                        style: const TextStyle(fontSize: 15),
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        formatTime(
                                          _checkEventController
                                                  .lastCheckOut
                                                  ?.timestamp ??
                                              DateTime.now(),
                                        ),
                                        style: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  )
                                : Text(
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
          ),
        );
      },
    );
  }
}
