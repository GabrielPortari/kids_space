import 'package:flutter/foundation.dart';
import '../service/parent_service.dart';
import '../model/parent.dart';

class ParentController extends ChangeNotifier {
  final ParentService _service = ParentService();

  List<Parent> _parents = [];
  String userFilter = '';
  bool refreshLoading = false;
  String? lastError;
  String? selectedUserId;

  List<Parent> get parents => _parents;

  List<Parent> get filteredUsers {
    final q = userFilter.trim().toLowerCase();
    if (q.isEmpty) return _parents;
    return _parents.where((p) {
      final name = p.name?.toLowerCase() ?? '';
      final email = p.email?.toLowerCase() ?? '';
      final doc = p.document?.toLowerCase() ?? '';
      return name.contains(q) || email.contains(q) || doc.contains(q);
    }).toList();
  }

  Parent? getUserById(String? id) {
    if (id == null) return null;
    try {
      return _parents.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> refreshUsersForCompany(String? companyId) async {
    refreshLoading = true;
    notifyListeners();
    try {
      final data = await _service.list();
      final list = data
          .map((e) => Parent.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      if (companyId != null && companyId.isNotEmpty) {
        _parents = list.where((p) => p.companyId == companyId).toList();
      } else {
        _parents = list;
      }
      lastError = null;
    } catch (e) {
      // capture and expose error (avoid crashing the app)
      // ignore: avoid_print
      print('ParentController.refreshUsersForCompany error: $e');
      lastError = e.toString();
      _parents = [];
    } finally {
      refreshLoading = false;
      notifyListeners();
    }
  }

  Future<Parent?> fetchUserById(String id) async {
    final cached = getUserById(id);
    if (cached != null) return cached;
    final res = await _service.getById(id);
    if (res == null) return null;
    final p = Parent.fromJson(Map<String, dynamic>.from(res));
    _parents.add(p);
    notifyListeners();
    return p;
  }

  Future<bool> createUser(Parent p) async {
    final payload = p.toJson();
    final res = await _service.create(payload);
    final created = Parent.fromJson(Map<String, dynamic>.from(res));
    _parents.insert(0, created);
    notifyListeners();
    return true;
  }

  Future<bool> updateUser(Parent p) async {
    if (p.id == null) return false;
    final payload = p.toJson();
    final res = await _service.update(p.id!, payload);
    final updated = Parent.fromJson(Map<String, dynamic>.from(res));
    final idx = _parents.indexWhere((x) => x.id == updated.id);
    if (idx != -1) _parents[idx] = updated;
    notifyListeners();
    return true;
  }

  Future<bool> deleteUser(String id) async {
    final ok = await _service.delete(id);
    if (ok) {
      _parents.removeWhere((p) => p.id == id);
      notifyListeners();
    }
    return ok;
  }
}
