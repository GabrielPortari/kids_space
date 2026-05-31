import 'package:flutter/material.dart';
import 'package:kids_space/model/child_health_info.dart';
import 'package:kids_space/util/localization_service.dart';

class ProfileHealthInfoSection extends StatelessWidget {
  final ChildHealthInfo? healthInfo;

  const ProfileHealthInfoSection({super.key, this.healthInfo});

  @override
  Widget build(BuildContext context) {
    final info = healthInfo;
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.health_and_safety, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  translate('health_info.title'),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            if (info == null || info.isEmpty)
              Text(
                translate('health_info.no_data'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
              )
            else ...[
              _ChipListRow(
                label: translate('health_info.dietary_restrictions'),
                icon: Icons.no_food,
                items: info.dietaryRestrictions ?? [],
                color: Colors.orange,
              ),
              _ChipListRow(
                label: translate('health_info.allergies'),
                icon: Icons.warning_amber,
                items: info.allergies ?? [],
                color: Colors.red,
              ),
              _ChipListRow(
                label: translate('health_info.medical_conditions'),
                icon: Icons.medical_information,
                items: info.medicalConditions ?? [],
                color: Colors.blue,
              ),
              _ChipListRow(
                label: translate('health_info.fears_or_sensitivities'),
                icon: Icons.sentiment_dissatisfied,
                items: info.fearsOrSensitivities ?? [],
                color: Colors.purple,
              ),
              _MedicationList(medications: info.medications ?? []),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChipListRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final List<String> items;
  final Color color;

  const _ChipListRow({
    required this.label,
    required this.icon,
    required this.items,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
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
                  (item) => Chip(
                    label: Text(item, style: const TextStyle(fontSize: 12)),
                    backgroundColor: color.withValues(alpha: 0.1),
                    side: BorderSide(color: color.withValues(alpha: 0.3)),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }
}

class _MedicationList extends StatelessWidget {
  final List<Medication> medications;

  const _MedicationList({required this.medications});

  @override
  Widget build(BuildContext context) {
    if (medications.isEmpty) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.medication, size: 16, color: Colors.teal),
            const SizedBox(width: 6),
            Text(
              translate('health_info.medications'),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                color: Colors.teal,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...medications.map(
          (med) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.teal.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  med.name ?? '-',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (med.dosage != null && med.dosage!.isNotEmpty)
                  _InfoRow(
                    label: translate('health_info.med_dosage'),
                    value: med.dosage!,
                  ),
                if (med.schedule != null && med.schedule!.isNotEmpty)
                  _InfoRow(
                    label: translate('health_info.med_schedule'),
                    value: med.schedule!,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
