import 'package:flutter/material.dart';
import 'package:kids_space/view/design_system/app_text.dart';
import '../../util/company_tile_helpers.dart';
import '../../model/company_tile_model.dart';

class CompanyTile extends StatelessWidget {
  final CompanyTileModel model;
  final VoidCallback? onTap;

  const CompanyTile({super.key, required this.model, this.onTap});

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
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12.0,
            vertical: 8.0,
          ),
          leading: CircleAvatar(
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withValues(alpha: 0.2),
            child: Icon(model.icon, size: 24),
          ),
          title: TextHeaderSmall(title),
          subtitle: TextBodyMedium(subtitle, maxLines: 2),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }
}
