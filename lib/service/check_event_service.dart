import 'package:kids_space/model/check_event.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/model/mock/model_mock.dart';
// import 'package:uuid/uuid.dart';

class CheckEventService {
  final List<CheckEvent> _events = List.from(mockCheckEvents);
  // final _uuid = Uuid();

  /// Registra um novo evento de check-in/check-out
  CheckEvent registerEvent({
    required String companyId,
    required Child child,
    required Collaborator collaborator,
    required CheckType checkType,
    DateTime? timestamp,
  }) {
    final event = CheckEvent(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      companyId: companyId,
      child: child,
      collaborator: collaborator,
      timestamp: timestamp ?? DateTime.now(),
      checkType: checkType,
    );
    _events.add(event);
    return event;
  }

  /// Retorna todos os eventos registrados
  List<CheckEvent> getAllEvents() => List.unmodifiable(_events);

  /// Retorna eventos por empresa
  List<CheckEvent> getEventsByCompany(String companyId) =>
      _events.where((e) => e.companyId == companyId).toList();

  /// Retorna eventos por criança
  List<CheckEvent> getEventsByChild(String childId) =>
      _events.where((e) => e.child.id == childId).toList();

  /// Retorna eventos por colaborador
  List<CheckEvent> getEventsByCollaborator(String collaboratorId) =>
      _events.where((e) => e.collaborator.id == collaboratorId).toList();

  /// Retorna o último check-in e check-out da empresa
  Map<CheckType, CheckEvent?> getLastCheckinAndCheckout(String companyId) {
    final events = getEventsByCompany(companyId);
    CheckEvent? lastCheckIn = events
        .where((e) => e.checkType == CheckType.checkIn)
        .toList()
        .fold<CheckEvent?>(null, (prev, e) => prev == null || e.timestamp.isAfter(prev.timestamp) ? e : prev);
    CheckEvent? lastCheckOut = events
        .where((e) => e.checkType == CheckType.checkOut)
        .toList()
        .fold<CheckEvent?>(null, (prev, e) => prev == null || e.timestamp.isAfter(prev.timestamp) ? e : prev);
    return {
      CheckType.checkIn: lastCheckIn,
      CheckType.checkOut: lastCheckOut,
    };
  }

  /// Retorna os últimos eventos (check-in e check-out) da empresa, ordenados do mais recente para o mais antigo
  List<CheckEvent> getLastEventsByCompany(String companyId, {int limit = 30}) {
    final events = getEventsByCompany(companyId);
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events.take(limit).toList();
  }

}
