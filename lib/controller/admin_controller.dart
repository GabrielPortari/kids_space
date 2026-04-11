import 'package:flutter/foundation.dart';

import '../model/admin.dart';
import '../service/admin_service.dart';

class AdminController extends ChangeNotifier {
  final AdminService _service = AdminService();

  List<Admin> _admins = [];
  bool refreshLoading = false;
  String? lastError;

  String searchFilter = '';
  bool? activeFilter;

  List<Admin> get admins => _admins;

  List<Admin> get filteredAdmins {
    final q = searchFilter.trim().toLowerCase();
    final active = activeFilter;

    return _admins.where((a) {
      final name = (a.name ?? '').toLowerCase();
      final email = (a.email ?? '').toLowerCase();
      final document = (a.document ?? '').toLowerCase();
      final matchesText =
          q.isEmpty ||
          name.contains(q) ||
          email.contains(q) ||
          document.contains(q);
      final matchesActive = active == null || a.active == active;
      return matchesText && matchesActive;
    }).toList();
  }

  Future<void> refreshAdmins() async {
    refreshLoading = true;
    lastError = null;
    notifyListeners();
    try {
      final data = await _service.list(active: activeFilter);
      _admins = data
          .map((e) => Admin.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (e) {
      _admins = [];
      lastError = e.toString();
    } finally {
      refreshLoading = false;
      notifyListeners();
    }
  }

  Future<Admin?> getAdminById(String id) async {
    try {
      final data = await _service.getById(id);
      if (data == null) return null;
      final admin = Admin.fromJson(data);
      final idx = _admins.indexWhere((a) => a.id == admin.id);
      if (idx == -1) {
        _admins.insert(0, admin);
      } else {
        _admins[idx] = admin;
      }
      notifyListeners();
      return admin;
    } catch (e) {
      lastError = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Admin?> createAdmin(Map<String, dynamic> payload) async {
    try {
      final data = await _service.create(payload);
      final admin = Admin.fromJson(data);
      _admins.insert(0, admin);
      lastError = null;
      notifyListeners();
      return admin;
    } catch (e) {
      lastError = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<Admin?> updateAdmin(String id, Map<String, dynamic> payload) async {
    try {
      final data = await _service.update(id, payload);
      final admin = Admin.fromJson(data);
      final idx = _admins.indexWhere((a) => a.id == id);
      if (idx != -1) {
        _admins[idx] = admin;
      }
      lastError = null;
      notifyListeners();
      return admin;
    } catch (e) {
      lastError = e.toString();
      notifyListeners();
      return null;
    }
  }

  Future<bool> deleteAdmin(String id) async {
    try {
      final ok = await _service.delete(id);
      if (ok) {
        _admins.removeWhere((a) => a.id == id);
      }
      lastError = null;
      notifyListeners();
      return ok;
    } catch (e) {
      lastError = e.toString();
      notifyListeners();
      return false;
    }
  }
}
