import 'package:flutter/foundation.dart';
import '../service/collaborator_service.dart';
import '../model/collaborator.dart';

class CollaboratorController extends ChangeNotifier {
  final CollaboratorService _service = CollaboratorService();
  Collaborator? _loggedCollaborator;

  Collaborator? get loggedCollaborator => _loggedCollaborator;

  Future<Collaborator?> create(Map<String, dynamic> payload) async {
    final data = await _service.create(payload);
    _loggedCollaborator = Collaborator.fromJson(data);
    notifyListeners();
    return _loggedCollaborator;
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
  }

  Future<bool> deleteCollaborator(String id) async {
    final ok = await _service.delete(id);
    if (ok) {
      if (_loggedCollaborator?.id == id) {
        _loggedCollaborator = null;
      }
      notifyListeners();
    }
    return ok;
  }
}
