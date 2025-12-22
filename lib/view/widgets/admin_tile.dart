import 'package:flutter/material.dart';
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
          leading: CircleAvatar(child: Icon(model.icon, size: 20)),
          title: Text(title, overflow: TextOverflow.ellipsis),
          subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
