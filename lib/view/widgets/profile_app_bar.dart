import 'package:flutter/material.dart';
import 'package:kids_space/util/localization_service.dart';

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
            if (canEdit) PopupMenuItem(value: 'edit', child: Text(translate('ui.profile_menu.edit'))),
            if (canAddChild) PopupMenuItem(value: 'add_child', child: Text(translate('ui.profile_menu.add_child'))),
            if (canLogout) PopupMenuItem(value: 'logout', child: Text(translate('ui.profile_menu.logout'))),
            if (canDelete) PopupMenuItem(value: 'delete', child: Text(translate('ui.profile_menu.delete'))),
          ],
        ),
      ],
    );
  }
}
