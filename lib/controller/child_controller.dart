import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import '../service/child_service.dart';
import '../model/child.dart';
import '../model/parent.dart';
import 'attendance_controller.dart';
import 'parent_controller.dart';

class ChildController extends ChangeNotifier {
  final ChildService _service = ChildService();
  List<Child> _children = [];

  String childFilter = '';
  bool refreshLoading = false;

  List<Child> get children => _children;

  List<Child> get filteredChildren {
    final q = childFilter.trim().toLowerCase();
    if (q.isEmpty) return _children;
    return _children.where((c) {
      final name = c.name?.toLowerCase() ?? '';
      final email = c.email?.toLowerCase() ?? '';
      final doc = c.document?.toLowerCase() ?? '';
      return name.contains(q) || email.contains(q) || doc.contains(q);
    }).toList();
  }

  Future<void> refreshChildren() async {
    final data = await _service.list();
    _children = data
        .map((e) => Child.fromJson(Map<String, dynamic>.from(e)))
        .toList();
    notifyListeners();
  }

  Future<void> refreshChildrenForCompany(String? companyId) async {
    refreshLoading = true;
    notifyListeners();
    try {
      final data = await _service.list();
      final list = data
          .map((e) => Child.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      // mark checkedIn based on attendance active checkins
      final attendance = GetIt.I<AttendanceController>();
      final activeIds = attendance.activeCheckins
          .where((a) => a.childId != null)
          .map((a) => a.childId!)
          .toSet();

      final enriched = list
          .map((c) => c.copyWith(checkedIn: activeIds.contains(c.id)))
          .toList();

      if (companyId != null && companyId.isNotEmpty) {
        _children = enriched.where((c) => c.companyId == companyId).toList();
      } else {
        _children = enriched;
      }
    } finally {
      refreshLoading = false;
      notifyListeners();
    }
  }

  Future<Child?> fetchChildById(String id) async {
    try {
      final cached = _children.firstWhere((c) => c.id == id);
      return cached;
    } catch (_) {}
    final res = await _service.getById(id);
    if (res == null) return null;
    final c = Child.fromJson(Map<String, dynamic>.from(res));
    _children.add(c);
    notifyListeners();
    return c;
  }

  /// Synchronous cached lookup for a child by id. Returns null if not cached.
  Child? getChildById(String? id) {
    if (id == null) return null;
    try {
      return _children.firstWhere((c) => c.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Async lookup that fetches from server if not present in cache.
  Future<Child?> getChildByIdAsync(String id) async => await fetchChildById(id);

  Future<Child> createChild(Map<String, dynamic> payload) async {
    final data = await _service.create(payload);
    final child = Child.fromJson(data);
    _children.add(child);
    notifyListeners();
    return child;
  }

  Future<bool> updateChild(Child c) async {
    if (c.id == null) return false;
    final payload = c.toJson();
    final res = await _service.update(c.id!, payload);
    final updated = Child.fromJson(Map<String, dynamic>.from(res));
    final idx = _children.indexWhere((x) => x.id == updated.id);
    if (idx != -1) _children[idx] = updated;
    notifyListeners();
    return true;
  }

  Future<bool> deleteChild(String id) async {
    final ok = await _service.delete(id);
    if (ok) {
      _children.removeWhere((c) => c.id == id);
      notifyListeners();
    }
    return ok;
  }

  /// Returns children that are currently checked-in for the given company
  List<Child> activeCheckedInChildren(String? companyId) {
    if (companyId == null) return [];
    final attendance = GetIt.I<AttendanceController>();
    final active = attendance.activeCheckins
        .where((e) => e.checkOutTime == null && e.childId != null)
        .map((e) => e.childId!)
        .toSet();
    return _children
        .where(
          (c) =>
              c.id != null && active.contains(c.id) && c.companyId == companyId,
        )
        .toList();
  }

  /// A computed-style variant used by some widgets for synchronous access
  List<Child> activeCheckedInChildrenComputed(String? companyId) =>
      activeCheckedInChildren(companyId);

  /// Build a map childId -> list of Parent (responsibles) using cached parents
  Map<String, List<Parent>> getChildrenWithResponsibles(List<Child> list) {
    final parentCtrl = GetIt.I<ParentController>();
    final Map<String, List<Parent>> map = {};
    for (final c in list) {
      final ids = c.parents ?? [];
      final res = <Parent>[];
      for (final id in ids) {
        final p = parentCtrl.getUserById(id);
        if (p != null) res.add(p);
      }
      map[c.id ?? ''] = res;
    }
    return map;
  }
}
