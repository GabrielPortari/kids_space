import 'package:flutter/material.dart';

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
    _controllers = {
      for (var f in widget.fields)
        if (f.type != FieldType.select) f.key: TextEditingController(text: f.initialValue?.toString() ?? '')
    };
    _values = { for (var f in widget.fields) f.key: f.initialValue };
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
                ...widget.fields.map((f) {
                  switch (f.type) {
                    case FieldType.multiline:
                      return TextFormField(
                        controller: _controllers[f.key],
                        decoration: InputDecoration(labelText: f.label),
                        maxLines: 1,
                        validator: (v) => f.required && (v == null || v.isEmpty) ? 'Obrigatório' : null,
                      );
                    case FieldType.number:
                      return TextFormField(
                        controller: _controllers[f.key],
                        decoration: InputDecoration(labelText: f.label),
                        keyboardType: TextInputType.number,
                        validator: (v) => f.required && (v == null || v.isEmpty) ? 'Obrigatório' : null,
                      );
                    case FieldType.date:
                      return TextFormField(
                        controller: _controllers[f.key],
                        decoration: InputDecoration(labelText: f.label, suffixIcon: const Icon(Icons.calendar_today)),
                        readOnly: true,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: (f.initialValue is DateTime) ? f.initialValue : DateTime.now(),
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) {
                            _controllers[f.key]?.text = picked.toIso8601String();
                            _values[f.key] = picked;
                          }
                        },
                        validator: (v) => f.required && (v == null || v.isEmpty) ? 'Obrigatório' : null,
                      );
                    case FieldType.select:
                      return DropdownButtonFormField<String>(
                        initialValue: f.initialValue?.toString(),
                        decoration: InputDecoration(labelText: f.label),
                        items: (f.options ?? []).map((o) => DropdownMenuItem(value: o.value, child: Text(o.label))).toList(),
                        onChanged: (v) => _values[f.key] = v,
                        validator: (v) => f.required && (v == null) ? 'Obrigatório' : null,
                      );
                    default:
                      return TextFormField(
                        controller: _controllers[f.key],
                        decoration: InputDecoration(labelText: f.label),
                        keyboardType: f.type == FieldType.email ? TextInputType.emailAddress : TextInputType.text,
                        validator: (v) => f.required && (v == null || v.isEmpty) ? 'Obrigatório' : null,
                      );
                  }
                }),
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