import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/parent_controller.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/user_type.dart';
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
    // Listen to controllers so the profile view updates when underlying entities change
    _collaboratorController.addListener(_onControllersChanged);
    _userController.addListener(_onControllersChanged);
    _childController.addListener(_onControllersChanged);
    // If any entity is provided, attempt to refresh it from API and show skeleton while loading
    if (widget.selectedCompany != null && widget.selectedCompany!.id != null) {
      _company = widget.selectedCompany;
      setState(() {
        _isLoading = true;
      });
      _companyController
          .loadCompanyById(widget.selectedCompany!.id!)
          .then((_) {
            final fetched = _companyController.getCompanyById(
              widget.selectedCompany!.id!,
            );
            if (fetched != null && mounted) {
              setState(() {
                _company = fetched;
              });
            }
          })
          .whenComplete(() {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
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
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
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
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
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
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          });
      return;
    }
  }

  @override
  void dispose() {
    _collaboratorController.removeListener(_onControllersChanged);
    _userController.removeListener(_onControllersChanged);
    _childController.removeListener(_onControllersChanged);
    super.dispose();
  }

  void _onControllersChanged() {
    // If viewing a collaborator, try to update the fetched collaborator from controller cache
    try {
      if (widget.selectedCollaborator != null &&
          widget.selectedCollaborator!.id != null) {
        final id = widget.selectedCollaborator!.id!;
        try {
          final found = _collaboratorController.collaborators.firstWhere(
            (c) => c.id == id,
          );
          if (found != null) {
            setState(() {
              _fetchedCollaborator = found;
            });
            return;
          }
        } catch (_) {}
      }
      if (widget.selectedUser != null && widget.selectedUser!.id != null) {
        final id = widget.selectedUser!.id!;
        final found = _userController.getUserById(id);
        if (found != null) {
          setState(() {
            _fetchedUser = found;
          });
          return;
        }
      }
      if (widget.selectedChild != null && widget.selectedChild!.id != null) {
        final id = widget.selectedChild!.id!;
        final found = _childController.getChildById(id);
        if (found != null) {
          setState(() {
            _fetchedChild = found;
          });
          return;
        }
      }
    } catch (_) {}
  }

  _AppBarConfig _computeAppBarConfig() {
    String title = translate('profile.screen_title');
    if (selectedProfileType != null) {
      if (selectedProfileType == SelectedProfileType.user) {
        title = translate(
          'profile.profile_of',
          namedArgs: {
            'name_placeholder':
                widget.selectedUser?.name ??
                translate('profile.name_placeholder'),
          },
        );
      } else if (selectedProfileType == SelectedProfileType.collaborator ||
          selectedProfileType == SelectedProfileType.admin) {
        title = translate(
          'profile.profile_of',
          namedArgs: {
            'name_placeholder':
                widget.selectedCollaborator?.name ??
                translate('profile.name_placeholder'),
          },
        );
      } else if (selectedProfileType == SelectedProfileType.company) {
        title = translate(
          'profile.profile_of',
          namedArgs: {
            'name_placeholder':
                _effectiveCompany?.name ??
                _effectiveCompany?.legalName ??
                translate('profile.name_placeholder'),
          },
        );
      } else if (selectedProfileType == SelectedProfileType.child) {
        title = translate(
          'profile.profile_of',
          namedArgs: {
            'name_placeholder':
                widget.selectedChild?.name ??
                translate('profile.name_placeholder'),
          },
        );
      }
    }

    final loggedCollaborator = _collaboratorController.loggedCollaborator;
    final loggedUserType = loggedCollaborator?.userType;
    // Consider AuthController role as authoritative for company logins
    final loggedAsCompany =
        _authController.role.toString().toLowerCase().contains('company') ||
        loggedUserType == UserType.company;
    final loggedAsCollaborator =
        _authController.role.toString().toLowerCase().contains(
          'collaborator',
        ) ||
        loggedUserType == UserType.collaborator;

    final bool canEdit =
        // company users can edit non-company profiles
        (loggedAsCompany &&
            selectedProfileType != null &&
            selectedProfileType != SelectedProfileType.company) ||
        // company should be able to edit its own company profile when viewing its company
        (loggedAsCompany &&
            selectedProfileType == SelectedProfileType.company &&
            _effectiveCompany?.id != null &&
            _effectiveCompany?.id == _companyController.company?.id) ||
        (loggedAsCollaborator &&
            (selectedProfileType == SelectedProfileType.user ||
                selectedProfileType == SelectedProfileType.child));

    final bool canAddChild =
        (loggedAsCompany || loggedAsCollaborator) &&
        (selectedProfileType != null &&
            selectedProfileType == SelectedProfileType.user);

    final bool canLogout =
        // collaborator can logout when viewing their own collaborator profile
        (loggedAsCollaborator &&
            (selectedProfileType != null &&
                widget.selectedCollaborator?.id == loggedCollaborator?.id)) ||
        // company can logout when viewing their own company profile
        (loggedAsCompany &&
            (selectedProfileType == SelectedProfileType.company) &&
            _effectiveCompany?.id != null &&
            _effectiveCompany?.id == _companyController.company?.id);

    final bool canDelete =
        (loggedAsCompany) &&
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
        title: Text(translate('ui.confirm_delete_title')),
        content: Text(
          translate(
            'ui.confirm_delete_message',
            namedArgs: {'name': targetName},
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(translate('buttons.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(translate('profile.delete')),
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
      success = await _collaboratorController.deleteCollaborator(
        widget.selectedCollaborator?.id ?? '',
      );
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
          success ? translate('common.success') : translate('common.error'),
        ),
        content: Text(
          success
              ? translate(
                  'profile.delete_success',
                  namedArgs: {'name': targetName},
                )
              : translate(
                  'profile.delete_error',
                  namedArgs: {'name': targetName},
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(translate('buttons.ok')),
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
    // If viewing a company profile and logged as company, show company edit dialogs
    final loggedAsCompany =
        _authController.role.toString().toLowerCase().contains('company') ||
        _collaboratorController.loggedCollaborator?.userType ==
            UserType.company;
    if (selectedProfileType == SelectedProfileType.company && loggedAsCompany) {
      await _showCompanyEditDialogs();
      return;
    }

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

  Future<void> _showCompanyEditDialogs() async {
    final company = _effectiveCompany;
    if (company == null) return;

    final choice = await showModalBottomSheet<String?>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 16),
              Text(
                translate('profile.edit_user'),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Divider(),
              ListTile(
                leading: const Icon(Icons.business),
                title: Text(translate('profile.edit_personal')),
                onTap: () => Navigator.of(context).pop('personal'),
              ),
              ListTile(
                leading: const Icon(Icons.home),
                title: Text(translate('profile.edit_address')),
                onTap: () => Navigator.of(context).pop('address'),
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.red),
                title: Text(translate('buttons.cancel')),
                onTap: () => Navigator.of(context).pop(null),
              ),
            ],
          ),
        ),
      ),
    );

    if (choice == 'personal') {
      final fields = [
        FieldDefinition(
          key: 'name',
          label: translate('profile.fantasy_name'),
          initialValue: company.name ?? '',
        ),
        FieldDefinition(
          key: 'contact',
          label: translate('profile.phone'),
          type: FieldType.phone,
          initialValue: company.contact ?? '',
        ),
        FieldDefinition(
          key: 'website',
          label: translate('profile.website'),
          initialValue: company.website ?? '',
        ),
        FieldDefinition(
          key: 'logoUrl',
          label: translate('profile.logo_url'),
          initialValue: company.logoUrl ?? '',
        ),
      ];

      final res = await showEditEntityBottomSheet(
        context: context,
        title: translate('profile.edit_personal'),
        fields: fields,
      );
      if (res == null) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(translate('profile.confirm_change_title')),
          content: Text(translate('profile.confirm_change_personal')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(translate('buttons.cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(translate('buttons.confirm')),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      final payload = <String, dynamic>{
        'name': res['name']?.toString(),
        'contact': res['contact']?.toString(),
        'website': res['website']?.toString(),
        'logoUrl': res['logoUrl']?.toString(),
      };

      bool success = false;
      try {
        await _companyController.updateMyCompany(payload);
        success = true;
      } catch (_) {
        success = false;
      }

      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            success ? translate('common.success') : translate('common.error'),
          ),
          content: Text(
            success
                ? translate('company.update_success')
                : translate('company.update_error'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(translate('buttons.ok')),
            ),
          ],
        ),
      );
      if (success) setState(() => _company = _companyController.company);
    } else if (choice == 'address') {
      final fields = [
        FieldDefinition(
          key: 'addressStreet',
          label: translate('profile.address'),
          initialValue: company.address?.address ?? '',
        ),
        FieldDefinition(
          key: 'addressNumber',
          label: translate('profile.address_number'),
          initialValue: company.address?.number ?? '',
        ),
        FieldDefinition(
          key: 'addressComplement',
          label: translate('profile.address_complement'),
          initialValue: company.address?.complement ?? '',
        ),
        FieldDefinition(
          key: 'addressNeighborhood',
          label: translate('profile.neighborhood'),
          initialValue: company.address?.neighborhood ?? '',
        ),
        FieldDefinition(
          key: 'addressCity',
          label: translate('profile.city'),
          initialValue: company.address?.city ?? '',
        ),
        FieldDefinition(
          key: 'addressState',
          label: translate('profile.state'),
          initialValue: company.address?.state ?? '',
        ),
        FieldDefinition(
          key: 'addressZipcode',
          label: translate('profile.zip_code'),
          initialValue: company.address?.zipcode ?? '',
        ),
      ];

      final res = await showEditEntityBottomSheet(
        context: context,
        title: translate('profile.edit_address'),
        fields: fields,
      );
      if (res == null) return;

      final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(translate('profile.confirm_change_title')),
          content: Text(translate('profile.confirm_change_address')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(false),
              child: Text(translate('buttons.cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              child: Text(translate('buttons.confirm')),
            ),
          ],
        ),
      );
      if (confirmed != true) return;

      final payload = <String, dynamic>{
        'address': {
          'address': res['addressStreet']?.toString(),
          'number': res['addressNumber']?.toString(),
          'complement': res['addressComplement']?.toString(),
          'neighborhood': res['addressNeighborhood']?.toString(),
          'city': res['addressCity']?.toString(),
          'state': res['addressState']?.toString(),
          'zipcode': res['addressZipcode']?.toString(),
        },
      };

      bool success = false;
      try {
        await _companyController.updateMyCompany(payload);
        success = true;
      } catch (_) {
        success = false;
      }

      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(
            success ? translate('common.success') : translate('common.error'),
          ),
          content: Text(
            success
                ? translate('company.address_update_success')
                : translate('company.address_update_error'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text(translate('buttons.ok')),
            ),
          ],
        ),
      );
      if (success) setState(() => _company = _companyController.company);
    }
  }

  Future<void> _confirmAndLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(translate('ui.logout_confirm_title')),
        content: Text(translate('ui.logout_confirm_message')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(translate('buttons.cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(translate('ui.logout_button')),
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
        label: translate('profile.name'),
        initialValue: null,
        required: true,
      ),
      FieldDefinition(
        key: 'email',
        label: translate('profile.email'),
        type: FieldType.email,
        initialValue: null,
      ),
      FieldDefinition(
        key: 'birthDate',
        label: translate('profile.birth_date'),
        type: FieldType.date,
        initialValue: null,
      ),
      FieldDefinition(
        key: 'phone',
        label: translate('profile.phone'),
        type: FieldType.phone,
        initialValue: null,
      ),
      FieldDefinition(
        key: 'document',
        label: translate('profile.document'),
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
        title: Text(translate('profile.address_title')),
        content: Text(translate('ui.inherit_address_question')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(translate('ui.yes')),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(translate('ui.no')),
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
          label: translate('profile.address'),
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
          label: translate('profile.zip_code'),
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
