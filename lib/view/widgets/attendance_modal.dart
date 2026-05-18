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
  final ChildController childController = GetIt.I<ChildController>();
  final AttendanceController attendanceController =
      GetIt.I<AttendanceController>();
  final collaboratorController = GetIt.I<CollaboratorController>();
  final companyController = GetIt.I<CompanyController>();

  final companyId = companyController.company?.id;
  if (companyId != null) {
    // trigger load of active checkins so UI can react when data arrives
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
          final companyId = companyController.company?.id;
          final activeIds = attendanceController.activeCheckins
              .map((a) => a.childId)
              .whereType<String>()
              .toSet();
          final List<Child> source = type == AttendanceType.checkout
              ? (companyId != null
                    ? childController.children
                          .where(
                            (ch) => ch.id != null && activeIds.contains(ch.id),
                          )
                          .toList()
                    : <Child>[])
              : childController.filteredChildren
                    .where(
                      (ch) => !(ch.id != null && activeIds.contains(ch.id)),
                    )
                    .toList();
          final filteredSource = source.where((ch) {
            if (filter.isEmpty) return true;
            final name = ch.name?.toLowerCase() ?? '';
            final email = ch.email?.toLowerCase() ?? '';
            final doc = ch.document?.toLowerCase() ?? '';
            return name.contains(filter) ||
                email.contains(filter) ||
                doc.contains(filter);
          }).toList();
          final screenHeight = MediaQuery.of(innerCtx).size.height;
          return AlertDialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 8.0,
            ),
            title: Text(
              type == AttendanceType.checkin
                  ? translate('home.check_in')
                  : translate('home.check_out'),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: screenHeight * 0.85,
              child: Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search),
                      hintText: translate('attendance.search_child'),
                    ),
                    onChanged: (v) {
                      // update observable filter; Observer will react
                      childController.childFilter = v;
                      setState(() {}); // keep selection redraw
                    },
                  ),
                  const SizedBox(height: 12),
                  Flexible(
                    child: filteredSource.isEmpty
                        ? Center(
                            child: Text(
                              translate('attendance.no_children_found'),
                            ),
                          )
                        : Scrollbar(
                            child: ListView.separated(
                              shrinkWrap: true,
                              itemCount: filteredSource.length,
                              separatorBuilder: (_, __) =>
                                  const Divider(height: 1),
                              itemBuilder: (_, i) {
                                final Child ch = filteredSource[i];
                                final id = ch.id ?? '';
                                return RadioListTile<String>(
                                  value: id,
                                  groupValue: selectedChildId,
                                  onChanged: (v) =>
                                      setState(() => selectedChildId = v),
                                  title: Text(ch.name ?? '-'),
                                  subtitle: Text(ch.document ?? ''),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  childController.childFilter = '';
                  Navigator.of(ctx).pop();
                },
                child: Text(translate('buttons.cancel')),
              ),
              ElevatedButton(
                onPressed: (selectedChildId == null || loading)
                    ? null
                    : () async {
                        setState(() => loading = true);

                        // Recompute the current source to match the list shown inside the Observer
                        final activeIds = attendanceController.activeCheckins
                            .map((a) => a.childId)
                            .whereType<String>()
                            .toSet();
                        final List<Child> currentSource =
                            type == AttendanceType.checkout
                            ? (companyId != null
                                  ? childController.children
                                        .where(
                                          (c) =>
                                              c.id != null &&
                                              activeIds.contains(c.id),
                                        )
                                        .toList()
                                  : <Child>[])
                            : childController.filteredChildren
                                  .where(
                                    (ch) =>
                                        !(ch.id != null &&
                                            activeIds.contains(ch.id)),
                                  )
                                  .toList();

                        final idx = currentSource.indexWhere(
                          (c) => c.id == selectedChildId,
                        );
                        if (idx == -1) {
                          setState(() => loading = false);
                          return;
                        }
                        final child = currentSource[idx];

                        // Ask for responsible and notes for both checkin and checkout flows.
                        String? selectedResponsibleId;
                        String? notes;
                        String? typedResponsibleDocument;
                        final userController = GetIt.I<ParentController>();
                        if (type == AttendanceType.checkin ||
                            type == AttendanceType.checkout) {
                          // For checkout, prefer responsibleIds from active checkins for this child
                          List<String> parents = [];
                          if (type == AttendanceType.checkin) {
                            parents = child.parents ?? [];
                          } else {
                            final active = attendanceController.activeCheckins;
                            parents = active
                                .where(
                                  (a) =>
                                      (a.childSnapshot ?? a.childId) ==
                                      child.id,
                                )
                                .map(
                                  (a) =>
                                      a.responsibleCheckedInSnapshot ??
                                      a.parentIdWhoCheckedInId,
                                )
                                .whereType<String>()
                                .toSet()
                                .toList();
                            if (parents.isEmpty) {
                              parents = child.parents ?? [];
                            }
                          }

                          // show dialog to select responsible and input notes (preselect when single)
                          final result = await showDialog<Map<String, String?>>(
                            context: innerCtx,
                            builder: (rc) {
                              String? chosen = parents.length == 1
                                  ? parents.first
                                  : null;
                              String localNotes = '';
                              String localDocument = '';
                              final TextEditingController
                              localDocumentController = TextEditingController();
                              String formatCpf(String v) {
                                final d = normalizeDigits(v);
                                final len = d.length;
                                if (len <= 3) return d;
                                if (len <= 6)
                                  return '${d.substring(0, 3)}.${d.substring(3)}';
                                if (len <= 9)
                                  return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6)}';
                                return '${d.substring(0, 3)}.${d.substring(3, 6)}.${d.substring(6, 9)}-${d.substring(9)}';
                              }

                              // formatting will be applied in the TextField.onChanged
                              return StatefulBuilder(
                                builder: (rcCtx, rcSetState) {
                                  return AlertDialog(
                                    title: Text(
                                      translate(
                                        'attendance.responsible_and_notes',
                                      ),
                                    ),
                                    content: SizedBox(
                                      width: double.maxFinite,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          if (parents.isNotEmpty) ...[
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                translate(
                                                  'attendance.select_responsible',
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 8),
                                            ConstrainedBox(
                                              constraints: BoxConstraints(
                                                maxHeight:
                                                    MediaQuery.of(
                                                      rcCtx,
                                                    ).size.height *
                                                    0.3,
                                              ),
                                              child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: parents.length,
                                                itemBuilder: (_, idx) {
                                                  final rid = parents[idx];
                                                  final name =
                                                      userController
                                                          .getUserById(rid)
                                                          ?.name ??
                                                      rid;
                                                  return RadioListTile<String>(
                                                    value: rid,
                                                    groupValue: chosen,
                                                    onChanged: (v) =>
                                                        rcSetState(
                                                          () => chosen = v,
                                                        ),
                                                    title: Text(name),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                          const SizedBox(height: 8),
                                          TextField(
                                            decoration: InputDecoration(
                                              hintText: translate(
                                                'attendance.notes_optional',
                                              ),
                                            ),
                                            maxLines: 3,
                                            onChanged: (v) => localNotes = v,
                                          ),
                                          const SizedBox(height: 8),
                                          if (type == AttendanceType.checkout)
                                            TextField(
                                              controller:
                                                  localDocumentController,
                                              decoration: InputDecoration(
                                                hintText: translate(
                                                  'attendance.responsible_document_placeholder',
                                                ),
                                                helperText: translate(
                                                  'attendance.responsible_document_helper',
                                                ),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (raw) {
                                                final digits = normalizeDigits(
                                                  raw,
                                                );
                                                final limited =
                                                    digits.length > 11
                                                    ? digits.substring(0, 11)
                                                    : digits;
                                                final formatted = formatCpf(
                                                  limited,
                                                );
                                                if (formatted != raw) {
                                                  localDocumentController
                                                      .value = TextEditingValue(
                                                    text: formatted,
                                                    selection:
                                                        TextSelection.collapsed(
                                                          offset:
                                                              formatted.length,
                                                        ),
                                                  );
                                                }
                                                rcSetState(
                                                  () =>
                                                      localDocument = formatted,
                                                );
                                              },
                                            ),
                                          if (type == AttendanceType.checkout)
                                            const SizedBox(height: 8),
                                          if (type == AttendanceType.checkout &&
                                              localDocument.isNotEmpty &&
                                              normalizeDigits(
                                                    localDocument,
                                                  ).length !=
                                                  11)
                                            Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                translate(
                                                  'attendance.invalid_document',
                                                ),
                                                style: TextStyle(
                                                  color: Theme.of(
                                                    rcCtx,
                                                  ).colorScheme.error,
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.of(rc).pop(null),
                                        child: Text(
                                          translate('buttons.cancel'),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed:
                                            (type == AttendanceType.checkout &&
                                                normalizeDigits(
                                                      localDocument,
                                                    ).length !=
                                                    11)
                                            ? null
                                            : () => Navigator.of(rc).pop({
                                                'responsible': chosen,
                                                'notes': localNotes,
                                                'responsibleDocument':
                                                    localDocument,
                                              }),
                                        child: Text(translate('buttons.next')),
                                      ),
                                    ],
                                  );
                                },
                              );
                            },
                          );

                          if (result == null) {
                            // user cancelled
                            setState(() => loading = false);
                            return;
                          }
                          selectedResponsibleId = result['responsible'];
                          notes = result['notes'];
                          typedResponsibleDocument =
                              result['responsibleDocument'];
                        }

                        // Confirmation dialog
                        final confirm = await showDialog<bool>(
                          context: innerCtx,
                          builder: (cc) {
                            final childName =
                                child.name ?? selectedChildId ?? '-';
                            final responsibleName =
                                selectedResponsibleId != null
                                ? GetIt.I<ParentController>()
                                          .getUserById(selectedResponsibleId)
                                          ?.name ??
                                      selectedResponsibleId
                                : (collaboratorController
                                          .loggedCollaborator
                                          ?.name ??
                                      '-');
                            return AlertDialog(
                              title: Text(
                                translate('attendance.confirm_attendance'),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${translate('attendance.child_label')}: $childName',
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${translate('attendance.type_label')}: ${type == AttendanceType.checkin ? translate('home.check_in') : translate('home.check_out')}',
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${translate('attendance.responsible_label')}: $responsibleName',
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${translate('attendance.collaborator_label')}: ${collaboratorController.loggedCollaborator?.name ?? '-'}',
                                  ),
                                  const SizedBox(height: 8),
                                  if (notes != null && notes.isNotEmpty)
                                    Text(
                                      '${translate('attendance.notes_label')}: $notes',
                                    ),
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(cc).pop(false),
                                  child: Text(translate('buttons.cancel')),
                                ),
                                ElevatedButton(
                                  onPressed: () => Navigator.of(cc).pop(true),
                                  child: Text(translate('buttons.confirm')),
                                ),
                              ],
                            );
                          },
                        );

                        bool ok = false;
                        if (confirm == true) {
                          try {
                            if (type == AttendanceType.checkin) {
                              // Build payload according to backend contract
                              final res = await attendanceController.checkin({
                                'childId': child.id,
                                if (selectedResponsibleId != null)
                                  'responsibleIdWhoCheckedInId':
                                      selectedResponsibleId,
                                if (notes != null && notes.isNotEmpty)
                                  'notes': notes,
                                if (companyId != null && companyId.isNotEmpty)
                                  'companyId': companyId,
                              });
                              ok = (res.id != null);
                            } else {
                              String? responsibleDocument;
                              // Prefer document typed by the operator in the dialog
                              if (selectedResponsibleId != null) {
                                // try to get typed document from dialog result
                                // `selectedResponsibleDocument` is in scope above
                                // but not here; recompute from result map instead
                                // If dialog provided a document, use it; otherwise
                                // fallback to parent's stored document.
                                final parent = GetIt.I<ParentController>()
                                    .getUserById(selectedResponsibleId);
                                responsibleDocument = parent?.document;
                              }
                              // If dialog returned an explicit document, override
                              // (result variable available above as selectedResponsibleDocument)
                              if (typedResponsibleDocument != null &&
                                  typedResponsibleDocument.isNotEmpty) {
                                responsibleDocument = typedResponsibleDocument;
                              }
                              final checkoutPayload = <String, dynamic>{
                                'childId': child.id,
                                if (responsibleDocument != null &&
                                    responsibleDocument.isNotEmpty)
                                  'responsibleDocument': normalizeDigits(
                                    responsibleDocument,
                                  ),
                                if (notes != null && notes.isNotEmpty)
                                  'notes': notes,
                                if (companyId != null && companyId.isNotEmpty)
                                  'companyId': companyId,
                              };
                              final res = await attendanceController.checkout(
                                checkoutPayload,
                              );
                              ok = (res.id != null || res.checkOutTime != null);
                            }
                          } catch (_) {
                            ok = false;
                          }
                        }

                        setState(() => loading = false);
                        if (!ctx.mounted) return;
                        Navigator.of(ctx).pop();

                        // Trigger background refreshes so the UI reflects the
                        // newly created checkin without blocking the flow.
                        if (companyId != null) {
                          attendanceController.loadActiveCheckinsForCompany(
                            companyId,
                          );
                          attendanceController.loadLast10AttendancesForCompany(
                            companyId,
                          );
                          attendanceController
                              .loadLastCheckinAndCheckoutForCompany(companyId);
                          childController.refreshChildrenForCompany(companyId);
                        }

                        if (!innerCtx.mounted) return;
                        final successMsg = type == AttendanceType.checkin
                            ? 'Checkin realizado com sucesso'
                            : 'Checkout realizado com sucesso';
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              ok
                                  ? successMsg
                                  : translate('attendance.operation_error'),
                            ),
                          ),
                        );
                      },
                child: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(translate('buttons.confirm')),
              ),
            ],
          );
        },
      );
    },
  );
}
