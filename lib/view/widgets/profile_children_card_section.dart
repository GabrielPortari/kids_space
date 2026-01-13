import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/model/base_user.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/user.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/view/widgets/profile_edit_helper.dart';


class ProfileChildrenCardSection extends StatefulWidget {
  final User? user;

  const ProfileChildrenCardSection({super.key, this.user});

  @override
  State<ProfileChildrenCardSection> createState() => _ProfileChildrenCardSectionState();
}

class _ProfileChildrenCardSectionState extends State<ProfileChildrenCardSection> {
  final CollaboratorController _collaboratorController = GetIt.I<CollaboratorController>();
  final ChildController _childController = GetIt.I.get<ChildController>();
  final List<Child> _children = [];
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  @override
  void didUpdateWidget(covariant ProfileChildrenCardSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.user?.id != widget.user?.id) {
      _loadChildren();
    }
  }

  void _loadChildren() {
    _children.clear();
    for (final cId in widget.user?.childrenIds ?? []) {
      final child = _childController.getChildById(cId);
      if (child != null) _children.add(child);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final loggedType = _collaboratorController.loggedCollaborator?.userType;
    final canEditChild = loggedType == UserType.admin || loggedType == UserType.collaborator;
    final canDeleteChild = loggedType == UserType.admin;

    final header = Row(children: [
      Expanded(
        child: const Text(
          'Crianças sob responsabilidade',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      IconButton(
        icon: Icon(_collapsed ? Icons.expand_more : Icons.expand_less),
        onPressed: () => setState(() => _collapsed = !_collapsed),
      ),
    ]);

    final firstChildWidget = _children.isEmpty
        ? Center(child: Text('Nenhuma criança cadastrada.', style: TextStyle(color: Theme.of(context).colorScheme.primary)))
        : ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(_children.first.name ?? ''),
            subtitle: Text('${(_children.first.isActive ?? false) ? 'Ativa' : 'Inativa'}${_children.first.document != null && _children.first.document!.isNotEmpty ? ' · ${_children.first.document}' : ''}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              if (canEditChild)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () async {
                    debugPrint('DebuggerLog: ProfileChildrenCardSection.editChild.tap -> childId=${_children.first.id}');
                    await _editChild(_children.first);
                  },
                ),
              if (canDeleteChild)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () async {
                    debugPrint('DebuggerLog: ProfileChildrenCardSection.deleteChild.tap -> childId=${_children.first.id}');
                    await _deleteChild(_children.first);
                  },
                ),
            ]),
          );

    final fullListWidget = _children.isEmpty
        ? Center(child: Text('Nenhuma criança cadastrada.', style: TextStyle(color: Theme.of(context).colorScheme.primary)))
        : Column(
            children: _children.map((c) {
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
                          onPressed: () async {
                            debugPrint('DebuggerLog: ProfileChildrenCardSection.editChild.tap -> childId=${c.id}');
                            await _editChild(c);
                          },
                        ),
                      if (canDeleteChild)
                        IconButton(
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () async {
                            debugPrint('DebuggerLog: ProfileChildrenCardSection.deleteChild.tap -> childId=${c.id}');
                            await _deleteChild(c);
                          },
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
              ]);
            }).toList(),
          );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          header,
          const SizedBox(height: 12),
          AnimatedCrossFade(
            firstChild: firstChildWidget,
            secondChild: fullListWidget,
            crossFadeState: _collapsed ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            duration: const Duration(milliseconds: 220),
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
            sizeCurve: Curves.easeInOut,
          ),
        ]),
      ),
    );
  }
  Future<void> _editChild(Child? c) async {
    final success = await showChildEditDialogs(context, child: c, childController: _childController);
    if (success == true) {
      final updated = await Future.value(_childController.getChildById(c?.id ?? ''));
      final idx = _children.indexWhere((e) => e.id == c?.id);
      if (idx != -1 && updated != null) {
        _children[idx] = updated;
        setState(() {});
      } else {
        // fallback: reload full list
        _loadChildren();
      }
    }
  }

  Future<void> _deleteChild(Child c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Deseja realmente excluir esta criança?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Excluir')),
        ],
      ),
    );
    if (confirm != true) return;

    final success = await _childController.deleteChild(c.id ?? '');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(success ? 'Sucesso' : 'Erro'),
        content: Text(success ? 'Criança excluída com sucesso.' : 'Falha ao excluir criança.'),
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK'))],
      ),
    );

    if (success) {
      setState(() {});
    }
  }
}
