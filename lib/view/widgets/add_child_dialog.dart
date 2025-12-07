import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kids_space/model/child.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/user_controller.dart';

/// Modal dialog to create a new `Child`.
///
/// Usage examples:
/// - `final created = await showDialog<Child>(context: context, builder: (_) => AddChildDialog(responsibleUserId: userId, companyId: companyId));`
/// - or provide `onCreate` to handle persistence: `AddChildDialog(onCreate: (child) => childService.save(child))`
class AddChildDialog extends StatefulWidget {
  final String? companyId;
  final String? responsibleUserId;
  final void Function(Child child)? onCreate;
  final void Function(Child child)? onUpdate;
  final Child? initialChild;

  const AddChildDialog({this.companyId, this.responsibleUserId, this.onCreate, this.onUpdate, this.initialChild, super.key});

  @override
  State<AddChildDialog> createState() => _AddChildDialogState();
}

class _AddChildDialogState extends State<AddChildDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _documentController;
  bool _isActive = false;
  bool _isSaving = false;
  bool _isFormValid = false;

  @override
  void initState() {
    super.initState();
    debugPrint('DebuggerLog: AddChildDialog.initState responsible=${widget.responsibleUserId ?? 'none'}');
    _nameController = TextEditingController(text: widget.initialChild?.name ?? '');
    _documentController = TextEditingController(text: widget.initialChild?.document ?? '');
    _isActive = widget.initialChild?.isActive ?? false;
    _nameController.addListener(_onFieldChanged);
    _documentController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    debugPrint('DebuggerLog: AddChildDialog.dispose');
    _nameController.removeListener(_onFieldChanged);
    _nameController.dispose();
    _documentController.removeListener(_onFieldChanged);
    _documentController.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final valid = _nameController.text.trim().isNotEmpty;
    if (valid != _isFormValid) {
      setState(() => _isFormValid = valid);
    }
    debugPrint('DebuggerLog: AddChildDialog.onFieldChanged name="${_nameController.text}" document="${_documentController.text}" isFormValid=${_isFormValid}');
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.initialChild == null ? 'Cadastrar criança' : 'Editar criança'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _nameField(),
              const SizedBox(height: 12),
              _documentField(),
              if (widget.responsibleUserId != null) ...[
                const SizedBox(height: 8),
                _responsibleInfo(),
              ],
            ],
          ),
        ),
      ),
      actions: _buildActions(context),
    );
  }

  Widget _nameField() {
    return TextFormField(
      controller: _nameController,
      decoration: const InputDecoration(labelText: 'Nome da criança'),
      textInputAction: TextInputAction.done,
      validator: (v) => (v == null || v.trim().isEmpty) ? 'Nome é obrigatório' : null,
      autofocus: true,
    );
  }

  Widget _documentField() {
    return TextFormField(
      controller: _documentController,
      decoration: const InputDecoration(labelText: 'Documento (CPF/RG)', hintText: 'Somente dígitos'),
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
      textInputAction: TextInputAction.next,
      validator: (v) {
        if (v == null || v.trim().isEmpty) return null; // optional
        final digits = v.replaceAll(RegExp(r'[^0-9]'), '');
        if (digits.length == 9 || digits.length == 11) return null;
        return 'Documento inválido (9 ou 11 dígitos)';
      },
    );
  }

  Widget _responsibleInfo() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Builder(builder: (_) {
        var responsibleName = widget.responsibleUserId;
        try {
          final u = GetIt.I<UserController>().getUserById(widget.responsibleUserId!);
          if (u != null) responsibleName = u.name;
        } catch (_) {}
        return Text('Responsável: $responsibleName', style: const TextStyle(fontSize: 12, color: Colors.black54));
      }),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    return [
      TextButton(
        onPressed: _isSaving
            ? null
            : () {
                debugPrint('DebuggerLog: AddChildDialog.cancel');
                Navigator.pop(context, null);
              },
        child: const Text('Cancelar'),
      ),
      ElevatedButton(
        onPressed: (_isSaving || !_isFormValid)
            ? null
            : () async {
                debugPrint('DebuggerLog: AddChildDialog.submit attempt');
                if (!_formKey.currentState!.validate()) {
                  debugPrint('DebuggerLog: AddChildDialog.submit validation failed');
                  return;
                }
                setState(() => _isSaving = true);

                try {
                  if (widget.initialChild == null) {
                    // create
                    final id = DateTime.now().millisecondsSinceEpoch.toString();
                    final child = Child(
                      id: id,
                      name: _nameController.text.trim(),
                      companyId: widget.companyId ?? '',
                      responsibleUserIds: widget.responsibleUserId != null ? [widget.responsibleUserId!] : [],
                      document: _documentController.text.trim().isEmpty ? null : _documentController.text.trim(),
                      isActive: _isActive,
                      createdAt: DateTime.now(),
                      updatedAt: DateTime.now()
                    );
                    debugPrint('DebuggerLog: AddChildDialog.createChild -> id=$id name=${child.name} responsible=${widget.responsibleUserId ?? 'none'}');
                    if (widget.onCreate != null) {
                      debugPrint('DebuggerLog: AddChildDialog.calling onCreate callback');
                      widget.onCreate!(child);
                    }
                    Navigator.pop(context, child);
                    debugPrint('DebuggerLog: AddChildDialog.created and closed -> id=$id');
                  } else {
                    final updated = Child(
                      id: widget.initialChild!.id,
                      name: _nameController.text.trim(),
                      companyId: widget.companyId ?? widget.initialChild!.companyId,
                      responsibleUserIds: widget.initialChild!.responsibleUserIds,
                      document: _documentController.text.trim().isEmpty ? null : _documentController.text.trim(),
                      isActive: _isActive,
                      createdAt: widget.initialChild!.createdAt,
                      updatedAt: DateTime.now(),
                    );
                    debugPrint('DebuggerLog: AddChildDialog.updateChild -> id=${updated.id} name=${updated.name}');
                    if (widget.onUpdate != null) {
                      widget.onUpdate!(updated);
                    }
                    Navigator.pop(context, updated);
                    debugPrint('DebuggerLog: AddChildDialog.updated and closed -> id=${updated.id}');
                  }
                } catch (e, st) {
                  debugPrint('DebuggerLog: AddChildDialog.createChild ERROR $e\n$st');
                  setState(() => _isSaving = false);
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erro ao cadastrar criança')));
                }
              },
        child: Builder(builder: (_) {
          return _isSaving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(widget.initialChild == null ? 'Cadastrar' : 'Salvar');
        }),
      ),
    ];
  }
}
