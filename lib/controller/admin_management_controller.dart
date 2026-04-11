import 'package:flutter/foundation.dart';

import '../model/attendance.dart';
import '../model/child.dart';
import '../model/collaborator.dart';
import '../model/parent.dart';
import '../service/admin_management_service.dart';

class AdminManagementController extends ChangeNotifier {
  final AdminManagementService _service = AdminManagementService();

  bool loading = false;
  String? lastError;

  Map<String, dynamic>? companyOverview;
  List<Collaborator> allCollaborators = [];
  List<Parent> allParents = [];
  List<Child> allChildren = [];
  List<Attendance> allAttendances = [];

  Future<void> _run(Future<void> Function() action) async {
    loading = true;
    lastError = null;
    notifyListeners();
    try {
      await action();
    } catch (e) {
      lastError = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  Future<void> loadCompanyOverview(String companyId) async {
    await _run(() async {
      companyOverview = await _service.getCompanyOverview(companyId);
    });
  }

  Future<Collaborator?> createCollaborator(
    String companyId,
    Map<String, dynamic> payload,
  ) async {
    Collaborator? created;
    await _run(() async {
      final data = await _service.createCollaborator(companyId, payload);
      created = Collaborator.fromJson(data);
    });
    return created;
  }

  Future<Collaborator?> updateCollaborator(
    String companyId,
    String collaboratorId,
    Map<String, dynamic> payload,
  ) async {
    Collaborator? updated;
    await _run(() async {
      final data = await _service.updateCollaborator(
        companyId,
        collaboratorId,
        payload,
      );
      updated = Collaborator.fromJson(data);
    });
    return updated;
  }

  Future<bool> deleteCollaborator(
    String companyId,
    String collaboratorId,
  ) async {
    bool ok = false;
    await _run(() async {
      ok = await _service.deleteCollaborator(companyId, collaboratorId);
    });
    return ok;
  }

  Future<Parent?> createParent(
    String companyId,
    Map<String, dynamic> payload,
  ) async {
    Parent? created;
    await _run(() async {
      final data = await _service.createParent(companyId, payload);
      created = Parent.fromJson(data);
    });
    return created;
  }

  Future<Parent?> updateParent(
    String companyId,
    String parentId,
    Map<String, dynamic> payload,
  ) async {
    Parent? updated;
    await _run(() async {
      final data = await _service.updateParent(companyId, parentId, payload);
      updated = Parent.fromJson(data);
    });
    return updated;
  }

  Future<bool> deleteParent(String companyId, String parentId) async {
    bool ok = false;
    await _run(() async {
      ok = await _service.deleteParent(companyId, parentId);
    });
    return ok;
  }

  Future<Child?> createChild(
    String companyId,
    Map<String, dynamic> payload,
  ) async {
    Child? created;
    await _run(() async {
      final data = await _service.createChild(companyId, payload);
      created = Child.fromJson(data);
    });
    return created;
  }

  Future<Child?> updateChild(
    String companyId,
    String childId,
    Map<String, dynamic> payload,
  ) async {
    Child? updated;
    await _run(() async {
      final data = await _service.updateChild(companyId, childId, payload);
      updated = Child.fromJson(data);
    });
    return updated;
  }

  Future<bool> deleteChild(String companyId, String childId) async {
    bool ok = false;
    await _run(() async {
      ok = await _service.deleteChild(companyId, childId);
    });
    return ok;
  }

  Future<Attendance?> createAttendanceCheckin(
    String companyId,
    Map<String, dynamic> payload,
  ) async {
    Attendance? created;
    await _run(() async {
      final data = await _service.createAttendanceCheckin(companyId, payload);
      created = Attendance.fromJson(data);
    });
    return created;
  }

  Future<Attendance?> updateAttendance(
    String companyId,
    String attendanceId,
    Map<String, dynamic> payload,
  ) async {
    Attendance? updated;
    await _run(() async {
      final data = await _service.updateAttendance(
        companyId,
        attendanceId,
        payload,
      );
      updated = Attendance.fromJson(data);
    });
    return updated;
  }

  Future<bool> deleteAttendance(String companyId, String attendanceId) async {
    bool ok = false;
    await _run(() async {
      ok = await _service.deleteAttendance(companyId, attendanceId);
    });
    return ok;
  }

  Future<void> loadAllCollaborators() async {
    await _run(() async {
      final data = await _service.listAllCollaborators();
      allCollaborators = data
          .map((e) => Collaborator.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
  }

  Future<void> loadAllParents() async {
    await _run(() async {
      final data = await _service.listAllParents();
      allParents = data
          .map((e) => Parent.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
  }

  Future<void> loadAllChildren() async {
    await _run(() async {
      final data = await _service.listAllChildren();
      allChildren = data
          .map((e) => Child.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
  }

  Future<void> loadAllAttendances() async {
    await _run(() async {
      final data = await _service.listAllAttendances();
      allAttendances = data
          .map((e) => Attendance.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    });
  }
}
