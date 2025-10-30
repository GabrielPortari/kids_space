import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/check_event_controller.dart';
import 'package:kids_space/model/check_event.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/util/date_hour_util.dart';

final CompanyController _companyController = GetIt.I<CompanyController>();
final CollaboratorController _collaboratorController = GetIt.I<CollaboratorController>();
final CheckEventController _checkEventController = GetIt.I<CheckEventController>();

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          _infoCompanyCard(),
          const SizedBox(height: 8),
          _checkInAndOutButtons(),
          const SizedBox(height: 8),
          _activeChildrenInfoCard(),
          const SizedBox(height: 8),
          Expanded(child: _inAndOutList()),
        ],
      ),
    );
  }

  Widget _activeChildrenInfoCard() {
    final company = _companyController.companySelected;
    final companyId = company?.id;
    if (companyId != null) {
      _checkEventController.loadEventsForCompany(companyId);
    }
    final lastCheckIn = _checkEventController.loadedLastCheckIn;
    final lastCheckOut = _checkEventController.loadedLastCheckOut;
    final int activeCount = _checkEventController.getActiveCheckins(companyId!).length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Row(
            children: [
              Builder(
                builder: (context) => GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/all_active_children');
                  },
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Ativos',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 22, color: Colors.grey),
                        ),
                        Text(
                          '$activeCount',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepPurple,
                          ),
                        ),
                        const Text(
                          'Ver mais',
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
                        const Icon(Icons.login, color: Colors.green, size: 20),
                        const SizedBox(width: 6),
                        const Text(
                          'Último check-in:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0, top: 2.0),
                      child: lastCheckIn != null
                          ? Row(
                              children: [
                                Text(
                                  lastCheckIn.child.name,
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  formatTime(lastCheckIn.timestamp),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            )
                          : const Text('Nenhum check-in registrado'),
                    ),
                    const Divider(height: 20),
                    Row(
                      children: [
                        const Icon(Icons.logout, color: Colors.red, size: 20),
                        const SizedBox(width: 6),
                        const Text(
                          'Último check-out:',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 32.0, top: 2.0),
                      child: lastCheckOut != null
                          ? Row(
                              children: [
                                Text(
                                  lastCheckOut.child.name,
                                  style: const TextStyle(fontSize: 15),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  formatTime(lastCheckOut.timestamp),
                                  style: const TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            )
                          : const Text('Nenhum check-out registrado'),
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


  Widget _checkInAndOutButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          ElevatedButton.icon(
            onPressed: () {
              // Ação de check-in
            },
            icon: const Icon(Icons.login, color: Colors.white),
            label: const Text(
              'Check-In',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 16),
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () {
              // Ação de check-out
            },
            icon: const Icon(Icons.logout, color: Colors.white),
            label: const Text(
              'Check-Out',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              textStyle: const TextStyle(fontSize: 16),
              backgroundColor: Colors.deepPurple,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inAndOutList() {
    final company = _companyController.companySelected;
    final companyId = company?.id;
    final List<CheckEvent> logEvents =
        companyId != null ? 
        _checkEventController.getLastEventsByCompany(companyId, limit: 30) : [];
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Log de presença (últimos 30)',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: ListView.separated(
                  itemCount: logEvents.length,
                  separatorBuilder: (context, index) => const Divider(height: 12),
                  itemBuilder: (context, index) {
                    final event = logEvents[index];
                    final isCheckin = event.checkType == CheckType.checkIn;
                    return Row(
                      children: [
                        Icon(
                          isCheckin ? Icons.login : Icons.logout,
                          color: isCheckin ? Colors.green : Colors.red,
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            event.child.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          formatTime(event.timestamp),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          formatDate(event.timestamp),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCompanyCard() {
    return Builder(
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.only(top: 32.0),
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: IntrinsicHeight(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed('/profile');
                          },
                          child: CircleAvatar(
                            radius: 32,
                            backgroundImage: const AssetImage(
                              'assets/images/company_logo_placeholder.png',
                            ),
                            backgroundColor: Colors.deepPurple[50],
                            child: const Icon(
                              Icons.business,
                              size: 32,
                              color: Colors.deepPurple,
                            ),
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
                                    'Nome da Empresa',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Colaborador: ${_collaboratorController.loggedCollaborator?.name ?? 
                                "Nome do Colaborador"}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.deepPurple,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    'id: ${_collaboratorController.loggedCollaborator?.id ?? "ID do Colaborador"}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(width: 6),
                                  InkWell(
                                    child: const Icon(
                                      Icons.copy,
                                      size: 18,
                                      color: Colors.grey,
                                    ),
                                    onTap: () async {
                                      await Clipboard.setData(
                                        ClipboardData(
                                          text:
                                              _collaboratorController.loggedCollaborator?.id ?? "0",
                                        ),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'ID copiado para a área de transferência!',
                                          ),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
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
