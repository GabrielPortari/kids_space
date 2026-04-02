import 'package:flutter/foundation.dart';
import 'package:get_it/get_it.dart';
import 'dart:convert';
import '../service/collaborator_service.dart';
import '../model/collaborator.dart';
import 'company_controller.dart';

class CollaboratorController extends ChangeNotifier {
  final CollaboratorService _service = CollaboratorService();
  Collaborator? _loggedCollaborator;
  List<Collaborator> _collaborators = [];
  String collaboratorFilter = '';
  bool refreshLoading = false;
  String? lastError;

  Collaborator? get loggedCollaborator => _loggedCollaborator;

  Future<Collaborator?> create(Map<String, dynamic> payload) async {
    try {
      final data = await _service.create(payload);
      _loggedCollaborator = Collaborator.fromJson(data);
      // add to cached list
      final created = _loggedCollaborator;
      if (created != null) {
        _collaborators.insert(0, created);
      }
      lastError = null;
      notifyListeners();
      return _loggedCollaborator;
    } catch (e) {
      // capture error for UI
      // ignore: avoid_print
      print('CollaboratorController.create error: $e');
      lastError = e.toString();
      notifyListeners();
      return null;
    }
  }

  List<Collaborator> get collaborators => _collaborators;

  List<Collaborator> get filteredCollaborators {
    final q = collaboratorFilter.trim().toLowerCase();
    if (q.isEmpty) return _collaborators;
    return _collaborators.where((c) {
      final name = c.name?.toLowerCase() ?? '';
      final email = c.email?.toLowerCase() ?? '';
      final doc = c.document?.toLowerCase() ?? '';
      return name.contains(q) || email.contains(q) || doc.contains(q);
    }).toList();
  }

  Future<void> refreshCollaboratorsForCompany(String? companyId) async {
    refreshLoading = true;
    lastError = null;
    notifyListeners();
    try {
      final data = await _service.list();
      final list = data
          .map((e) => Collaborator.fromJson(Map<String, dynamic>.from(e)))
          .toList();
      if (companyId != null && companyId.isNotEmpty) {
        _collaborators = list.where((c) => c.companyId == companyId).toList();
      } else {
        _collaborators = list;
      }
    } catch (e) {
      // capture error and expose to UI
      // ignore: avoid_print
      print('CollaboratorController.refreshCollaboratorsForCompany error: $e');
      lastError = e.toString();
      _collaborators = [];
    } finally {
      refreshLoading = false;
      notifyListeners();
    }
  }

  Future<Collaborator?> getCollaboratorById(String id) async {
    final cached = _loggedCollaborator?.id == id ? _loggedCollaborator : null;
    if (cached != null) return cached;
    final res = await _service.getById(id);
    if (res == null) return null;
    final c = Collaborator.fromJson(res);
    _loggedCollaborator = c;
    notifyListeners();
    return c;
  }

  Future<void> setLoggedCollaborator(Collaborator c) async {
    _loggedCollaborator = c;
    notifyListeners();
    // If collaborator belongs to a company, ensure the CompanyController
    // has the company loaded so the app can differentiate a "logged company"
    // vs a "logged collaborator" context.
    try {
      final companyId = c.companyId;
      if (companyId != null && companyId.isNotEmpty) {
        final companyController = GetIt.I.get<CompanyController>();
        await companyController.loadCompanyById(companyId);
      }
    } catch (_) {}
  }

  Future<bool> deleteCollaborator(String id) async {
    final ok = await _service.delete(id);
    if (ok) {
      if (_loggedCollaborator?.id == id) {
        _loggedCollaborator = null;
      }
      _collaborators.removeWhere((c) => c.id == id);
      notifyListeners();
    }
    return ok;
  }

  Future<bool> updateCollaborator(Collaborator c) async {
    if (c.id == null) return false;
    // Build payload but remove server-managed/read-only fields that the API rejects
    final payload = Map<String, dynamic>.from(c.toJson());
    payload.remove('id');
    payload.remove('createdAt');
    payload.remove('updatedAt');
    payload.remove('userType');
    if (kDebugMode) {
      // ignore: avoid_print
      print(
        'CollaboratorController.updateCollaborator payload=${jsonEncode(payload)}',
      );
    }
    final res = await _service.update(c.id!, payload);
    final updated = Collaborator.fromJson(Map<String, dynamic>.from(res));
    if (_loggedCollaborator?.id == updated.id) {
      _loggedCollaborator = updated;
    }
    final idx = _collaborators.indexWhere((x) => x.id == updated.id);
    if (idx != -1) _collaborators[idx] = updated;
    notifyListeners();
    return true;
  }
}
