import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
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

  String? selectedChildId;
  bool loading = false;

  await showDialog<void>(
    context: context,
    builder: (ctx) {
      return StatefulBuilder(builder: (innerCtx, setState) {
        final filter = childController.childFilter.toLowerCase();
        final companyId = companyController.companySelected?.id;
        final List<Child> source = type == AttendanceType.checkout
            ? (companyId != null ? childController.activeCheckedInChildren(companyId) : [])
            : childController.filteredChildren;
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
                    childController.childFilter = v;
                    setState(() {});
                  },
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: children.isEmpty
                      ? const Center(child: Text('Nenhuma criança encontrada'))
                      : Scrollbar(
                          child: ListView.separated(
                            shrinkWrap: true,
                            itemCount: children.length,
                            separatorBuilder: (_, __) => const Divider(height: 1),
                            itemBuilder: (_, i) {
                              final Child ch = children[i];
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
                        ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancelar')),
            ElevatedButton(
              onPressed: (selectedChildId == null || loading)
                  ? null
                  : () async {
                      setState(() => loading = true);

                      final child = source.firstWhere((c) => c.id == selectedChildId);

                      // For checkin: if child has multiple responsibles, or even one, ask for responsible + notes.
                      String? selectedResponsibleId;
                      String? notes;
                      if (type == AttendanceType.checkin) {
                        final userController = GetIt.I<UserController>();
                        final responsibles = child?.responsibleUserIds ?? [];
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
                        final childName = child?.name ?? selectedChildId ?? '-';
                        final responsibleName = selectedResponsibleId != null ? GetIt.I<UserController>().getUserById(selectedResponsibleId!)?.name ?? selectedResponsibleId : (collaboratorController.loggedCollaborator?.name ?? '-');
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
                              if (type == AttendanceType.checkin) Text('Responsável: $responsibleName'),
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
                        final attendance = Attendance(
                          companyId: companyController.companySelected?.id,
                          collaboratorCheckedInId: type == AttendanceType.checkin ? collaboratorController.loggedCollaborator?.id : null,
                          collaboratorCheckedOutId: type == AttendanceType.checkout ? collaboratorController.loggedCollaborator?.id : null,
                          childId: selectedChildId,
                          responsibleId: type == AttendanceType.checkin ? selectedResponsibleId : null,
                          notes: notes,
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
