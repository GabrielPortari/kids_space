import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kids_space/util/localization_service.dart';

class ProfileHeaderSection extends StatelessWidget {
  final String name;
  final String userTypeLabel;
  final String? id;

  const ProfileHeaderSection({
    super.key,
    required this.name,
    required this.userTypeLabel,
    this.id,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Column(
      children: [
        // Nome
        Text(
          name,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F1218),
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),

        // Badge de tipo de usuário
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            userTypeLabel,
            style: textTheme.labelMedium?.copyWith(
              color: scheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        // ID copiável (compacto, discreto)
        if (id != null && id!.isNotEmpty) ...[
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: id!));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      translate('ui.id_copied', namedArgs: {'id': id!}),
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.tag_rounded,
                  size: 12,
                  color: const Color(0xFF9AA3B5),
                ),
                const SizedBox(width: 4),
                Text(
                  id!.length > 16
                      ? '${id!.substring(0, 8)}…${id!.substring(id!.length - 4)}'
                      : id!,
                  style: textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF9AA3B5),
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.copy_rounded,
                  size: 12,
                  color: const Color(0xFF9AA3B5),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
