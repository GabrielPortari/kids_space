import 'package:flutter/material.dart';

class ProfileAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool canEdit;
  final bool canAddChild;
  final bool canLogout;
  final bool canDelete;
  final VoidCallback? onEdit;
  final VoidCallback? onAddChild;
  final VoidCallback? onDelete;
  final VoidCallback? onLogout;

  const ProfileAppBar({
    super.key,
    required this.title,
    this.canEdit = false,
    this.canAddChild = false,
    this.canLogout = false,
    this.canDelete = false,
    this.onEdit,
    this.onAddChild,
    this.onDelete,
    this.onLogout,
  });

  @override
  Size get preferredSize => AppBar().preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      actions: [
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            switch (value) {
              case 'edit':
                if (onEdit != null) onEdit!();
                break;
              case 'add_child':
                if (onAddChild != null) onAddChild!();
                break;
              case 'delete':
                if (onDelete != null) onDelete!();
                break;
              case 'logout':
                if (onLogout != null) onLogout!();
                break;
              default:
                break;
            }
          },
          itemBuilder: (context) => [
            if (canEdit) const PopupMenuItem(value: 'edit', child: Text('Editar')),
            if (canAddChild) const PopupMenuItem(value: 'add_child', child: Text('Cadastrar criança')),
            if (canLogout) const PopupMenuItem(value: 'logout', child: Text('Deslogar')),
            if (canDelete) const PopupMenuItem(value: 'delete', child: Text('Excluir (Admin)')),
          ],
        ),
      ],
    );
  }
}
