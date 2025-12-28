import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter/services.dart';
import 'package:kids_space/controller/auth_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/view/design_system/app_card.dart';
import 'package:kids_space/view/design_system/app_button.dart';
import 'package:kids_space/view/design_system/app_text.dart';
import 'package:kids_space/view/design_system/app_textfield.dart';

final AuthController authController = GetIt.I<AuthController>();
final CollaboratorController _collaboratorController =
    GetIt.I<CollaboratorController>();

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    debugPrint('DebuggerLog: ProfileScreen.initState');
  }

  bool _fabOpen = false;

  @override
  Widget build(BuildContext context) {
    debugPrint('DebuggerLog: ProfileScreen.build');
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 720),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Observer(
                  builder: (_) {
                    final displayed = _collaboratorController.selectedCollaborator ?? _collaboratorController.loggedCollaborator;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 24),
                        _collaboratorProfileInfo(displayed),
                        const SizedBox(height: 24),
                        TextHeaderMedium(displayed != null ? displayed.name : 'Nome do Colaborador'),
                        const SizedBox(height: 8),
                        TextHeaderSmall('Colaborador'),
                        const SizedBox(height: 24),
                        _collaboratorProfileCard(displayed),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (_fabOpen) ...[
            Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(6),
                      boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                    ),
                    child: const Text('Editar perfil', style: TextStyle(fontSize: 14, color: Colors.black)),
                  ),
                  FloatingActionButton(
                    heroTag: 'collab_edit_fab',
                    onPressed: () {
                      debugPrint('DebuggerLog: ProfileScreen.editFab.tap');
                      _onEditProfile();
                      setState(() => _fabOpen = false);
                    },
                    child: const Icon(Icons.edit),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Logout button: hide if logged user is admin
            if ((_collaboratorController.loggedCollaborator != null && 
            _collaboratorController.loggedCollaborator?.id == _collaboratorController.selectedCollaborator?.id &&
            _collaboratorController.loggedCollaborator?.userType != UserType.admin)) ...[
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: const Text('Deslogar', style: TextStyle(fontSize: 14, color: Colors.black)),
                    ),
                    FloatingActionButton(
                      heroTag: 'collab_logout_fab',
                      onPressed: () {
                        debugPrint('DebuggerLog: ProfileScreen.logoutFab.tap');
                        _onLogout();
                        setState(() => _fabOpen = false);
                      },
                      child: const Icon(Icons.logout),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],

            // Delete button for any logged collaborator
            if (_collaboratorController.loggedCollaborator != null && _collaboratorController.loggedCollaborator!.userType == UserType.admin) ...[
              Align(
                alignment: Alignment.centerRight,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      margin: const EdgeInsets.only(right: 8),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                      ),
                      child: const Text('Excluir', style: TextStyle(fontSize: 14, color: Colors.black)),
                    ),
                    FloatingActionButton(
                      backgroundColor: Colors.red,
                      heroTag: 'collab_delete_fab',
                      onPressed: () async {
                        setState(() => _fabOpen = false);
                        // TODO : Implementar exclusão de colaborador
                      },
                      child: const Icon(Icons.delete),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
            ],
          ],
          FloatingActionButton(
            heroTag: 'collab_main_fab',
            onPressed: () {
              setState(() => _fabOpen = !_fabOpen);
              debugPrint('DebuggerLog: ProfileScreen.fab toggled -> $_fabOpen');
            },
            child: Icon(_fabOpen ? Icons.close : Icons.menu),
          ),
        ],
      ),
    );
  }



  _collaboratorProfileInfo(Collaborator? displayed) {
    return Stack(
      alignment: Alignment.center,
      children: [
        CircleAvatar(
          radius: 50,
          backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
          child: const Icon(Icons.person, size: 60),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                debugPrint('DebuggerLog: ProfileScreen.addPhoto tapped');
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

  _collaboratorProfileCard(Collaborator? displayed) {
    return AppCard(
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextBodyMedium('Nome:'),
              const SizedBox(width: 8),
              TextBodyMedium(displayed != null ? displayed.name : 'Nome do Colaborador'),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextBodyMedium('Email:'),
              const SizedBox(width: 8),
              TextBodyMedium(displayed != null ? displayed.email : 'email@placeholder.com'),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextBodyMedium('Telefone:'),
              const SizedBox(width: 8),
              TextBodyMedium(displayed != null && displayed.phoneNumber != null ? displayed.phoneNumber! : '(11) 1234 5678'),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  TextBodyMedium('ID:'),
                  const SizedBox(width: 8),
                  SizedBox(
                    width: 200,
                    child: TextBodyMedium(displayed != null ? displayed.id : 'ID do Colaborador'),
                  ),
                ],
              ),
              const SizedBox(width: 8),
              InkWell(
                onTap: () async {
                  final id = displayed?.id ?? '';
                  debugPrint('DebuggerLog: ProfileScreen.copyId tapped -> $id');
                  if (id.isNotEmpty) {
                    await Clipboard.setData(ClipboardData(text: id));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('ID copiado para a área de transferência!')));
                  }
                },
                child: const Padding(
                  padding: EdgeInsets.all(4.0),
                  child: Icon(Icons.copy, size: 18, color: Colors.grey),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  _onEditProfile() {
    return showDialog(
      context: context,
      builder: (context) {
        debugPrint('DebuggerLog: ProfileScreen.openEditDialog -> collaboratorId=${_collaboratorController.loggedCollaborator?.id ?? 'none'}');
        final nameController = TextEditingController(text: _collaboratorController.loggedCollaborator?.name ?? '');
        final emailController = TextEditingController(text: _collaboratorController.loggedCollaborator?.email ?? '');
        final phoneController = TextEditingController(text: _collaboratorController.loggedCollaborator?.phoneNumber ?? '');
        return AlertDialog(
          title: TextHeaderSmall('Editar perfil'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(controller: nameController, labelText: 'Nome'),
                const SizedBox(height: 12),
                AppTextField(controller: emailController, labelText: 'Email'),
                const SizedBox(height: 12),
                AppTextField(controller: phoneController, labelText: 'Telefone'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                debugPrint('DebuggerLog: ProfileScreen.editDialog.cancel');
                Navigator.pop(context);
              },
              child: TextButtonLabel('Cancelar'),
            ),
            AppButton(
              text: 'Salvar',
              onPressed: () {
                debugPrint('DebuggerLog: ProfileScreen.saveProfile -> name=${nameController.text}, email=${emailController.text}, phone=${phoneController.text}');
                // TODO: Salvar alterações (persistir via _collaboratorController)
                Navigator.pop(context);
              }
            ),
          ],
        );
      },
    );
  }

  _onLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sair'),
        content: const Text('Deseja deslogar o usuário?'),
        actions: [
          TextButton(
            onPressed: () {
              debugPrint('DebuggerLog: ProfileScreen.logout.cancel');
              Navigator.pop(context);
            },
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              debugPrint('DebuggerLog: ProfileScreen.logout.confirm');
              authController.logout();
              Navigator.of(context).pushNamedAndRemoveUntil('/company_selection', (route) => false);
            },
            child: const Text('Deslogar'),
          ),
        ],
      ),
    );
  }
}
