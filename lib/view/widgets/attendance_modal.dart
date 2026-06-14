import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/controller/attendance_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/parent_controller.dart';
import 'package:kids_space/model/attendance.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/util/localization_service.dart';
import 'package:kids_space/util/string_utils.dart';

Future<void> showAttendanceModal(
  BuildContext context,
  AttendanceType type,
) async {
  final childController = GetIt.I<ChildController>();
  final attendanceController = GetIt.I<AttendanceController>();
  final companyController = GetIt.I<CompanyController>();

  final companyId = companyController.company?.id;
  if (companyId != null) {
    await attendanceController.loadActiveCheckinsForCompany(companyId);
  }

  String? selectedChildId;
  bool loading = false;

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(
        builder: (innerCtx, setState) {
          final filter = childController.childFilter.toLowerCase();
          final activeIds = attendanceController.activeCheckins
              .map((a) => a.childId)
              .whereType<String>()
              .toSet();

          final List<Child> source = type == AttendanceType.checkout
              ? (companyId != null
                    ? childController.children
                          .where((c) => c.id != null && activeIds.contains(c.id))
                          .toList()
                    : <Child>[])
              : childController.filteredChildren
                    .where((c) => !(c.id != null && activeIds.contains(c.id)))
                    .toList();

          final filteredSource = source.where((c) {
            if (filter.isEmpty) return true;
            final name = c.name?.toLowerCase() ?? '';
            final email = c.email?.toLowerCase() ?? '';
            final doc = c.document?.toLowerCase() ?? '';
            return name.contains(filter) ||
                email.contains(filter) ||
                doc.contains(filter);
          }).toList();

          final isCheckin = type == AttendanceType.checkin;
          final textTheme = Theme.of(innerCtx).textTheme;

          return Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 24,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // ── Header ────────────────────────────────────────────────
                  Container(
                    color: isCheckin
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFF3E0),
                    padding: const EdgeInsets.fromLTRB(20, 16, 12, 16),
                    child: Row(
                      children: [
                        Icon(
                          isCheckin
                              ? Icons.login_rounded
                              : Icons.logout_rounded,
                          color: isCheckin
                              ? const Color(0xFF388E3C)
                              : const Color(0xFFE65100),
                          size: 22,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            isCheckin
                                ? translate('home.check_in')
                                : translate('home.check_out'),
                            style: textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isCheckin
                                  ? const Color(0xFF1B5E20)
                                  : const Color(0xFFBF360C),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () {
                            childController.childFilter = '';
                            Navigator.of(ctx).pop();
                          },
                          color: const Color(0xFF495267),
                          tooltip: translate('buttons.cancel'),
                        ),
                      ],
                    ),
                  ),

                  // ── Busca ─────────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: TextField(
                      autofocus: true,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded),
                        hintText: translate('attendance.search_child'),
                        suffixIcon: filter.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.close_rounded, size: 18),
                                onPressed: () {
                                  childController.childFilter = '';
                                  setState(() {});
                                },
                              ),
                      ),
                      onChanged: (v) {
                        childController.childFilter = v;
                        setState(() {});
                      },
                    ),
                  ),

                  // ── Lista de crianças ────────────────────────────────────
                  Flexible(
                    child: filteredSource.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.child_care_outlined,
                                  size: 48,
                                  color: const Color(0xFFC4CADA),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  translate('attendance.no_children_found'),
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: const Color(0xFF9AA3B5),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            itemCount: filteredSource.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 2),
                            itemBuilder: (_, i) {
                              final child = filteredSource[i];
                              final id = child.id ?? '';
                              final isSelected = selectedChildId == id;

                              return _ChildSelectionTile(
                                child: child,
                                isSelected: isSelected,
                                onTap: () => setState(
                                  () => selectedChildId = isSelected ? null : id,
                                ),
                              );
                            },
                          ),
                  ),

                  // ── Ações ─────────────────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    decoration: const BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFEEF1F7)),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              childController.childFilter = '';
                              Navigator.of(ctx).pop();
                            },
                            child: Text(translate('buttons.cancel')),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            onPressed: (selectedChildId == null || loading)
                                ? null
                                : () async {
                                    setState(() => loading = true);
                                    await _handleConfirm(
                                      ctx: ctx,
                                      innerCtx: innerCtx,
                                      type: type,
                                      selectedChildId: selectedChildId!,
                                      companyId: companyId,
                                      childController: childController,
                                      attendanceController:
                                          attendanceController,
                                      context: context,
                                    );
                                    setState(() => loading = false);
                                  },
                            style: FilledButton.styleFrom(
                              backgroundColor: isCheckin
                                  ? const Color(0xFF388E3C)
                                  : const Color(0xFFE65100),
                            ),
                            child: loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    selectedChildId == null
                                        ? translate('attendance.search_child')
                                        : translate('buttons.confirm'),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

