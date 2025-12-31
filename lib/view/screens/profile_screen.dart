import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/model/base_user.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/model/company.dart';
import 'package:kids_space/model/user.dart';
import 'package:kids_space/util/string_utils.dart';
import 'package:kids_space/view/design_system/app_text.dart';
import 'package:flutter/services.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/service/child_service.dart';

enum SelectedProfileType {
  user,
  collaborator,
  admin,
  company
}

class ProfileScreen extends StatefulWidget {
  
  final User? selectedUser;
  
  final Collaborator? selectedCollaborator;
  final Company? selectedCompany;
  const ProfileScreen({super.key, this.selectedUser, this.selectedCollaborator, this.selectedCompany});
  
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final CollaboratorController _collaboratorController = GetIt.I<CollaboratorController>();
  final AuthController _authController = GetIt.I<AuthController>();
  final Map<String, bool> _collapsedCards = {};

  SelectedProfileType? get selectedProfileType {
    if (widget.selectedUser != null) {
      return SelectedProfileType.user;
    } else if (widget.selectedCollaborator != null) {
      return widget.selectedCollaborator!.userType == UserType.admin ? 
      SelectedProfileType.admin : SelectedProfileType.collaborator;
    } else if (widget.selectedCompany != null) {
      return SelectedProfileType.company;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {

    final Map<String, String> infoMap = _getProfileData();
    final profileEntries = infoMap.entries.toList();
    final Map<String, String> addressMap = _getAddressData();
    final addressEntries = addressMap.entries.toList();

    return Scaffold(
      appBar: _buildAppBar(),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 16),
                      _buildProfilePictureSection(context),
                      const SizedBox(height: 16),
                      _buildHeaderSection(context),
                      const SizedBox(height: 16),
                      _buildInfoCard(context, 'Dados pessoais', profileEntries),
                      const SizedBox(height: 16),
                      _buildInfoCard(context, 'Endereço', addressEntries),
                      const SizedBox(height: 16),
                      ...selectedProfileType == SelectedProfileType.user ? [_buildChildrenCard(context)] : [],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _buildAppBar(){
    String? title = 'Perfil';
    if (selectedProfileType != null) {
      switch (selectedProfileType!) {
        case SelectedProfileType.user:
          title = 'Perfil de ${widget.selectedUser?.name ?? 'user_placeholder'}';
          debugPrint('DebuggerLog: ProfileScreen.building selectedUserId= ${widget.selectedUser?.id ?? 'none'}, userType = $selectedProfileType');
          break;
        case (SelectedProfileType.collaborator || SelectedProfileType.admin):
          title = 'Perfil de ${widget.selectedCollaborator?.name ?? 'collaborator_placeholder'}';
          debugPrint('DebuggerLog: ProfileScreen.building selectedCollaboratorId= ${widget.selectedCollaborator?.id ?? 'none'}, userType = $selectedProfileType');
          break;
        case SelectedProfileType.company:
          title = 'Perfil de ${widget.selectedCompany?.fantasyName ?? widget.selectedCompany?.corporateName ?? 'company_placeholder'}';
          debugPrint('DebuggerLog: ProfileScreen.building selectedCompanyId= ${widget.selectedCompany?.id ?? 'none'}, userType = $selectedProfileType');
          break;
      }
    }

    /* Permissões do menu perfil */
    final loggedCollaborator = _collaboratorController.loggedCollaborator;
    final loggedUserType = loggedCollaborator?.userType;
    
    bool canEdit = false;
    if(loggedUserType == UserType.admin) {
      if(selectedProfileType != null && selectedProfileType != SelectedProfileType.company){
        canEdit = true;
      }
    }else if(loggedUserType == UserType.collaborator) {
      if(selectedProfileType == SelectedProfileType.user) {
        canEdit = true;
      }
    }

    bool canAddChild = false;
    if(loggedUserType == UserType.admin || loggedUserType == UserType.collaborator) {
      if(selectedProfileType != null && 
      selectedProfileType == SelectedProfileType.user){
        canAddChild = true;
      }
    }

    bool canLogout = false;
    if(loggedUserType == UserType.collaborator) {
      if(selectedProfileType != null && 
      widget.selectedCollaborator?.id == loggedCollaborator?.id){
        canLogout = true;
      }
    }

    bool canDelete = false;
    if(loggedUserType == UserType.admin) {
      if(selectedProfileType != null && 
      selectedProfileType != SelectedProfileType.company &&
      selectedProfileType != SelectedProfileType.admin){
        canDelete = true;
      }
    }
    // admin -> edita todos, exclui colaboradores, adiciona criança em usuario
    // colaborador -> editar apenas usuarios, cadastrar crianças em usuario, deslogar do proprio perfil

    return AppBar(
      title: Text(title),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                debugPrint('DebuggerLog: Perfil - editar selecionado');
                break;
              case 'add_child':
                debugPrint('DebuggerLog: Perfil - cadastrar criança selecionado');
                break;
              case 'delete':
                debugPrint('DebuggerLog: Perfil - excluir selecionado');
                break;
              case 'logout':
                debugPrint('DebuggerLog: Perfil - deslogar selecionado');
                _authController.logout();
                Navigator.pushNamedAndRemoveUntil(context, '/company_selection', (route) => false);
                break;
              default:
                break;
            }
          },
          itemBuilder: (context) => [
            if (canEdit) const PopupMenuItem(value: 'edit', child: Text('Editar')),
            if (canAddChild) const PopupMenuItem(value: 'add_child', child: Text('Cadastrar criança')),
            if (canLogout) const PopupMenuItem(value: 'logout', child: Text('Deslogar')),
            if (canDelete) const PopupMenuItem(value: 'delete', child: Text('Excluir (Admin)'))
          ],
        ),
      ],
    );
  }

  Widget _buildProfilePictureSection(BuildContext context) {
    String? name = widget.selectedUser?.name ?? widget.selectedCollaborator?.name ?? widget.selectedCompany?.fantasyName ?? 'A';
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          child: Text(
            getInitials(name),
            style: TextStyle(fontSize: 40, color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w600),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                debugPrint('DebuggerLog: UserProfileScreen.addPhoto tapped');
                // TODO: Implementar ação para adicionar foto
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.add_a_photo,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    String? name = widget.selectedUser?.name ?? widget.selectedCollaborator?.name ?? widget.selectedCompany?.fantasyName ?? 'name_placeholder';
    String? userType = widget.selectedUser != null ? 'Usuário' : 
      widget.selectedCompany != null ? 'Empresa' : widget.selectedCollaborator != null ? 
      (widget.selectedCollaborator?.userType == UserType.admin ? 'Administrador' : 
      widget.selectedCollaborator?.userType == UserType.collaborator ? 'Colaborador' : 'user_type_placeholder') :
      'user_type_placeholder';
    String? id;
    if (selectedProfileType == SelectedProfileType.user){
      id = widget.selectedUser?.id;
    }else if (selectedProfileType == SelectedProfileType.collaborator || selectedProfileType == SelectedProfileType.admin) {
      id = widget.selectedCollaborator?.id;
    } else if (selectedProfileType == SelectedProfileType.company) {
      id = widget.selectedCompany?.id;
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextHeaderMedium(name),
          const SizedBox(height: 8),
          TextHeaderSmall(userType,  style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          (id == null || id.isEmpty) ? const SizedBox.shrink() : 
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextBodyMedium('Id:'),
              const SizedBox(width: 8),
              TextBodyMedium(id, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              const SizedBox(width: 8),
              IconButton(
                alignment: Alignment.center,
                icon: Icon(Icons.copy, size: 14, color: Theme.of(context).colorScheme.primary),
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: id ?? ''));
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, String title, List<MapEntry<String, String>> entries) {
    final collapsed = _collapsedCards[title] ?? false;

    final firstRowWidget = entries.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _infoRow(entries.first.key, entries.first.value,
                valueStyle: entries.first.key == 'ID' ? TextStyle(color: Theme.of(context).colorScheme.primary) : null),
          );

    final fullListWidget = entries.isEmpty
        ? const SizedBox.shrink()
        : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final e = entries[index];
              return _infoRow(e.key, e.value,
                  valueStyle: e.key == 'ID' ? TextStyle(color: Theme.of(context).colorScheme.primary) : null);
            },
            separatorBuilder: (context, index) => const Divider(height: 1),
          );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: TextHeaderSmall(title)),
                IconButton(
                  icon: Icon(collapsed ? Icons.expand_more : Icons.expand_less),
                  onPressed: () => setState(() => _collapsedCards[title] = !collapsed),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedCrossFade(
              firstChild: firstRowWidget,
              secondChild: fullListWidget,
              crossFadeState: collapsed ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 220),
              firstCurve: Curves.easeInOut,
              secondCurve: Curves.easeInOut,
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChildrenCard(BuildContext context) {
    if (selectedProfileType != SelectedProfileType.user || widget.selectedUser == null) return const SizedBox.shrink();

    final List<Child> children = [];
    final service = ChildService();
    for (final cid in widget.selectedUser!.childrenIds ?? []) {
      final child = service.getChildById(cid);
      if (child != null) children.add(child);
    }

    final loggedType = _collaboratorController.loggedCollaborator?.userType;
    final canEditChild = loggedType == UserType.admin || loggedType == UserType.collaborator;
    final canDeleteChild = loggedType == UserType.admin;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(
                child: const Text(
                  'Crianças sob responsabilidade',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            if (children.isEmpty)
              Center(child: Text('Nenhuma criança cadastrada.', style: TextStyle(color: Theme.of(context).colorScheme.primary)))
            else
              Column(
                children: children.map((c) {
                  return Column(children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(c.name ?? ''),
                      subtitle: Text('${(c.isActive ?? false) ? 'Ativa' : 'Inativa'}${c.document != null && c.document!.isNotEmpty ? ' · ${c.document}' : ''}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (canEditChild)
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              onPressed: () {
                                debugPrint('DebuggerLog: ProfileScreen.editChild.tap -> childId=${c.id}');
                                // TODO: Implementar edição de criança (abrir modal)
                              },
                            ),
                          if (canDeleteChild)
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () {
                                debugPrint('DebuggerLog: ProfileScreen.deleteChild.tap -> childId=${c.id}');
                                // TODO: Implementar exclusão de criança
                              },
                            ),
                        ],
                      ),
                    ),
                    const Divider(height: 1),
                  ]);
                }).toList(),
              ),
          ]),
        ]),
      ),
    );
  }

  Widget _infoRow(String label, String value, {TextStyle? valueStyle}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextBodyMedium('$label:'),
          const SizedBox(width: 8),
          Expanded(child: TextBodyMedium(value, style: valueStyle)),
        ],
      ),
    );
  }

  Map<String, String> _getProfileData() {
    if (selectedProfileType == SelectedProfileType.user && widget.selectedUser != null) {
      final u = widget.selectedUser!;
      return {
        'Nome': u.name ?? '-',
        'Email': u.email ?? '-',
        'Data de Nascimento': u.birthDate ?? '-',
        'Telefone': u.phone ?? '-',
        'Documento': u.document ?? '-',
      };
    } else if ((selectedProfileType == SelectedProfileType.collaborator || selectedProfileType == SelectedProfileType.admin) && widget.selectedCollaborator != null) {
      final c = widget.selectedCollaborator!;
      return {
        'Nome': c.name ?? '-',
        'Email': c.email ?? '-',
        'Data de Nascimento': c.birthDate ?? '-',
        'Telefone': c.phone ?? '-',
        'Documento': c.document ?? '-',
      };
    } else if (selectedProfileType == SelectedProfileType.company && widget.selectedCompany != null) {
      final co = widget.selectedCompany!;
      return {
        'Nome': co.fantasyName ?? co.corporateName ?? '-',
        'CNPJ': co.cnpj ?? '-',
        'Site': co.website ?? '-',
        'Telefone': co.address ?? '-',
        'Endereço': '${co.address ?? '-'}${co.adressNumber != null ? ', ${co.adressNumber}' : ''}',
      };
    }
    return {};
  }

  Map<String, String> _getAddressData() {
    if (selectedProfileType == SelectedProfileType.user && widget.selectedUser != null) {
      final u = widget.selectedUser!;
      return {
        'Endereço': u.address ?? '-',
        'Número': u.adressNumber ?? '-',
        'Complemento': u.adressComplement ?? '-',
        'Bairro': u.neighborhood ?? '-',
        'Cidade': u.city ?? '-',
        'Estado': u.state ?? '-',
        'CEP': u.zipCode ?? '-',
      };
    } else if ((selectedProfileType == SelectedProfileType.collaborator || selectedProfileType == SelectedProfileType.admin) && widget.selectedCollaborator != null) {
      final c = widget.selectedCollaborator!;
      return {
        'Endereço': c.address ?? '-',
        'Número': c.adressNumber ?? '-',
        'Complemento': c.adressComplement ?? '-',
        'Bairro': c.neighborhood ?? '-',
        'Cidade': c.city ?? '-',
        'Estado': c.state ?? '-',
        'CEP': c.zipCode ?? '-',
      };
    } else if (selectedProfileType == SelectedProfileType.company && widget.selectedCompany != null) {
      final co = widget.selectedCompany!;
      return {
        'Endereço': co.address ?? '-',
        'Número': co.adressNumber ?? '-',
        'Complemento': co.adressComplement ?? '-',
        'Bairro': co.neighborhood ?? '-',
        'Cidade': co.city ?? '-',
        'Estado': co.state ?? '-',
        'CEP': co.zipCode ?? '-',
      };
    }
    return {};
  }
}