import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/model/company.dart';
import 'package:kids_space/util/localization_service.dart';
import 'package:kids_space/view/screens/company_attendances_screen.dart';
import 'package:kids_space/view/screens/profile_screen.dart';
import '../../util/company_tile_helpers.dart';
import '../../model/company_tile_model.dart';
import '../widgets/company_tile.dart';

final AuthController _authController = GetIt.I<AuthController>();

class CompanyScreen extends StatefulWidget {
  const CompanyScreen({Key? key}) : super(key: key);

  @override
  State<CompanyScreen> createState() => _CompanyScreenState();
}

class _CompanyScreenState extends State<CompanyScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<CompanyTileModel> _companyItems = const [
    CompanyTileModel(type: CompanyTileType.dashboard, icon: Icons.dashboard),
    CompanyTileModel(
      type: CompanyTileType.attendances,
      icon: Icons.fact_check_outlined,
    ),
    CompanyTileModel(type: CompanyTileType.company, icon: Icons.business),
    CompanyTileModel(type: CompanyTileType.collaborator, icon: Icons.group),
    CompanyTileModel(type: CompanyTileType.responsible, icon: Icons.person),
    CompanyTileModel(type: CompanyTileType.child, icon: Icons.child_care),
    //CompanyTileModel(type: CompanyTileType.reports, icon: Icons.bar_chart),
  ];
  final CompanyController _companyController = GetIt.I.get<CompanyController>();
  final CollaboratorController _collaboratorController = GetIt.I
      .get<CollaboratorController>();

  Company? get company {
    // Prefer company already loaded in CompanyController (e.g., when a company user is logged)
    if (_companyController.company != null) return _companyController.company;
    // Fallback to collaborator's company id if a collaborator is logged
    final collCompanyId = _collaboratorController.loggedCollaborator?.companyId;
    if (collCompanyId == null || collCompanyId.isEmpty) return null;
    return _companyController.getCompanyById(collCompanyId);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        tooltip: translate('ui.logout_confirm_title'),
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(translate('ui.logout_confirm_title')),
              content: Text(translate('ui.logout_confirm_message')),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(translate('buttons.cancel')),
                ),
                TextButton(
                  style: TextButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                  ),
                  onPressed: () async {
                    await _authController.logout();
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/login', (route) => false);
                  },
                  child: Text(translate('ui.logout_button')),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.logout),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: EdgeInsets.all(16),
                child: ListView.separated(
                  itemCount: _companyItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final model = _companyItems[index];
                    return CompanyTile(
                      model: model,
                      onTap: () async {
                        if (model.type == CompanyTileType.company) {
                          // ensure company is loaded before navigating
                          final loggedColl =
                              _collaboratorController.loggedCollaborator;
                          final collCompanyId = loggedColl?.companyId ?? '';
                          Company? comp = company;
                          if (comp == null && collCompanyId.isNotEmpty) {
                            await _companyController.loadCompanyById(
                              collCompanyId,
                            );
                            comp = _companyController.company;
                          }
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  ProfileScreen(selectedCompany: comp),
                            ),
                          );
                        } else if (model.type == CompanyTileType.attendances) {
                          final currentCompany = company;
                          final companyId = currentCompany?.id;
                          if (companyId == null || companyId.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Company nao carregada.'),
                              ),
                            );
                            return;
                          }

                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => CompanyAttendancesScreen(
                                companyId: companyId,
                                companyName: currentCompany?.name,
                              ),
                            ),
                          );
                        } else {
                          Navigator.pushNamed(
                            context,
                            getNavigationRoute(model.type),
                          );
                        }
                      },
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