// ── Tile de seleção de criança ────────────────────────────────────────────────

class _ChildSelectionTile extends StatelessWidget {
  final Child child;
  final bool isSelected;
  final VoidCallback onTap;

  const _ChildSelectionTile({
    required this.child,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final initials = (child.name ?? '?')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .take(2)
        .map((w) => w[0].toUpperCase())
        .join();

    return Material(
      color: isSelected
          ? scheme.primaryContainer
          : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: isSelected
                    ? scheme.primary
                    : scheme.primaryContainer,
                child: Text(
                  initials,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : scheme.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      child.name ?? '-',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? scheme.primary
                            : const Color(0xFF0F1218),
                      ),
                    ),
                    if (child.document != null && child.document!.isNotEmpty)
                      Text(
                        child.document!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9AA3B5),
                        ),
                      ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle_rounded, color: scheme.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Lógica de confirmação (extraída para legibilidade) ────────────────────────

Future<void> _handleConfirm({
  required BuildContext ctx,
  required BuildContext innerCtx,
  required AttendanceType type,
  required String selectedChildId,
  required String? companyId,
  required ChildController childController,
  required AttendanceController attendanceController,
  required BuildContext context,
}) async {
  final collaboratorController = GetIt.I<CollaboratorController>();
  final userController = GetIt.I<ParentController>();

  final activeIds = attendanceController.activeCheckins
      .map((a) => a.childId)
      .whereType<String>()
      .toSet();

  final List<Child> currentSource = type == AttendanceType.checkout
      ? (companyId != null
            ? childController.children
                  .where((c) => c.id != null && activeIds.contains(c.id))
                  .toList()
            : <Child>[])
      : childController.filteredChildren
            .where((c) => !(c.id != null && activeIds.contains(c.id)))
            .toList();

  final idx = currentSource.indexWhere((c) => c.id == selectedChildId);
  if (idx == -1) return;
  final child = currentSource[idx];

  // ── Seleção de responsável + CPF ─────────────────────────────────────────
  String? selectedResponsibleId;
  String? notes;
  String? typedResponsibleDocument;

  List<String> parents = [];
  if (type == AttendanceType.checkin) {
    parents = child.parents ?? [];
  } else {
    final active = attendanceController.activeCheckins;
    parents = active
        .where((a) => (a.childSnapshot ?? a.childId) == child.id)
        .map((a) => a.responsibleCheckedInSnapshot ?? a.parentIdWhoCheckedInId)
        .whereType<String>()
        .toSet()
        .toList();
    if (parents.isEmpty) parents = child.parents ?? [];
  }

  final result = await showDialog<Map<String, String?>>(
    context: innerCtx,
    builder: (rc) => _ResponsibleAndNotesDialog(
      child: child,
      parents: parents,
      type: type,
      userController: userController,
    ),
  );

  if (result == null) return;
  selectedResponsibleId = result['responsible'];
  notes = result['notes'];
  typedResponsibleDocument = result['responsibleDocument'];

  // ── Confirmação final ─────────────────────────────────────────────────────
  final confirm = await showDialog<bool>(
    context: innerCtx,
    builder: (cc) {
      final childName = child.name ?? selectedChildId;
      final responsibleName = selectedResponsibleId != null
          ? userController.getUserById(selectedResponsibleId)?.name ??
                selectedResponsibleId
          : collaboratorController.loggedCollaborator?.name ?? '-';

      return _ConfirmDialog(
        childName: childName,
        type: type,
        responsibleName: responsibleName,
        collaboratorName:
            collaboratorController.loggedCollaborator?.name ?? '-',
        notes: notes,
      );
    },
  );

  bool ok = false;
  if (confirm == true) {
    try {
      if (type == AttendanceType.checkin) {
        final res = await attendanceController.checkin({
          'childId': child.id,
          if (selectedResponsibleId != null)
            'responsibleIdWhoCheckedInId': selectedResponsibleId,
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          if (companyId != null && companyId.isNotEmpty) 'companyId': companyId,
        });
        ok = res.id != null;
      } else {
        String? responsibleDocument;
        if (selectedResponsibleId != null) {
          final parent = userController.getUserById(selectedResponsibleId);
          responsibleDocument = parent?.document;
        }
        if (typedResponsibleDocument != null &&
            typedResponsibleDocument.isNotEmpty) {
          responsibleDocument = typedResponsibleDocument;
        }
        final res = await attendanceController.checkout({
          'childId': child.id,
          if (responsibleDocument != null && responsibleDocument.isNotEmpty)
            'responsibleDocument': normalizeDigits(responsibleDocument),
          if (notes != null && notes.isNotEmpty) 'notes': notes,
          if (companyId != null && companyId.isNotEmpty) 'companyId': companyId,
        });
        ok = res.id != null || res.checkOutTime != null;
      }
    } catch (_) {
      ok = false;
    }
  }

  if (!ctx.mounted) return;
  Navigator.of(ctx).pop();
  childController.childFilter = '';

  // Background refresh
  if (companyId != null) {
    attendanceController.loadActiveCheckinsForCompany(companyId);
    attendanceController.loadLast10AttendancesForCompany(companyId);
    attendanceController.loadLastCheckinAndCheckoutForCompany(companyId);
    childController.refreshChildrenForCompany(companyId);
  }

  if (!context.mounted) return;
  final successMsg = type == AttendanceType.checkin
      ? 'Check-in realizado com sucesso'
      : 'Check-out realizado com sucesso';
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(ok ? successMsg : translate('attendance.operation_error')),
      backgroundColor: ok
          ? (type == AttendanceType.checkin
                ? const Color(0xFF388E3C)
                : const Color(0xFFE65100))
          : const Color(0xFFB00020),
    ),
  );
}

