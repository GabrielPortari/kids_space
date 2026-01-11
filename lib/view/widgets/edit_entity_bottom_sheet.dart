import 'package:flutter/material.dart';
import 'package:kids_space/util/date_hour_util.dart';

enum FieldType { text, multiline, email, phone, number, date, select }

class FieldOption { final String value; final String label; FieldOption(this.value, this.label); }

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

Future<Map<String,dynamic>?> showEditEntityBottomSheet({
  required BuildContext context,
  required String title,
  required List<FieldDefinition> fields,
}) {
  return showModalBottomSheet<Map<String,dynamic>?>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => EditEntityBottomSheet(title: title, fields: fields),
  );
}

class EditEntityBottomSheet extends StatefulWidget {
  final String title;
  final List<FieldDefinition> fields;
  const EditEntityBottomSheet({required this.title, required this.fields, super.key});
  @override State<EditEntityBottomSheet> createState() => _EditEntityBottomSheetState();
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
    for (var f in widget.fields) {
      if (f.type == FieldType.select) {
        vals[f.key] = f.initialValue;
        continue;
      }

      if (f.type == FieldType.date) {
        // default date: 2000-01-01
        final defaultDate = DateTime(2000, 1, 1);
        String display = '';
        String? isoValue;

        if (f.initialValue is DateTime) {
          final dt = f.initialValue as DateTime;
          display = formatDateFull(dt);
          isoValue = dt.toIso8601String().split('T').first;
        } else if (f.initialValue is String) {
          // try parse ISO or dd/MM/yyyy
          final s = f.initialValue as String;
          DateTime? parsed = DateTime.tryParse(s);
          if (parsed == null) {
            // try dd/MM/yyyy
            final iso = formatDateToIsoString(s);
            if (iso != null) parsed = DateTime.tryParse(iso);
          }
          if (parsed != null) {
            display = formatDateFull(parsed);
            isoValue = parsed.toIso8601String().split('T').first;
          } else {
            display = formatDateFull(defaultDate);
            isoValue = defaultDate.toIso8601String().split('T').first;
          }
        } else {
          display = formatDateFull(defaultDate);
          isoValue = defaultDate.toIso8601String().split('T').first;
        }

        ctrl[f.key] = TextEditingController(text: display);
        vals[f.key] = isoValue;
      } else {
        ctrl[f.key] = TextEditingController(text: f.initialValue?.toString() ?? '');
        vals[f.key] = f.initialValue;
      }
    }

    _controllers = ctrl;
    _values = vals;
  }

  @override
  void dispose() {
    for (var c in _controllers.values) c.dispose();
    super.dispose();
  }

  void _onSave() {
    if (!_formKey.currentState!.validate()) return;
    for (var f in widget.fields) {
      if (f.type == FieldType.select) continue;
      if (f.type == FieldType.date) {
        final display = _controllers[f.key]?.text;
        final iso = display == null ? null : formatDateToIsoString(display);
        if (iso != null) {
          _values[f.key] = iso.split('T').first; // store yyyy-MM-dd
        }
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
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: Theme.of(context).canvasColor, borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(widget.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  IconButton(onPressed: () => Navigator.of(context).pop(), icon: const Icon(Icons.close)),
                ]),
                const SizedBox(height: 8),
                // build fields with small spacing between them
                (() {
                  final List<Widget> fieldWidgets = [];
                  for (var i = 0; i < widget.fields.length; i++) {
                    final f = widget.fields[i];
                    Widget fieldWidget;
                    switch (f.type) {
                      case FieldType.multiline:
                        fieldWidget = TextFormField(
                          controller: _controllers[f.key],
                          decoration: InputDecoration(labelText: f.label),
                          maxLines: 1,
                          validator: (v) => f.required && (v == null || v.isEmpty) ? 'Obrigatório' : null,
                        );
                        break;
                      case FieldType.number:
                        fieldWidget = TextFormField(
                          controller: _controllers[f.key],
                          decoration: InputDecoration(labelText: f.label),
                          keyboardType: TextInputType.number,
                          validator: (v) => f.required && (v == null || v.isEmpty) ? 'Obrigatório' : null,
                        );
                        break;
                      case FieldType.date:
                        fieldWidget = TextFormField(
                          controller: _controllers[f.key],
                          decoration: InputDecoration(labelText: f.label, suffixIcon: const Icon(Icons.calendar_today)),
                          readOnly: true,
                          onTap: () async {
                            DateTime initial = DateTime(2000, 1, 1);
                            final currentVal = _values[f.key];
                            if (currentVal is String) {
                              final parsedIso = DateTime.tryParse(currentVal);
                              if (parsedIso != null) initial = parsedIso;
                              else {
                                final iso = formatDateToIsoString(currentVal);
                                if (iso != null) {
                                  final p = DateTime.tryParse(iso);
                                  if (p != null) initial = p;
                                }
                              }
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
                              _controllers[f.key]?.text = formatDateFull(picked);
                              _values[f.key] = picked.toIso8601String().split('T').first;
                            }
                          },
                          validator: (v) => f.required && (v == null || v.isEmpty) ? 'Obrigatório' : null,
                        );
                        break;
                      case FieldType.select:
                        fieldWidget = DropdownButtonFormField<String>(
                          initialValue: f.initialValue?.toString(),
                          decoration: InputDecoration(labelText: f.label),
                          items: (f.options ?? []).map((o) => DropdownMenuItem(value: o.value, child: Text(o.label))).toList(),
                          onChanged: (v) => _values[f.key] = v,
                          validator: (v) => f.required && (v == null) ? 'Obrigatório' : null,
                        );
                        break;
                      default:
                        fieldWidget = TextFormField(
                          controller: _controllers[f.key],
                          decoration: InputDecoration(labelText: f.label),
                          keyboardType: f.type == FieldType.email ? TextInputType.emailAddress : TextInputType.text,
                          validator: (v) => f.required && (v == null || v.isEmpty) ? 'Obrigatório' : null,
                        );
                    }

                    fieldWidgets.add(fieldWidget);
                    if (i < widget.fields.length - 1) fieldWidgets.add(const SizedBox(height: 8));
                  }
                  return Column(children: fieldWidgets);
                })(),
                const SizedBox(height: 12),
                Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                  TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
                  const SizedBox(width: 8),
                  ElevatedButton(onPressed: _onSave, child: const Text('Salvar')),
                ])
              ]),
            ),
          ),
        ),
      ),
    );
  }
}