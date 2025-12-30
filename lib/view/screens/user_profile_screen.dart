import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/user_controller.dart';
import 'package:kids_space/model/base_user.dart';
import 'package:kids_space/model/user.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/service/child_service.dart';
import 'package:kids_space/util/string_utils.dart';
import 'package:kids_space/view/design_system/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kids_space/view/widgets/edit_entity_bottom_sheet.dart';
import 'package:mobx/mobx.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final UserController _userController = GetIt.I<UserController>();
  final ObservableList<Child> responsibleChildren = ObservableList<Child>();
  String? _lastUserId;
  bool _fabOpen = false;

  @override
  void initState() {
    super.initState();
    debugPrint('DebuggerLog: UserProfileScreen.initState');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil do Usuário'),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Observer(builder: (_) {
                  final user = _userController.selectedUser;
                  if (user?.id != _lastUserId) {
                    _lastUserId = user?.id;
                    _loadResponsibleChildren(user);
                  }
                  debugPrint('DebuggerLog: UserProfileScreen.build selectedUserId=${user?.id ?? 'none'}');
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        _buildAvatarSection(user),
                        const SizedBox(height: 24),
                        _buildHeaderSection(user),
                        const SizedBox(height: 24),
                        _buildInfoCard(user),
                        const SizedBox(height: 24),
                        _buildChildrenCard(),
                        const SizedBox(height: 48),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFabColumn(),
    );
  }

  Widget _buildAvatarSection(User? user) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
          child: Text(
            getInitials(user?.name),
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

  Widget _buildHeaderSection(User? user) {
    return Column(
      children: [
        Text(
          user?.name ?? 'Nome não encontrado',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'Usuário',
          style: TextStyle(fontSize: 18, color: Theme.of(context).colorScheme.primary),
        ),
      ],
    );
  }

  Widget _buildInfoCard(User? user) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Nome:', user?.name ?? '-'),
            const Divider(),
            _infoRow('Email:', user?.email ?? '-'),
            const Divider(),
            _infoRow('Telefone:', user?.phone ?? '-'),
            const Divider(),
            _infoRow('Documento:', user?.document ?? '-'),
            const Divider(),
            _infoRow('ID:', user?.id ?? '-', valueStyle: const TextStyle(fontSize: 16, color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {TextStyle? valueStyle}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 16)),
        const SizedBox(width: 8),
        Text(value, style: valueStyle ?? const TextStyle(fontSize: 16)),
      ],
    );
  }

  Widget _buildChildrenCard() {
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
            if (responsibleChildren.isEmpty)
              const Text('Você não possui crianças cadastradas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))
            else
              Column(
                children: responsibleChildren.map((c) {
                  return Column(children: [
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(c.name ?? ''),
                      subtitle: Text('${(c.isActive ?? false) ? 'Ativa' : 'Inativa'}${c.document != null && c.document!.isNotEmpty ? ' · ${c.document}' : ''}'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit_outlined),
                            onPressed: () async {
                              _onRegisterChild(isEdit: true, child: c);
                              debugPrint('DebuggerLog: UserProfileScreen.editChild.tap -> childId=${c.id}');
                            },
                          ),
                          if (GetIt.I<CollaboratorController>().loggedCollaborator?.userType == UserType.admin)
                            IconButton(
                              icon: const Icon(Icons.delete_outline, color: danger),
                              onPressed: () {
                                debugPrint('DebuggerLog: UserProfileScreen.deleteChild.tap -> childId=${c.id}');
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

  Widget _buildFabColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (_fabOpen) ...[
          Align(
            alignment: Alignment.centerRight,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(6), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                child: const Text('Editar perfil', style: TextStyle(fontSize: 14, color: Colors.black)),
              ),
              FloatingActionButton(
                heroTag: 'edit_fab',
                onPressed: () {
                  debugPrint('DebuggerLog: UserProfileScreen.editFab.tap');
                  _onEditProfile();
                  setState(() => _fabOpen = false);
                },
                child: const Icon(Icons.edit),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(6), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                child: const Text('Cadastrar criança', style: TextStyle(fontSize: 14, color: Colors.black)),
              ),
              FloatingActionButton(
                heroTag: 'add_child_fab',
                onPressed: () {
                  debugPrint('DebuggerLog: UserProfileScreen.addChildFab.tap');
                  _onRegisterChild(isEdit: false);
                  setState(() => _fabOpen = false);
                },
                child: const Icon(Icons.child_care),
              ),
            ]),
          ),
          const SizedBox(height: 8),
          if(GetIt.I<CollaboratorController>().loggedCollaborator?.userType == UserType.admin)
            Align(
              alignment: Alignment.centerRight,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.circular(6), boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)]),
                  child: const Text('Excluir usuário', style: TextStyle(fontSize: 14, color: Colors.black)),
                ),
                FloatingActionButton(
                  heroTag: 'exclude_user_fab',
                  onPressed: () {
                    debugPrint('DebuggerLog: UserProfileScreen.excludeUserFab.tap');
                    setState(() => _fabOpen = false);
                  },
                  child: const Icon(Icons.delete_outline),
                ),
              ]),
            ),
            const SizedBox(height: 8),
        ],
        FloatingActionButton(
          heroTag: 'main_fab',
          onPressed: () {
            setState(() => _fabOpen = !_fabOpen);
            debugPrint('DebuggerLog: UserProfileScreen.fab toggled -> $_fabOpen');
          },
          child: Icon(_fabOpen ? Icons.close : Icons.menu),
        ),
      ],
    );
  }
 

  void _loadResponsibleChildren(User? user) {
    debugPrint('DebuggerLog: UserProfileScreen._loadResponsibleChildren for userId=${user?.id ?? 'none'}');
    responsibleChildren.clear();
    if (user == null) return;
    final service = ChildService();
    for (final cid in user.childrenIds ?? []) {
      final child = service.getChildById(cid);
      if (child != null) responsibleChildren.add(child);
    }
  }

  Future<void> _onEditProfile() async {
    final user = _userController.selectedUser;

    debugPrint('DebuggerLog: UserProfileScreen.openEditDialog -> userId=${user?.id ?? 'none'}');

    final fields = [
      FieldDefinition(key: 'name', label: 'Nome', initialValue: user?.name, required: true),
      FieldDefinition(key: 'email', label: 'Email', initialValue: user?.email, required: true),
      FieldDefinition(key: 'phone', label: 'Telefone', initialValue: user?.phone, required: true),
      FieldDefinition(key: 'document', label: 'Documento', initialValue: user?.document, required: true),
    ];

    final result = await showEditEntityBottomSheet(context: context, title: 'Editar usuário', fields: fields);

    if (result != null) {
      debugPrint('DebuggerLog: UsersScreen.editModal.result -> $result');
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Usuário não encontrado')));
        return;
      }

      debugPrint('DebuggerLog: UserProfileScreen.saveProfile -> name=${result['name']}, email=${result['email']}, phone=${result['phone']}');
      final updated = User(
        id: user.id,
        name: result['name'].trim(),
        email: result['email'].trim(),
        phone: result['phone'].trim(),
        document: user.document,
        companyId: user.companyId,
        childrenIds: user.childrenIds, 
        createdAt: user.createdAt, 
        updatedAt: user.updatedAt,
      );
      _userController.updateUser(updated);
    }
  }

  Future<void> _onRegisterChild({bool isEdit = false, Child? child}) async {

    final user = _userController.selectedUser;
    debugPrint('DebuggerLog: UserProfileScreen._onRegisterChild -> userId=${user?.id ?? 'none'}');

    final fields = [
      FieldDefinition(key: 'name', label: 'Nome', initialValue: isEdit ? child?.name : null, required: true),
      FieldDefinition(key: 'document', label: 'Documento', initialValue: isEdit ? child?.document : null, required: true),
    ];

    final result = await showEditEntityBottomSheet(context: context, title: isEdit ? 'Editar criança' : 'Adicionar criança', fields: fields);
    
    if (result != null) {
      debugPrint('DebuggerLog: UserProfileScreen._onRegisterChild.result -> $result');
      final id = isEdit ? child!.id : DateTime.now().millisecondsSinceEpoch.toString();
      final childModel = Child(
        id: id,
        name: result['name'].trim(),
        companyId: user?.companyId ?? '',
        responsibleUserIds: [user?.id ?? ''],
        document: result['document'].trim().isEmpty
            ? null
            : result['document'].trim(),
        isActive: isEdit ? (child?.isActive ?? false) : true,
        createdAt: isEdit ? child?.createdAt ?? DateTime.parse('1969-07-20 20:18:04Z') : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      debugPrint('DebuggerLog: UserProfileScreen._onRegisterChild -> id=$id name=${childModel.name} responsible=${user?.id}');
      
      setState(() {
        ChildService().addChild(childModel);
      });
      debugPrint('DebuggerLog: UserProfileScreen._onRegisterChild -> id=${childModel.id}, name=${childModel.name}');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEdit ? 'Criança atualizada' : 'Criança cadastrada')));
    }
  }
}
