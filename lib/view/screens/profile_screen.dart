import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/user_controller.dart';
import 'package:kids_space/model/base_user.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/model/company.dart';
import 'package:kids_space/model/user.dart';
import 'package:kids_space/view/widgets/profile_picture_section.dart';
import 'package:kids_space/view/widgets/profile_header_section.dart';
import 'package:kids_space/view/widgets/profile_info_card_section.dart';
import 'package:kids_space/view/widgets/profile_children_card_section.dart';
import 'package:kids_space/view/widgets/profile_app_bar.dart';

enum SelectedProfileType {
  user,
  collaborator,
  admin,
  company
}

class _AppBarConfig {
  final String title;
  final bool canEdit;
  final bool canAddChild;
  final bool canLogout;
  final bool canDelete;

  _AppBarConfig({
    required this.title,
    required this.canEdit,
    required this.canAddChild,
    required this.canLogout,
    required this.canDelete,
  });
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
  final UserController _userController = GetIt.I<UserController>();
  final ChildController _childController = GetIt.I<ChildController>();
  final AuthController _authController = GetIt.I<AuthController>();

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

  _AppBarConfig _computeAppBarConfig() {
    String title = 'Perfil';
    if (selectedProfileType != null) {
      if (selectedProfileType == SelectedProfileType.user) {
        title = 'Perfil de ${widget.selectedUser?.name ?? 'user_placeholder'}';
      } else if (selectedProfileType == SelectedProfileType.collaborator || selectedProfileType == SelectedProfileType.admin) {
        title = 'Perfil de ${widget.selectedCollaborator?.name ?? 'collaborator_placeholder'}';
      } else if (selectedProfileType == SelectedProfileType.company) {
        title = 'Perfil de ${widget.selectedCompany?.fantasyName ?? widget.selectedCompany?.corporateName ?? 'company_placeholder'}';
      }
    }

    final loggedCollaborator = _collaboratorController.loggedCollaborator;
    final loggedUserType = loggedCollaborator?.userType;

    final bool canEdit = (loggedUserType == UserType.admin && selectedProfileType != null && selectedProfileType != SelectedProfileType.company) ||
        (loggedUserType == UserType.collaborator && selectedProfileType == SelectedProfileType.user);

    final bool canAddChild = (loggedUserType == UserType.admin || loggedUserType == UserType.collaborator) &&
        (selectedProfileType != null && selectedProfileType == SelectedProfileType.user);

    final bool canLogout = (loggedUserType == UserType.collaborator) &&
        (selectedProfileType != null && widget.selectedCollaborator?.id == loggedCollaborator?.id);

    final bool canDelete = (loggedUserType == UserType.admin) &&
        (selectedProfileType != null && selectedProfileType != SelectedProfileType.company && selectedProfileType != SelectedProfileType.admin);

    return _AppBarConfig(
      title: title,
      canEdit: canEdit,
      canAddChild: canAddChild,
      canLogout: canLogout,
      canDelete: canDelete,
    );
  }

  @override
  Widget build(BuildContext context) {

    final Map<String, String> infoMap = _getProfileData();
    final profileEntries = infoMap.entries.toList();
    final Map<String, String> addressMap = _getAddressData();
    final addressEntries = addressMap.entries.toList();

    final _AppBarConfig appBarConfig = _computeAppBarConfig();

    return Scaffold(
      appBar: ProfileAppBar(
        title: appBarConfig.title,
        canEdit: appBarConfig.canEdit,
        canAddChild: appBarConfig.canAddChild,
        canLogout: appBarConfig.canLogout,
        canDelete: appBarConfig.canDelete,
        onEdit: () {
          debugPrint('DebuggerLog: Perfil - editar selecionado');
        },
        onAddChild: () {
          debugPrint('DebuggerLog: Perfil - cadastrar criança selecionado');
        },
        onDelete: () async {
          switch(selectedProfileType) {
            case SelectedProfileType.user:
              if (widget.selectedUser != null) {
                if(await _userController.deleteUser(widget.selectedUser?.id ?? '')){
                  Navigator.pop(context);
                  debugPrint('DebuggerLog: Usuário excluído com sucesso');
                } else {
                  debugPrint('DebuggerLog: Falha ao excluir usuário');
                }
              }
              break;
            case SelectedProfileType.collaborator:
              if (widget.selectedCollaborator != null) {
                if(await _collaboratorController.deleteCollaborator(widget.selectedCollaborator?.id ?? '')){
                  Navigator.pop(context);
                  debugPrint('DebuggerLog: Colaborador excluído com sucesso');
                } else {
                  debugPrint('DebuggerLog: Falha ao excluir colaborador');
                }
              }
              break;
            default:
              break;
          }
          debugPrint('DebuggerLog: Perfil - excluir selecionado');
        },
        onLogout: () {
          debugPrint('DebuggerLog: Perfil - deslogar selecionado');
          _authController.logout();
          Navigator.pushNamedAndRemoveUntil(context, '/company_selection', (route) => false);
        },
      ),
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
                      // Profile picture
                      ProfilePictureSection(
                        name: widget.selectedUser?.name ?? 
                        widget.selectedCollaborator?.name ?? 
                        widget.selectedCompany?.fantasyName ?? '?',
                        onAddPhoto: () {
                          debugPrint('DebuggerLog: UserProfileScreen.addPhoto tapped');
                          // TODO: Implementar ação para adicionar foto
                        },
                      ),
                      const SizedBox(height: 16),
                      // Header
                      ProfileHeaderSection(
                        name: widget.selectedUser?.name ?? widget.selectedCollaborator?.name ?? widget.selectedCompany?.fantasyName ?? 'name_placeholder',
                        userTypeLabel: widget.selectedUser != null ? 'Usuário' : 
                          widget.selectedCompany != null ? 'Empresa' : widget.selectedCollaborator != null ? 
                          (widget.selectedCollaborator?.userType == UserType.admin ? 'Administrador' : 'Colaborador') : 'user_type_placeholder',
                        id: selectedProfileType == SelectedProfileType.user
                            ? widget.selectedUser?.id
                            : (selectedProfileType == SelectedProfileType.collaborator || selectedProfileType == SelectedProfileType.admin)
                                ? widget.selectedCollaborator?.id
                                : widget.selectedCompany?.id,
                      ),
                      const SizedBox(height: 16),
                      ProfileInfoCardSection(title: 'Dados pessoais', entries: profileEntries),
                      const SizedBox(height: 16),
                      ProfileInfoCardSection(title: 'Endereço', entries: addressEntries),
                      const SizedBox(height: 16),
                      if (selectedProfileType == SelectedProfileType.user) ProfileChildrenCardSection(user: widget.selectedUser),
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