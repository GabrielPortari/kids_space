import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kids_space/view/design_system/app_text.dart';
import 'package:kids_space/util/localization_service.dart';

class ProfileHeaderSection extends StatelessWidget {
  final String name;
  final String userTypeLabel;
  final String? id;

  const ProfileHeaderSection({super.key, required this.name, required this.userTypeLabel, this.id});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          TextHeaderMedium(name),
          const SizedBox(height: 8),
          TextHeaderSmall(userTypeLabel, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          if (id != null && id!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextBodyMedium(translate('profile.id_label')),
                const SizedBox(width: 8),
                TextBodyMedium(id!, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
                const SizedBox(width: 8),
                IconButton(
                  alignment: Alignment.center,
                  icon: Icon(Icons.copy, size: 14, color: Theme.of(context).colorScheme.primary),
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: id ?? ''));
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(translate('ui.id_copied', namedArgs: {'id': id ?? ''}))));
                  },
                ),
              ],
            ),
          ]
        ],
      ),
    );
  }
}
