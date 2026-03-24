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
    // backend endpoint missing; implement later
    return _loggedCollaborator?.id == id ? _loggedCollaborator : null;
  }

  Future<void> setLoggedCollaborator(Collaborator c) async {
    _loggedCollaborator = c;
    notifyListeners();
  }
}
