import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:kids_space/controller/child_controller.dart';
import 'package:kids_space/controller/attendance_controller.dart';
import 'package:kids_space/controller/collaborator_controller.dart';
import 'package:kids_space/controller/company_controller.dart';
import 'package:kids_space/controller/user_controller.dart';
import 'package:kids_space/model/attendance.dart';
import 'package:kids_space/model/child.dart';

Future<void> showAttendanceModal(BuildContext context, AttendanceType type) async {
  final ChildController childController = GetIt.I<ChildController>();
  final AttendanceController attendanceController = GetIt.I<AttendanceController>();
  final collaboratorController = GetIt.I<CollaboratorController>();
  final companyController = GetIt.I<CompanyController>();

  final companyId = companyController.companySelected?.id;
  if (companyId != null) {
    // trigger load of active checkins so UI can react when data arrives
    attendanceController.loadActiveCheckinsForCompany(companyId);
  }

  String? selectedChildId;
  bool loading = false;

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(builder: (innerCtx, setState) {
        final filter = childController.childFilter.toLowerCase();
        final companyId = companyController.companySelected?.id;
        // Use computed active checked-in children from controller when available
        final List<Child> activeChildren = companyId != null ? childController.activeCheckedInChildrenComputed(companyId) : [];
        final List<Child> source = type == AttendanceType.checkout
          ? activeChildren
          : // For checkin, exclude children that are already active (checked-in)
          childController.filteredChildren.where((ch) => !(ch.id != null && activeChildren.map((c) => c.id).contains(ch.id))).toList();
        final children = source.where((ch) {
          if (filter.isEmpty) return true;
          final name = ch.name?.toLowerCase() ?? '';
          final email = ch.email?.toLowerCase() ?? '';
          final doc = ch.document?.toLowerCase() ?? '';
          return name.contains(filter) || email.contains(filter) || doc.contains(filter);
        }).toList();
        final screenHeight = MediaQuery.of(innerCtx).size.height;
        return AlertDialog(
          insetPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          title: Text(type == AttendanceType.checkin ? 'Check-in' : 'Check-out'),
          content: SizedBox(
            width: double.maxFinite,
            height: screenHeight * 0.85,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: 'Buscar criança',
                  ),
                  onChanged: (v) {
                    // update observable filter; Observer will react
                    childController.childFilter = v;
                    setState(() {}); // keep selection redraw
                  },
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: Observer(builder: (_) {
                    // compute active children from attendanceController.activeCheckins
                    final activeAttendances = attendanceController.activeCheckins ?? [];
                    final activeIds = activeAttendances.map((a) => a.childId).whereType<String>().toSet();
                    final List<Child> activeChildren = companyId != null
                        ? childController.children.where((c) => c.id != null && activeIds.contains(c.id)).toList()
                        : <Child>[];

                    // compute source depending on type
                    final List<Child> source = type == AttendanceType.checkout
                        ? activeChildren
                        : childController.filteredChildren.where((ch) => !(ch.id != null && activeIds.contains(ch.id))).toList();

                    if (source.isEmpty) return const Center(child: Text('Nenhuma criança encontrada'));

                    return Scrollbar(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: source.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final Child ch = source[i];
                          final id = ch.id ?? '';
                          return RadioListTile<String>(
                            value: id,
                            groupValue: selectedChildId,
                            onChanged: (v) => setState(() => selectedChildId = v),
                            title: Text(ch.name ?? '-'),
                            subtitle: Text(ch.document ?? ''),
                          );
                        },
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: (){
              childController.childFilter = '';
              Navigator.of(ctx).pop();
            }, child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: (selectedChildId == null || loading)
                  ? null
                  : () async {
                      setState(() => loading = true);

                      // Recompute the current source to match the list shown inside the Observer
                      final activeAttendances = attendanceController.activeCheckins ?? [];
                      final activeIds = activeAttendances.map((a) => a.childId).whereType<String>().toSet();
                      final List<Child> currentSource = type == AttendanceType.checkout
                          ? (companyId != null ? childController.children.where((c) => c.id != null && activeIds.contains(c.id)).toList() : <Child>[])
                          : childController.filteredChildren.where((ch) => !(ch.id != null && activeIds.contains(ch.id))).toList();

                      final idx = currentSource.indexWhere((c) => c.id == selectedChildId);
                      if (idx == -1) {
                        setState(() => loading = false);
                        return;
                      }
                      final child = currentSource[idx];

                      // Ask for responsible and notes for both checkin and checkout flows.
                      String? selectedResponsibleId;
                      String? notes;
                      final userController = GetIt.I<UserController>();
                      if (type == AttendanceType.checkin || type == AttendanceType.checkout) {
                        // For checkout, prefer responsibleIds from active checkins for this child
                        List<String> responsibles = [];
                        if (type == AttendanceType.checkin) {
                          responsibles = child.responsibleUserIds ?? [];
                        } else {
                          final active = attendanceController.activeCheckins ?? [];
                          responsibles = active.where((a) => a.childId == child.id).map((a) => a.responsibleId).whereType<String>().toSet().toList();
                          if (responsibles.isEmpty) {
                            responsibles = child.responsibleUserIds ?? [];
                          }
                        }

                        // show dialog to select responsible and input notes (preselect when single)
                        final result = await showDialog<Map<String, String?>>(context: innerCtx, builder: (rc) {
                          String? chosen = responsibles.length == 1 ? responsibles.first : null;
                          String localNotes = '';
                          return StatefulBuilder(builder: (rcCtx, rcSetState) {
                            return AlertDialog(
                              title: const Text('Responsável e Observações'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (responsibles.isNotEmpty) ...[
                                      const Align(alignment: Alignment.centerLeft, child: Text('Selecione o responsável:')),
                                      const SizedBox(height: 8),
                                      ConstrainedBox(
                                        constraints: BoxConstraints(maxHeight: MediaQuery.of(rcCtx).size.height * 0.3),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: responsibles.length,
                                          itemBuilder: (_, idx) {
                                            final rid = responsibles[idx];
                                            final name = userController.getUserById(rid)?.name ?? rid;
                                            return RadioListTile<String>(
                                              value: rid,
                                              groupValue: chosen,
                                              onChanged: (v) => rcSetState(() => chosen = v),
                                              title: Text(name),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                    const SizedBox(height: 8),
                                    TextField(
                                      decoration: const InputDecoration(hintText: 'Observações (opcional)'),
                                      maxLines: 3,
                                      onChanged: (v) => localNotes = v,
                                    ),
                                  ],
                                ),
                              ),
                              actions: [
                                TextButton(onPressed: () => Navigator.of(rc).pop(null), child: const Text('Cancelar')),
                                ElevatedButton(onPressed: () => Navigator.of(rc).pop({'responsible': chosen, 'notes': localNotes}), child: const Text('Próximo')),
                              ],
                            );
                          });
                        });

                        if (result == null) {
                          // user cancelled
                          setState(() => loading = false);
                          return;
                        }
                        selectedResponsibleId = result['responsible'];
                        notes = result['notes'];
                      }

                      // Confirmation dialog
                      final confirm = await showDialog<bool>(context: innerCtx, builder: (cc) {
                        final childName = child.name ?? selectedChildId ?? '-';
                        final responsibleName = selectedResponsibleId != null ? GetIt.I<UserController>().getUserById(selectedResponsibleId)?.name ?? selectedResponsibleId : (collaboratorController.loggedCollaborator?.name ?? '-');
                        return AlertDialog(
                          title: const Text('Confirmar presença'),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Criança: $childName'),
                              const SizedBox(height: 8),
                              Text('Tipo: ${type == AttendanceType.checkin ? 'Check-in' : 'Check-out'}'),
                              const SizedBox(height: 8),
                              Text('Responsável: $responsibleName'),
                              const SizedBox(height: 8),
                              Text('Colaborador: ${collaboratorController.loggedCollaborator?.name ?? '-'}'),
                              const SizedBox(height: 8),
                              if (notes != null && notes.isNotEmpty) Text('Observações: $notes'),
                            ],
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(cc).pop(false), child: const Text('Cancelar')),
                            ElevatedButton(onPressed: () => Navigator.of(cc).pop(true), child: const Text('Confirmar')),
                          ],
                        );
                      });

                      bool ok = false;
                      if (confirm == true) {
                        // Build notes string: append identifiers and concat with existing checkin notes on checkout
                        String? notesPayload;
                        final entered = notes?.trim();
                        if (type == AttendanceType.checkin) {
                          notesPayload = (entered != null && entered.isNotEmpty) ? '$entered (checkin)' : null;
                        } else {
                          // checkout: try to find existing active checkin note for this child
                          final active = attendanceController.activeCheckins ?? [];
                          Attendance? existing;
                          try {
                            existing = active.firstWhere((a) => a.childId == selectedChildId);
                          } catch (_) {
                            existing = null;
                          }
                          final existingNotes = existing?.notes?.trim();
                          if (existingNotes != null && existingNotes.isNotEmpty && entered != null && entered.isNotEmpty) {
                            // if existing already contains identifier, avoid duplicating
                            final left = existingNotes.contains('(checkin)') ? existingNotes : '$existingNotes (checkin)';
                            notesPayload = '$left - $entered (checkout)';
                          } else if (existingNotes != null && existingNotes.isNotEmpty) {
                            notesPayload = existingNotes.contains('(checkin)') ? existingNotes : '$existingNotes (checkin)';
                          } else if (entered != null && entered.isNotEmpty) {
                            notesPayload = '$entered (checkout)';
                          } else {
                            notesPayload = null;
                          }
                        }

                        final attendance = Attendance(
                          companyId: collaboratorController.loggedCollaborator?.companyId,
                          collaboratorCheckedInId: type == AttendanceType.checkin ? collaboratorController.loggedCollaborator?.id : null,
                          collaboratorCheckedOutId: type == AttendanceType.checkout ? collaboratorController.loggedCollaborator?.id : null,
                          childId: selectedChildId,
                          responsibleId: selectedResponsibleId,
                          notes: notesPayload,
                        );

                        try {
                          if (type == AttendanceType.checkin) {
                            ok = await attendanceController.doCheckin(attendance);
                          } else {
                            ok = await attendanceController.doCheckout(attendance);
                          }
                        } catch (_) {
                          ok = false;
                        }
                      }

                      setState(() => loading = false);
                      if (!ctx.mounted) return;
                      Navigator.of(ctx).pop();
                      if (!innerCtx.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(ok ? 'Presença registrada' : 'Operação cancelada/erro')),
                      );
                    },
              child: loading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Confirmar'),
            ),
          ],
        );
      });
    },
  );
}