// ── Dialog: seleção de responsável e observações ──────────────────────────────

class _ResponsibleAndNotesDialog extends StatefulWidget {
  final Child child;
  final List<String> parents;
  final AttendanceType type;
  final ParentController userController;

  const _ResponsibleAndNotesDialog({
    required this.child,
    required this.parents,
    required this.type,
    required this.userController,
  });

  @override
  State<_ResponsibleAndNotesDialog> createState() =>
      _ResponsibleAndNotesDialogState();
}

class _ResponsibleAndNotesDialogState
    extends State<_ResponsibleAndNotesDialog> {
  String? _chosen;
  String _localNotes = '';
  String _localDocument = '';
  final _docCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.parents.length == 1) _chosen = widget.parents.first;
  }

  @override
  void dispose() {
    _docCtrl.dispose();
    super.dispose();
  }

  String _formatCpf(String v) {
    final d = normalizeDigits(v);
    final len = d.length;
    if (len <= 3) return d;
    if (len <= 6) return '${d.substring(0, 3)}.${d.substring(3)}';
    if (len <= 9) {
      return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6)}';
    }
    return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6, 9)}-${d.substring(9)}';
  }

  bool get _isCheckout => widget.type == AttendanceType.checkout;
  bool get _cpfComplete => normalizeDigits(_localDocument).length == 11;
  bool get _canConfirm => !_isCheckout || _cpfComplete;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _isCheckout ? Icons.logout_rounded : Icons.login_rounded,
            color: _isCheckout ? const Color(0xFFE65100) : scheme.primary,
            size: 22,
          ),
          const SizedBox(width: 8),
          Text(translate('attendance.responsible_and_notes')),
        ],
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nome da criança
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFF7F9FC),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.child_care_rounded,
                      size: 16, color: Color(0xFF9AA3B5)),
                  const SizedBox(width: 8),
                  Text(
                    widget.child.name ?? '-',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // Alerta de saúde
            if (widget.child.healthInfo != null &&
                !(widget.child.healthInfo!.isEmpty)) ...[
              const SizedBox(height: 12),
              _HealthAlertBanner(healthInfo: widget.child.healthInfo!),
            ],

            if (widget.parents.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                translate('attendance.select_responsible'),
                style: textTheme.labelMedium?.copyWith(
                  color: const Color(0xFF495267),
                ),
              ),
              const SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.25,
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: widget.parents.length,
                  itemBuilder: (_, i) {
                    final rid = widget.parents[i];
                    final name =
                        widget.userController.getUserById(rid)?.name ?? rid;
                    final isSelected = _chosen == rid;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: InkWell(
                        onTap: () => setState(() => _chosen = rid),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected
                                ? scheme.primaryContainer
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isSelected
                                  ? scheme.primary.withValues(alpha: 0.3)
                                  : const Color(0xFFEEF1F7),
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Row(
                            children: [
                              Icon(
                                isSelected
                                    ? Icons.radio_button_checked_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: isSelected
                                    ? scheme.primary
                                    : const Color(0xFFC4CADA),
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  name,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: isSelected
                                        ? scheme.primary
                                        : const Color(0xFF0F1218),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            // Observações
            const SizedBox(height: 16),
            TextField(
              maxLines: 3,
              decoration: InputDecoration(
                labelText: translate('attendance.notes_optional'),
                alignLabelWithHint: true,
                prefixIcon: const Padding(
                  padding: EdgeInsets.only(bottom: 40),
                  child: Icon(Icons.notes_rounded, size: 18),
                ),
              ),
              onChanged: (v) => setState(() => _localNotes = v),
            ),

            // CPF para checkout
            if (_isCheckout) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF8E1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFFFB300)),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.security_rounded,
                        size: 16, color: Color(0xFFE65100)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Confirme o CPF do responsável para concluir a saída.',
                        style: textTheme.bodySmall?.copyWith(
                          color: const Color(0xFFBF360C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _docCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'CPF do responsável *',
                  hintText: '000.000.000-00',
                  prefixIcon: const Icon(Icons.badge_outlined),
                  errorText:
                      _localDocument.isNotEmpty && !_cpfComplete
                      ? translate('attendance.invalid_document')
                      : null,
                ),
                onChanged: (raw) {
                  final d = normalizeDigits(raw);
                  final limited = d.length > 11 ? d.substring(0, 11) : d;
                  final formatted = _formatCpf(limited);
                  if (formatted != raw) {
                    _docCtrl.value = TextEditingValue(
                      text: formatted,
                      selection:
                          TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                  setState(() => _localDocument = formatted);
                },
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(null),
          child: Text(translate('buttons.cancel')),
        ),
        FilledButton(
          onPressed: _canConfirm
              ? () => Navigator.of(context).pop({
                    'responsible': _chosen,
                    'notes': _localNotes,
                    'responsibleDocument': _localDocument,
                  })
              : null,
          child: Text(translate('buttons.next')),
        ),
      ],
    );
  }
}

// ── Dialog de confirmação final ────────────────────────────────────────────────

class _ConfirmDialog extends StatelessWidget {
  final String childName;
  final AttendanceType type;
  final String responsibleName;
  final String collaboratorName;
  final String? notes;

  const _ConfirmDialog({
    required this.childName,
    required this.type,
    required this.responsibleName,
    required this.collaboratorName,
    this.notes,
  });

  @override
  Widget build(BuildContext context) {
    final isCheckin = type == AttendanceType.checkin;

    return AlertDialog(
      title: Text(translate('attendance.confirm_attendance')),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _SummaryRow(
            icon: Icons.child_care_rounded,
            label: translate('attendance.child_label'),
            value: childName,
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            icon: isCheckin ? Icons.login_rounded : Icons.logout_rounded,
            label: translate('attendance.type_label'),
            value: isCheckin
                ? translate('home.check_in')
                : translate('home.check_out'),
            valueColor: isCheckin
                ? const Color(0xFF388E3C)
                : const Color(0xFFE65100),
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            icon: Icons.person_rounded,
            label: translate('attendance.responsible_label'),
            value: responsibleName,
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            icon: Icons.badge_rounded,
            label: translate('attendance.collaborator_label'),
            value: collaboratorName,
          ),
          if (notes != null && notes!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _SummaryRow(
              icon: Icons.notes_rounded,
              label: translate('attendance.notes_label'),
              value: notes!,
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(translate('buttons.cancel')),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: isCheckin
                ? const Color(0xFF388E3C)
                : const Color(0xFFE65100),
          ),
          child: Text(translate('buttons.confirm')),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF9AA3B5)),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF9AA3B5),
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: valueColor ?? const Color(0xFF0F1218),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Banner de alerta de saúde compacto ────────────────────────────────────────

class _HealthAlertBanner extends StatelessWidget {
  final dynamic healthInfo;
  const _HealthAlertBanner({required this.healthInfo});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    final allergies = healthInfo.allergies as List<dynamic>? ?? [];
    final meds = healthInfo.medications as List<dynamic>? ?? [];
    final restrictions = healthInfo.dietaryRestrictions as List<dynamic>? ?? [];

    if (allergies.isNotEmpty) {
      parts.add('Alergia: ${allergies.take(2).join(", ")}');
    }
    if (meds.isNotEmpty) {
      parts.add('Medicamento: ${meds.take(2).map((m) => m.name).join(", ")}');
    }
    if (restrictions.isNotEmpty) {
      parts.add('Restrição: ${restrictions.take(1).join(", ")}');
    }

    if (parts.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFFB300)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.health_and_safety_rounded,
              size: 16, color: Color(0xFFE65100)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              parts.join(' · '),
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFFBF360C),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
