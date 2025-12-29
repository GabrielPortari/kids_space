import 'package:flutter/material.dart';
import 'package:kids_space/view/design_system/app_text.dart';
import '../../util/admin_tile_helpers.dart';
import '../../model/admin_tile_model.dart';

class AdminTile extends StatelessWidget {
  final AdminTileModel model;
  final VoidCallback? onTap;

  const AdminTile({Key? key, required this.model, this.onTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final title = titleForType(model.type);
    final subtitle = messageForType(model.type);

    return Card(
      clipBehavior: Clip.hardEdge,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          leading: CircleAvatar(
            backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
            child: Icon(model.icon, size: 24),),
          title: TextHeaderSmall(title),
          subtitle: TextBodyMedium(subtitle, maxLines: 2),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
