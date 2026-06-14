import 'package:flutter/material.dart';
import 'package:kids_space/model/child_health_info.dart';
import 'package:kids_space/util/localization_service.dart';

class ProfileHealthInfoSection extends StatefulWidget {
  final ChildHealthInfo? healthInfo;

  const ProfileHealthInfoSection({super.key, this.healthInfo});

  @override
  State<ProfileHealthInfoSection> createState() =>
      _ProfileHealthInfoSectionState();
}

class _ProfileHealthInfoSectionState extends State<ProfileHealthInfoSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final info = widget.healthInfo;
    final hasData = info != null && !info.isEmpty;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: hasData ? const Color(0xFFFFF8E1) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: hasData ? const Color(0xFFFFB300) : const Color(0xFFEEF1F7),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  Icon(
                    Icons.health_and_safety_rounded,
                    size: 18,
                    color: hasData
                        ? const Color(0xFFE65100)
                        : const Color(0xFF9AA3B5),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      translate('health_info.title'),
                      style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: hasData
                            ? const Color(0xFFBF360C)
                            : const Color(0xFF0F1218),
                      ),
                    ),
                  ),
                  if (hasData)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE65100),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '!',
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Color(0xFF9AA3B5),
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          if (_expanded) ...[
            const Divider(
              height: 1,
              color: Color(0xFFFFCC80),
            ),
            if (!hasData)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  translate('health_info.no_data'),
                  style: textTheme.bodyMedium?.copyWith(
                    color: const Color(0xFF9AA3B5),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TagGroup(
                      label: translate('health_info.allergies'),
                      icon: Icons.warning_amber_rounded,
                      color: const Color(0xFFD32F2F),
                      bgColor: const Color(0xFFFFEBEE),
                      items: info.allergies ?? [],
                    ),
                    _TagGroup(
                      label: translate('health_info.dietary_restrictions'),
                      icon: Icons.no_food_rounded,
                      color: const Color(0xFFE65100),
                      bgColor: const Color(0xFFFFF3E0),
                      items: info.dietaryRestrictions ?? [],
                    ),
                    _TagGroup(
                      label: translate('health_info.medical_conditions'),
                      icon: Icons.medical_information_rounded,
                      color: const Color(0xFF1565C0),
                      bgColor: const Color(0xFFE3F2FD),
                      items: info.medicalConditions ?? [],
                    ),
                    _TagGroup(
                      label: translate('health_info.fears_or_sensitivities'),
                      icon: Icons.sentiment_very_dissatisfied_rounded,
                      color: const Color(0xFF6A1B9A),
                      bgColor: const Color(0xFFF3E5F5),
                      items: info.fearsOrSensitivities ?? [],
                    ),
                    _MedicationGroup(medications: info.medications ?? []),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

// ── Grupo de tags ─────────────────────────────────────────────────────────────

class _TagGroup extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final Color bgColor;
  final List<String> items;

  const _TagGroup({
    required this.label,
    required this.icon,
    required this.color,
    required this.bgColor,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: items
                .map(
                  (item) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: color.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

// ── Grupo de medicamentos ─────────────────────────────────────────────────────

class _MedicationGroup extends StatelessWidget {
  final List<Medication> medications;

  const _MedicationGroup({required this.medications});

  @override
  Widget build(BuildContext context) {
    if (medications.isEmpty) return const SizedBox.shrink();

    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.medication_rounded, size: 14, color: Color(0xFF00695C)),
            const SizedBox(width: 6),
            Text(
              translate('health_info.medications'),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Color(0xFF00695C),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...medications.map(
          (med) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFE0F2F1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFF80CBC4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.medication_rounded,
                      size: 16,
                      color: Color(0xFF00695C),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        med.name ?? '-',
                        style: textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF004D40),
                        ),
                      ),
                    ),
                  ],
                ),
                if ((med.dosage?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 4),
                  _MedDetail(
                    label: translate('health_info.med_dosage'),
                    value: med.dosage!,
                  ),
                ],
                if ((med.schedule?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 2),
                  _MedDetail(
                    label: translate('health_info.med_schedule'),
                    value: med.schedule!,
                    icon: Icons.access_time_rounded,
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MedDetail extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MedDetail({
    required this.label,
    required this.value,
    this.icon = Icons.info_outline_rounded,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 12, color: const Color(0xFF00796B)),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF00796B),
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF004D40),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
