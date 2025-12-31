import 'package:flutter/material.dart';
import 'package:kids_space/view/design_system/app_text.dart';

class ProfileInfoCardSection extends StatefulWidget {
  final String title;
  final List<MapEntry<String, String>> entries;

  const ProfileInfoCardSection({super.key, required this.title, required this.entries});

  @override
  State<ProfileInfoCardSection> createState() => _ProfileInfoCardSectionState();
}

class _ProfileInfoCardSectionState extends State<ProfileInfoCardSection> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final entries = widget.entries;

    final firstRowWidget = entries.isEmpty
        ? const SizedBox.shrink()
        : Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _InfoRow(entries.first.key, entries.first.value,
                valueStyle: entries.first.key == 'ID' ? TextStyle(color: Theme.of(context).colorScheme.primary) : null),
          );

    final fullListWidget = entries.isEmpty
        ? const SizedBox.shrink()
        : ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: entries.length,
            itemBuilder: (context, index) {
              final e = entries[index];
              return _InfoRow(e.key, e.value,
                  valueStyle: e.key == 'ID' ? TextStyle(color: Theme.of(context).colorScheme.primary) : null);
            },
            separatorBuilder: (context, index) => const Divider(height: 1),
          );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: TextHeaderSmall(widget.title)),
                IconButton(
                  icon: Icon(_collapsed ? Icons.expand_more : Icons.expand_less),
                  onPressed: () => setState(() => _collapsed = !_collapsed),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AnimatedCrossFade(
              firstChild: firstRowWidget,
              secondChild: fullListWidget,
              crossFadeState: _collapsed ? CrossFadeState.showFirst : CrossFadeState.showSecond,
              duration: const Duration(milliseconds: 220),
              firstCurve: Curves.easeInOut,
              secondCurve: Curves.easeInOut,
              sizeCurve: Curves.easeInOut,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final TextStyle? valueStyle;

  const _InfoRow(this.label, this.value, {this.valueStyle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 8, 0, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          TextBodyMedium('$label:'),
          const SizedBox(width: 8),
          Expanded(child: TextBodyMedium(value, style: valueStyle)),
        ],
      ),
    );
  }
}
