import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/parent_controller.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/view/widgets/edit_entity_bottom_sheet.dart';
import 'package:kids_space/view/widgets/profile_edit_helper.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/model/company.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/model/parent.dart';
import 'package:kids_space/view/widgets/profile_app_bar.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'profile_sections.dart';
import 'package:kids_space/util/localization_service.dart';

enum SelectedProfileType { child, user, collaborator, admin, company }

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
  final Parent? selectedUser;
  final Collaborator? selectedCollaborator;
  final Company? selectedCompany;
  final Child? selectedChild;

  const ProfileScreen({
    super.key,
    this.selectedUser,
    this.selectedCollaborator,
    this.selectedCompany,
    this.selectedChild,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final CollaboratorController _collaboratorController =
      GetIt.I<CollaboratorController>();
  final ParentController _userController = GetIt.I<ParentController>();
  final ChildController _childController = GetIt.I<ChildController>();
  final AuthController _authController = GetIt.I<AuthController>();
  final CompanyController _companyController = GetIt.I<CompanyController>();

  Company? _company;
  bool _isLoading = false;
  // fetched entities when opening profile
  Parent? _fetchedUser;
  Collaborator? _fetchedCollaborator;
  Child? _fetchedChild;

  SelectedProfileType? get selectedProfileType {
    if (widget.selectedUser != null) {
      return SelectedProfileType.user;
    } else if (widget.selectedCollaborator != null) {
      return widget.selectedCollaborator!.userType == UserType.company
          ? SelectedProfileType.admin
          : SelectedProfileType.collaborator;
    } else if (widget.selectedCompany != null) {
      return SelectedProfileType.company;
    } else if (widget.selectedChild != null) {
      return SelectedProfileType.child;
    }
    return null;
  }

  Company? get _effectiveCompany => _company ?? widget.selectedCompany;

  @override
  void initState() {
    super.initState();
    // If any entity is provided, attempt to refresh it from API and show skeleton while loading
    if (widget.selectedCompany != null && widget.selectedCompany!.id != null) {
      _company = widget.selectedCompany;
      setState(() {
        _isLoading = true;
      });
      _companyController
          .loadCompanyById(widget.selectedCompany!.id!)
          .then((fetched) {
            if (fetched != null && mounted) {
              setState(() {
                _company = fetched;
              });
            }
          })
          .whenComplete(() {
            if (mounted)
              setState(() {
                _isLoading = false;
              });
          });
      return;
    }

    if (widget.selectedUser != null && widget.selectedUser!.id != null) {
      _fetchedUser = widget.selectedUser;
      setState(() {
        _isLoading = true;
      });
      _userController
          .fetchUserById(widget.selectedUser!.id!)
          .then((fetched) {
            if (fetched != null && mounted) {
              setState(() {
                _fetchedUser = fetched;
              });
            }
          })
          .whenComplete(() {
            if (mounted)
              setState(() {
                _isLoading = false;
              });
          });
      return;
    }

    if (widget.selectedCollaborator != null &&
        widget.selectedCollaborator!.id != null) {
      _fetchedCollaborator = widget.selectedCollaborator;
      setState(() {
        _isLoading = true;
      });
      _collaboratorController
          .getCollaboratorById(widget.selectedCollaborator!.id!)
          .then((fetched) {
            if (fetched != null && mounted) {
              setState(() {
                _fetchedCollaborator = fetched;
              });
            }
          })
          .whenComplete(() {
            if (mounted)
              setState(() {
                _isLoading = false;
              });
          });
      return;
    }

    if (widget.selectedChild != null && widget.selectedChild!.id != null) {
      _fetchedChild = widget.selectedChild;
      setState(() {
        _isLoading = true;
      });
      _childController
          .fetchChildById(widget.selectedChild!.id!)
          .then((fetched) {
            if (fetched != null && mounted) {
              setState(() {
                _fetchedChild = fetched;
              });
            }
          })
          .whenComplete(() {
            if (mounted)
              setState(() {
                _isLoading = false;
              });
          });
      return;
    }
  }

  _AppBarConfig _computeAppBarConfig() {
    String title = translate('profile.screen_title', defaultText: 'Perfil');
    if (selectedProfileType != null) {
      if (selectedProfileType == SelectedProfileType.user) {
        title = translate(
          'profile.profile_of',
          defaultText: 'Perfil de {name_placeholder}',
          namedArgs: {
            'name_placeholder':
                widget.selectedUser?.name ??
                translate('profile.name_placeholder', defaultText: 'Nome'),
          },
        );
      } else if (selectedProfileType == SelectedProfileType.collaborator ||
          selectedProfileType == SelectedProfileType.admin) {
        title = translate(
          'profile.profile_of',
          defaultText: 'Perfil de {name_placeholder}',
          namedArgs: {
            'name_placeholder':
                widget.selectedCollaborator?.name ??
                translate('profile.name_placeholder', defaultText: 'Nome'),
          },
        );
      } else if (selectedProfileType == SelectedProfileType.company) {
        title = translate(
          'profile.profile_of',
          defaultText: 'Perfil de {name_placeholder}',
          namedArgs: {
            'name_placeholder':
                _effectiveCompany?.name ??
                _effectiveCompany?.legalName ??
                translate('profile.name_placeholder', defaultText: 'Nome'),
          },
        );
      } else if (selectedProfileType == SelectedProfileType.child) {
        title = translate(
          'profile.profile_of',
          defaultText: 'Perfil de {name_placeholder}',
          namedArgs: {
            'name_placeholder':
                widget.selectedChild?.name ??
                translate('profile.name_placeholder', defaultText: 'Nome'),
          },
        );
      }
    }

    final loggedCollaborator = _collaboratorController.loggedCollaborator;
    final loggedUserType = loggedCollaborator?.userType;

    final bool canEdit =
        (loggedUserType == UserType.company &&
            selectedProfileType != null &&
            selectedProfileType != SelectedProfileType.company) ||
        (loggedUserType == UserType.collaborator &&
            (selectedProfileType == SelectedProfileType.user ||
                selectedProfileType == SelectedProfileType.child));

    final bool canAddChild =
        (loggedUserType == UserType.company ||
            loggedUserType == UserType.collaborator) &&
        (selectedProfileType != null &&
            selectedProfileType == SelectedProfileType.user);

    final bool canLogout =
        (loggedUserType == UserType.collaborator) &&
        (selectedProfileType != null &&
            widget.selectedCollaborator?.id == loggedCollaborator?.id);

    final bool canDelete =
        (loggedUserType == UserType.company) &&
        (selectedProfileType != null &&
            selectedProfileType != SelectedProfileType.company &&
            selectedProfileType != SelectedProfileType.admin);

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
    final _AppBarConfig appBarConfig = _computeAppBarConfig();

    return Scaffold(
      appBar: ProfileAppBar(
        title: appBarConfig.title,
        canEdit: appBarConfig.canEdit,
        canAddChild: appBarConfig.canAddChild,
        canLogout: appBarConfig.canLogout,
        canDelete: appBarConfig.canDelete,
        onEdit: () {
          _showEditChoice();
        },
        onAddChild: () {
          _onAddChild();
        },
        onDelete: () async {
          await _confirmAndDelete();
        },
        onLogout: () async {
          await _confirmAndLogout();
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
                  child: _isLoading
                      ? _buildSkeleton()
                      : ProfileContent(
                          selectedUser: _fetchedUser ?? widget.selectedUser,
                          selectedCollaborator:
                              _fetchedCollaborator ??
                              widget.selectedCollaborator,
                          selectedCompany: _effectiveCompany,
                          selectedChild: _fetchedChild ?? widget.selectedChild,
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmAndDelete() async {
    final type = selectedProfileType;
    if (type != SelectedProfileType.user &&
        type != SelectedProfileType.collaborator &&
        type != SelectedProfileType.child)
      return;

    final targetName = type == SelectedProfileType.user
        ? 'este usuário'
        : type == SelectedProfileType.collaborator
        ? 'este colaborador'
        : type == SelectedProfileType.child
        ? 'esta criança'
        : 'profile_type_placeholder';

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          translate(
            'ui.confirm_delete_title',
            defaultText: 'Confirmar exclusão',
          ),
        ),
        content: Text(
          translate(
            'ui.confirm_delete_message',
            namedArgs: {'name': targetName},
            defaultText: 'Tem certeza que deseja excluir {name}?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(translate('buttons.cancel', defaultText: 'Cancelar')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(translate('profile.delete', defaultText: 'Excluir')),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    bool success = false;
    if (type == SelectedProfileType.user && widget.selectedUser != null) {
      success = await _userController.deleteUser(widget.selectedUser?.id ?? '');
    }
    if (type == SelectedProfileType.collaborator &&
        widget.selectedCollaborator != null) {
      // Deleting collaborators isn't provided by the current v2 controller/service.
      // Keep as not-supported here to avoid calling a missing API.
      success = false;
    }
    if (type == SelectedProfileType.child && widget.selectedChild != null) {
      success = await _childController.deleteChild(
        widget.selectedChild?.id ?? '',
      );
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          success
              ? translate('common.success', defaultText: 'Sucesso')
              : translate('common.error', defaultText: 'Erro'),
        ),
        content: Text(
          success
              ? translate(
                  'profile.delete_success',
                  namedArgs: {'name': targetName},
                  defaultText: 'Excluído com sucesso: {name}',
                )
              : translate(
                  'profile.delete_error',
                  namedArgs: {'name': targetName},
                  defaultText: 'Falha ao excluir: {name}',
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(translate('buttons.ok', defaultText: 'OK')),
          ),
        ],
      ),
    );

    if (success) Navigator.pop(context);
  }

  Widget _buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 16),
        Skeletonizer(
          enabled: true,
          child: CircleAvatar(
            radius: 48,
            backgroundColor: Colors.grey.shade300,
          ),
        ),
        const SizedBox(height: 16),
        Skeletonizer(
          enabled: true,
          child: Container(height: 24, width: 220, color: Colors.grey.shade300),
        ),
        const SizedBox(height: 16),
        Skeletonizer(
          enabled: true,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(height: 120),
          ),
        ),
        Skeletonizer(
          enabled: true,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(height: 120),
          ),
        ),
        Skeletonizer(
          enabled: true,
          child: Card(
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(height: 80),
          ),
        ),
      ],
    );
  }

  Future<void> _showEditChoice() async {
    await showProfileEditDialogs(
      context,
      user: widget.selectedUser,
      collaborator: widget.selectedCollaborator,
      child: widget.selectedChild,
      childController: _childController,
      userController: _userController,
      collaboratorController: _collaboratorController,
    );
  }

  Future<void> _confirmAndLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          translate('ui.logout_confirm_title', defaultText: 'Confirmar logout'),
        ),
        content: Text(
          translate(
            'ui.logout_confirm_message',
            defaultText: 'Deseja realmente sair do aplicativo?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(translate('buttons.cancel', defaultText: 'Cancelar')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(translate('ui.logout_button', defaultText: 'Sair')),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    _authController.logout();
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _onAddChild() async {
    final parent = widget.selectedUser;
    if (parent == null) return;

    // Step 1: get personal data
    final personalFields = [
      FieldDefinition(
        key: 'name',
        label: translate('profile.name', defaultText: 'Nome'),
        initialValue: null,
        required: true,
      ),
      FieldDefinition(
        key: 'email',
        label: translate('profile.email', defaultText: 'Email'),
        type: FieldType.email,
        initialValue: null,
      ),
      FieldDefinition(
        key: 'birthDate',
        label: translate(
          'profile.birth_date',
          defaultText: 'Data de nascimento',
        ),
        type: FieldType.date,
        initialValue: null,
      ),
      FieldDefinition(
        key: 'phone',
        label: translate('profile.phone', defaultText: 'Telefone'),
        type: FieldType.phone,
        initialValue: null,
      ),
      FieldDefinition(
        key: 'document',
        label: translate('profile.document', defaultText: 'Documento'),
        initialValue: null,
      ),
    ];

    final personalRes = await showEditEntityBottomSheet(
      context: context,
      title: 'Cadastrar criança - Dados pessoais',
      fields: personalFields,
    );
    if (personalRes == null) return;

    // Ask whether to inherit address
    final inherit = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          translate('profile.address_title', defaultText: 'Endereço'),
        ),
        content: Text(
          translate(
            'ui.inherit_address_question',
            defaultText: 'Deseja herdar o endereço?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(translate('ui.yes', defaultText: 'Sim')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(translate('ui.no', defaultText: 'Não')),
          ),
        ],
      ),
    );
    if (inherit == null) return;

    Map<String, dynamic>? addressRes;
    if (inherit == false) {
      final addressFields = [
        FieldDefinition(
          key: 'address',
          label: translate('profile.address', defaultText: 'Endereço'),
          initialValue: null,
        ),
        FieldDefinition(
          key: 'addressNumber',
          label: 'Número',
          initialValue: null,
        ),
        FieldDefinition(
          key: 'addressComplement',
          label: 'Complemento',
          initialValue: null,
        ),
        FieldDefinition(key: 'neighborhood', label: 'Bairro', initialValue: ''),
        FieldDefinition(key: 'city', label: 'Cidade', initialValue: null),
        FieldDefinition(key: 'state', label: 'Estado', initialValue: null),
        FieldDefinition(
          key: 'zipCode',
          label: translate('profile.zip_code', defaultText: 'CEP'),
          initialValue: null,
        ),
      ];
      addressRes = await showEditEntityBottomSheet(
        context: context,
        title: 'Cadastrar criança - Endereço',
        fields: addressFields,
      );
      if (addressRes == null) return;
    }

    // Build payload for v2 API
    final Map<String, dynamic> payload = {
      'name': personalRes['name']?.toString(),
      'email': personalRes['email']?.toString(),
      'document': personalRes['document']?.toString(),
      'contact': personalRes['phone']?.toString(),
      'parents': [parent.id],
      'companyId': parent.companyId,
    };

    if (inherit == false && addressRes != null) {
      payload['address'] = {
        'address': addressRes['address']?.toString(),
        'number': addressRes['addressNumber']?.toString(),
        'complement': addressRes['addressComplement']?.toString(),
        'neighborhood': addressRes['neighborhood']?.toString(),
        'city': addressRes['city']?.toString(),
        'state': addressRes['state']?.toString(),
        'zipcode': addressRes['zipCode']?.toString(),
      };
    }

    bool success = false;
    try {
      final created = await _childController.createChild(payload);
      success = created.id != null;
    } catch (_) {
      success = false;
    }

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(success ? 'Sucesso' : 'Erro'),
        content: Text(
          success
              ? 'Criança cadastrada com sucesso.'
              : 'Falha ao cadastrar criança.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (success) Navigator.of(context).pop();
  }
}
