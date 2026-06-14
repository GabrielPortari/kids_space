import 'package:flutter/material.dart';
import 'package:kids_space/util/date_hour_util.dart';
import 'package:kids_space/util/localization_service.dart';

enum FieldType { text, multiline, email, phone, number, date, select }

class FieldOption {
  final String value;
  final String label;
  FieldOption(this.value, this.label);
}

class FieldDefinition {
  final String key;
  final String label;
  final FieldType type;
  final dynamic initialValue;
  final bool required;
  final List<FieldOption>? options;
  final String? Function(dynamic)? validator;

  FieldDefinition({
    required this.key,
    required this.label,
    this.type = FieldType.text,
    this.initialValue,
    this.required = false,
    this.options,
    this.validator,
  });
}

Future<Map<String, dynamic>?> showEditEntityBottomSheet({
  required BuildContext context,
  required String title,
  required List<FieldDefinition> fields,
}) {
  return showModalBottomSheet<Map<String, dynamic>?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => EditEntityBottomSheet(title: title, fields: fields),
  );
}

class EditEntityBottomSheet extends StatefulWidget {
  final String title;
  final List<FieldDefinition> fields;

  const EditEntityBottomSheet({
    required this.title,
    required this.fields,
    super.key,
  });

  @override
  State<EditEntityBottomSheet> createState() => _EditEntityBottomSheetState();
}

class _EditEntityBottomSheetState extends State<EditEntityBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final Map<String, TextEditingController> _controllers;
  late final Map<String, dynamic> _values;

  @override
  void initState() {
    super.initState();
    final Map<String, TextEditingController> ctrl = {};
    final Map<String, dynamic> vals = {};

    for (final f in widget.fields) {
      if (f.type == FieldType.select) {
        vals[f.key] = f.initialValue;
        continue;
      }
      if (f.type == FieldType.date) {
        final defaultDate = DateTime(2000, 1, 1);
        String display = '';
        String? isoValue;

        if (f.initialValue is DateTime) {
          final dt = f.initialValue as DateTime;
          display = formatDate_ddMMyyyy(dt);
          isoValue = dt.toIso8601String().split('T').first;
        } else if (f.initialValue is String) {
          final s = f.initialValue as String;
          DateTime? parsed = DateTime.tryParse(s);
          if (parsed == null) {
            final iso = formatDateToIsoString(s);
            if (iso != null) parsed = DateTime.tryParse(iso);
          }
          if (parsed != null) {
            display = formatDate_ddMMyyyy(parsed);
            isoValue = parsed.toIso8601String().split('T').first;
          } else {
            display = formatDate_ddMMyyyy(defaultDate);
            isoValue = defaultDate.toIso8601String().split('T').first;
          }
        } else {
          display = formatDate_ddMMyyyy(defaultDate);
          isoValue = defaultDate.toIso8601String().split('T').first;
        }

        ctrl[f.key] = TextEditingController(text: display);
        vals[f.key] = isoValue;
      } else {
        ctrl[f.key] = TextEditingController(
          text: f.initialValue?.toString() ?? '',
        );
        vals[f.key] = f.initialValue;
      }
    }

    _controllers = ctrl;
    _values = vals;
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    for (final f in widget.fields) {
      if (f.type == FieldType.select) continue;
      if (f.type == FieldType.date) {
        final display = _controllers[f.key]?.text;
        final iso = display == null ? null : formatDateToIsoString(display);
        if (iso != null) _values[f.key] = iso.split('T').first;
        continue;
      }
      _values[f.key] = _controllers[f.key]?.text;
    }
    Navigator.of(context).pop(_values);
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
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEEF1F7)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 10),
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFDDE2ED),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 12, 8, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0F1218),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close_rounded),
                      color: const Color(0xFF9AA3B5),
                    ),
                  ],
                ),
              ),
              const Divider(height: 16, color: Color(0xFFEEF1F7)),
              // Form
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ...widget.fields.indexed.expand((item) {
                          final (i, f) = item;
                          return [
                            if (i > 0) const SizedBox(height: 12),
                            _buildField(f),
                          ];
                        }),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: Text(translate('buttons.cancel')),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: FilledButton(
                                onPressed: _onSave,
                                child: Text(translate('buttons.save')),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildField(FieldDefinition f) {
    switch (f.type) {
      case FieldType.date:
        return TextFormField(
          controller: _controllers[f.key],
          decoration: InputDecoration(
            labelText: f.required ? '${f.label} *' : f.label,
            suffixIcon: const Icon(Icons.calendar_today_rounded, size: 18),
          ),
          readOnly: true,
          onTap: () async {
            DateTime initial = DateTime(2000);
            final currentVal = _values[f.key];
            if (currentVal is String) {
              final p = DateTime.tryParse(currentVal) ??
                  DateTime.tryParse(
                      formatDateToIsoString(currentVal) ?? '');
              if (p != null) initial = p;
            } else if (currentVal is DateTime) {
              initial = currentVal;
            }
            final picked = await showDatePicker(
              context: context,
              initialDate: initial,
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (picked != null) {
              _controllers[f.key]?.text = formatDate_ddMMyyyy(picked);
              _values[f.key] = picked.toIso8601String().split('T').first;
            }
          },
          validator: (v) =>
              f.required && (v == null || v.isEmpty)
              ? translate('validation.required')
              : null,
        );

      case FieldType.select:
        return DropdownButtonFormField<String>(
          initialValue: f.initialValue?.toString(),
          decoration: InputDecoration(
            labelText: f.required ? '${f.label} *' : f.label,
          ),
          items: (f.options ?? [])
              .map(
                (o) => DropdownMenuItem(value: o.value, child: Text(o.label)),
              )
              .toList(),
          onChanged: (v) => _values[f.key] = v,
          validator: (v) =>
              f.required && v == null
              ? translate('validation.required')
              : null,
        );

      case FieldType.multiline:
        return TextFormField(
          controller: _controllers[f.key],
          decoration: InputDecoration(
            labelText: f.required ? '${f.label} *' : f.label,
            alignLabelWithHint: true,
          ),
          maxLines: 3,
          validator: (v) =>
              f.required && (v == null || v.isEmpty)
              ? translate('validation.required')
              : null,
        );

      case FieldType.number:
        return TextFormField(
          controller: _controllers[f.key],
          decoration: InputDecoration(
            labelText: f.required ? '${f.label} *' : f.label,
          ),
          keyboardType: TextInputType.number,
          validator: (v) =>
              f.required && (v == null || v.isEmpty)
              ? translate('validation.required')
              : null,
        );

      default:
        return TextFormField(
          controller: _controllers[f.key],
          decoration: InputDecoration(
            labelText: f.required ? '${f.label} *' : f.label,
          ),
          keyboardType: switch (f.type) {
            FieldType.email => TextInputType.emailAddress,
            FieldType.phone => TextInputType.phone,
            _ => TextInputType.text,
          },
          validator: (v) {
            if (f.required && (v == null || v.isEmpty)) {
              return translate('validation.required');
            }
            return f.validator?.call(v);
          },
        );
    }
  }
}
