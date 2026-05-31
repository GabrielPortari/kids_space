import 'package:flutter/material.dart';
import 'package:kids_space/model/child_health_info.dart';
import 'package:kids_space/util/localization_service.dart';

Future<ChildHealthInfo?> showHealthInfoEditBottomSheet({
  required BuildContext context,
  required ChildHealthInfo? current,
}) {
  return showModalBottomSheet<ChildHealthInfo?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _HealthInfoEditSheet(current: current),
  );
}

class _HealthInfoEditSheet extends StatefulWidget {
  final ChildHealthInfo? current;
  const _HealthInfoEditSheet({this.current});

  @override
  State<_HealthInfoEditSheet> createState() => _HealthInfoEditSheetState();
}

class _HealthInfoEditSheetState extends State<_HealthInfoEditSheet> {
  late List<String> _dietaryRestrictions;
  late List<String> _allergies;
  late List<String> _medicalConditions;
  late List<String> _fearsOrSensitivities;
  late List<_MedEntry> _medications;

  @override
  void initState() {
    super.initState();
    final h = widget.current;
    _dietaryRestrictions = List.from(h?.dietaryRestrictions ?? []);
    _allergies = List.from(h?.allergies ?? []);
    _medicalConditions = List.from(h?.medicalConditions ?? []);
    _fearsOrSensitivities = List.from(h?.fearsOrSensitivities ?? []);
    _medications = (h?.medications ?? [])
        .map(
          (m) => _MedEntry(
            nameCtrl: TextEditingController(text: m.name ?? ''),
            dosageCtrl: TextEditingController(text: m.dosage ?? ''),
            scheduleCtrl: TextEditingController(text: m.schedule ?? ''),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    for (final m in _medications) {
      m.nameCtrl.dispose();
      m.dosageCtrl.dispose();
      m.scheduleCtrl.dispose();
    }
    super.dispose();
  }

  void _save() {
    final result = ChildHealthInfo(
      dietaryRestrictions: List.from(_dietaryRestrictions),
      allergies: List.from(_allergies),
      medicalConditions: List.from(_medicalConditions),
      fearsOrSensitivities: List.from(_fearsOrSensitivities),
      medications: _medications
          .map(
            (m) => Medication(
              name: m.nameCtrl.text.trim().isEmpty
                  ? null
                  : m.nameCtrl.text.trim(),
              dosage: m.dosageCtrl.text.trim().isEmpty
                  ? null
                  : m.dosageCtrl.text.trim(),
              schedule: m.scheduleCtrl.text.trim().isEmpty
                  ? null
                  : m.scheduleCtrl.text.trim(),
            ),
          )
          .where((m) => m.name != null)
          .toList(),
    );
    Navigator.of(context).pop(result);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      translate('health_info.edit_title'),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              const Divider(height: 8),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _TagSection(
                        label: translate('health_info.dietary_restrictions'),
                        icon: Icons.no_food,
                        color: Colors.orange,
                        items: _dietaryRestrictions,
                        onChanged: (v) =>
                            setState(() => _dietaryRestrictions = v),
                      ),
                      const SizedBox(height: 16),
                      _TagSection(
                        label: translate('health_info.allergies'),
                        icon: Icons.warning_amber,
                        color: Colors.red,
                        items: _allergies,
                        onChanged: (v) => setState(() => _allergies = v),
                      ),
                      const SizedBox(height: 16),
                      _TagSection(
                        label: translate('health_info.medical_conditions'),
                        icon: Icons.medical_information,
                        color: Colors.blue,
                        items: _medicalConditions,
                        onChanged: (v) =>
                            setState(() => _medicalConditions = v),
                      ),
                      const SizedBox(height: 16),
                      _TagSection(
                        label: translate('health_info.fears_or_sensitivities'),
                        icon: Icons.sentiment_dissatisfied,
                        color: Colors.purple,
                        items: _fearsOrSensitivities,
                        onChanged: (v) =>
                            setState(() => _fearsOrSensitivities = v),
                      ),
                      const SizedBox(height: 16),
                      _MedicationsSection(
                        medications: _medications,
                        onChanged: (v) => setState(() => _medications = v),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(translate('buttons.cancel')),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _save,
                      child: Text(translate('buttons.save')),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tag (chip list) section ──────────────────────────────────────────────────

class _TagSection extends StatefulWidget {
  final String label;
  final IconData icon;
  final Color color;
  final List<String> items;
  final ValueChanged<List<String>> onChanged;

  const _TagSection({
    required this.label,
    required this.icon,
    required this.color,
    required this.items,
    required this.onChanged,
  });

  @override
  State<_TagSection> createState() => _TagSectionState();
}

class _TagSectionState extends State<_TagSection> {
  final _ctrl = TextEditingController();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _add() {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final updated = [...widget.items, text];
    widget.onChanged(updated);
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(widget.icon, size: 16, color: widget.color),
            const SizedBox(width: 6),
            Text(
              widget.label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: widget.color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (widget.items.isNotEmpty)
          Wrap(
            spacing: 6,
            runSpacing: 4,
            children: widget.items
                .asMap()
                .entries
                .map(
                  (e) => Chip(
                    label: Text(e.value, style: const TextStyle(fontSize: 12)),
                    backgroundColor: widget.color.withValues(alpha: 0.1),
                    side: BorderSide(color: widget.color.withValues(alpha: 0.3)),
                    deleteIcon: const Icon(Icons.close, size: 14),
                    onDeleted: () {
                      final updated = [...widget.items]..removeAt(e.key);
                      widget.onChanged(updated);
                    },
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                )
                .toList(),
          ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _ctrl,
                decoration: InputDecoration(
                  hintText: translate('health_info.add_item_hint'),
                  isDense: true,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                ),
                onSubmitted: (_) => _add(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: _add,
              icon: const Icon(Icons.add),
              style: IconButton.styleFrom(
                backgroundColor: widget.color,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Medications section ──────────────────────────────────────────────────────

class _MedEntry {
  final TextEditingController nameCtrl;
  final TextEditingController dosageCtrl;
  final TextEditingController scheduleCtrl;

  _MedEntry({
    required this.nameCtrl,
    required this.dosageCtrl,
    required this.scheduleCtrl,
  });
}

class _MedicationsSection extends StatelessWidget {
  final List<_MedEntry> medications;
  final ValueChanged<List<_MedEntry>> onChanged;

  const _MedicationsSection({
    required this.medications,
    required this.onChanged,
  });

  void _add() {
    onChanged([
      ...medications,
      _MedEntry(
        nameCtrl: TextEditingController(),
        dosageCtrl: TextEditingController(),
        scheduleCtrl: TextEditingController(),
      ),
    ]);
  }

  void _remove(int index) {
    final entry = medications[index];
    entry.nameCtrl.dispose();
    entry.dosageCtrl.dispose();
    entry.scheduleCtrl.dispose();
    final updated = [...medications]..removeAt(index);
    onChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.medication, size: 16, color: Colors.teal),
            const SizedBox(width: 6),
            Text(
              translate('health_info.medications'),
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...medications.asMap().entries.map(
          (e) => _MedCard(
            entry: e.value,
            index: e.key,
            onRemove: () => _remove(e.key),
          ),
        ),
        TextButton.icon(
          onPressed: _add,
          icon: const Icon(Icons.add, color: Colors.teal),
          label: Text(
            translate('health_info.add_medication'),
            style: const TextStyle(color: Colors.teal),
          ),
        ),
      ],
    );
  }
}

class _MedCard extends StatelessWidget {
  final _MedEntry entry;
  final int index;
  final VoidCallback onRemove;

  const _MedCard({
    required this.entry,
    required this.index,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 10),
      decoration: BoxDecoration(
        color: Colors.teal.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.teal.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${translate("health_info.medication")} ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.teal,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onRemove,
                tooltip: translate('health_info.remove_medication'),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          const SizedBox(height: 6),
          TextField(
            controller: entry.nameCtrl,
            decoration: InputDecoration(
              labelText: translate('health_info.med_name'),
              isDense: true,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: entry.dosageCtrl,
            decoration: InputDecoration(
              labelText: translate('health_info.med_dosage'),
              isDense: true,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 8),
          _ScheduleField(controller: entry.scheduleCtrl),
        ],
      ),
    );
  }
}

class _ScheduleField extends StatelessWidget {
  final TextEditingController controller;

  const _ScheduleField({required this.controller});

  Future<void> _pickTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked == null) return;
    final formatted =
        '${picked.hour.toString().padLeft(2, '0')}h${picked.minute == 0 ? '' : picked.minute.toString().padLeft(2, '0')}';
    final current = controller.text.trim();
    controller.text =
        current.isEmpty ? formatted : '$current e $formatted';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: translate('health_info.med_schedule'),
              isDense: true,
              border: const OutlineInputBorder(),
              hintText: translate('health_info.med_schedule_hint'),
            ),
          ),
        ),
        const SizedBox(width: 6),
        IconButton(
          icon: const Icon(Icons.access_time, color: Colors.teal),
          tooltip: translate('health_info.pick_time'),
          onPressed: () => _pickTime(context),
        ),
      ],
    );
  }
}
