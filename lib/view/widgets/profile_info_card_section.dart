import 'package:flutter/material.dart';

class ProfileInfoCardSection extends StatefulWidget {
  final String title;
  final List<MapEntry<String, String>> entries;
  final IconData? icon;

  const ProfileInfoCardSection({
    super.key,
    required this.title,
    required this.entries,
    this.icon,
  });

  @override
  State<ProfileInfoCardSection> createState() => _ProfileInfoCardSectionState();
}

class _ProfileInfoCardSectionState extends State<ProfileInfoCardSection> {
  bool _collapsed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final entries = widget.entries;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEF1F7)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ───────────────────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _collapsed = !_collapsed),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Row(
                children: [
                  if (widget.icon != null) ...[
                    Icon(widget.icon, size: 18, color: scheme.primary),
                    const SizedBox(width: 8),
                  ],
                  Expanded(
                    child: Text(
                      widget.title,
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F1218),
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _collapsed ? 0 : 0.5,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: const Color(0xFF9AA3B5),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Divisor ───────────────────────────────────────────────────────
          if (!_collapsed)
            const Divider(height: 1, color: Color(0xFFEEF1F7)),

          // ── Conteúdo ─────────────────────────────────────────────────────
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 200),
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
            sizeCurve: Curves.easeInOut,
            crossFadeState: _collapsed
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: const SizedBox.shrink(),
            secondChild: entries.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '—',
                      style: textTheme.bodyMedium?.copyWith(
                        color: const Color(0xFF9AA3B5),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: entries.indexed
                          .expand((item) {
                            final (i, e) = item;
                            return [
                              if (i > 0) const SizedBox(height: 12),
                              _InfoRow(label: e.key, value: e.value),
                            ];
                          })
                          .toList(),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: textTheme.bodySmall?.copyWith(
              color: const Color(0xFF9AA3B5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value.isEmpty ? '—' : value,
            style: textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF0F1218),
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
