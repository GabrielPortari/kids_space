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
  final List<CompanyTileModel> _companyItems = const [
    CompanyTileModel(type: CompanyTileType.dashboard, icon: Icons.dashboard_rounded),
    CompanyTileModel(type: CompanyTileType.attendances, icon: Icons.fact_check_outlined),
    CompanyTileModel(type: CompanyTileType.company, icon: Icons.business_rounded),
    CompanyTileModel(type: CompanyTileType.collaborator, icon: Icons.badge_rounded),
    CompanyTileModel(type: CompanyTileType.responsible, icon: Icons.people_rounded),
    CompanyTileModel(type: CompanyTileType.child, icon: Icons.child_care_rounded),
  ];

  final CompanyController _companyController = GetIt.I.get<CompanyController>();
  final CollaboratorController _collaboratorController =
      GetIt.I.get<CollaboratorController>();

  Company? get company {
    if (_companyController.company != null) return _companyController.company;
    final collCompanyId = _collaboratorController.loggedCollaborator?.companyId;
    if (collCompanyId == null || collCompanyId.isEmpty) return null;
    return _companyController.getCompanyById(collCompanyId);
  }

  Future<void> _confirmLogout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(translate('ui.logout_confirm_title')),
        content: Text(translate('ui.logout_confirm_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(translate('buttons.cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: const Color(0xFFB00020)),
            child: Text(translate('ui.logout_button')),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _authController.logout();
    if (mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final comp = company;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(comp?.name ?? 'Kids Space'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: translate('ui.logout_confirm_title'),
            onPressed: _confirmLogout,
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            children: [
              // ── Company header card ──────────────────────────────────────
              if (comp != null) ...[
                _CompanyHeaderCard(company: comp),
                const SizedBox(height: 16),
              ],

              // ── Navigation tiles ─────────────────────────────────────────
              Text(
                'Gestão',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF9AA3B5),
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(_companyItems.length, (i) {
                final model = _companyItems[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CompanyTile(
                    model: model,
                    onTap: () async {
                      if (model.type == CompanyTileType.company) {
                        final collCompanyId =
                            _collaboratorController.loggedCollaborator?.companyId ?? '';
                        Company? comp = company;
                        if (comp == null && collCompanyId.isNotEmpty) {
                          await _companyController.loadCompanyById(collCompanyId);
                          comp = _companyController.company;
                        }
                        if (!mounted) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ProfileScreen(selectedCompany: comp),
                          ),
                        );
                      } else if (model.type == CompanyTileType.attendances) {
                        final companyId = company?.id;
                        if (companyId == null || companyId.isEmpty) return;
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => CompanyAttendancesScreen(
                              companyId: companyId,
                              companyName: company?.name,
                            ),
                          ),
                        );
                      } else {
                        Navigator.pushNamed(context, getNavigationRoute(model.type));
                      }
                    },
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompanyHeaderCard extends StatelessWidget {
  final Company company;
  const _CompanyHeaderCard({required this.company});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF2962FF), Color(0xFF1A3EB3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: company.logoUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(company.logoUrl!, fit: BoxFit.cover),
                  )
                : const Icon(Icons.business_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company.name ?? '—',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                if (company.legalName != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    company.legalName!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withValues(alpha: 0.75),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
