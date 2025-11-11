import 'package:kids_space/model/check_event.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/model/mock/model_mock.dart';
// import 'package:uuid/uuid.dart';

class CheckEventService {
  final List<CheckEvent> _events = List.from(mockCheckEvents);
  // final _uuid = Uuid();
  // Artificial delay to simulate network / IO latency for all service methods.
  final Duration _serviceDelay = const Duration(milliseconds: 300);

  /// Registra um novo evento de check-in/check-out
  Future<CheckEvent> registerEvent({
    required String companyId,
    required Child child,
    required Collaborator collaborator,
    required CheckType checkType,
    DateTime? timestamp,
  }) {
    return Future.delayed(_serviceDelay, () {
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
    });
  }

  /// Retorna todos os eventos registrados
  Future<List<CheckEvent>> getAllEvents() =>
      Future.delayed(_serviceDelay, () => List.unmodifiable(_events));

  /// Retorna eventos por empresa
  Future<List<CheckEvent>> getEventsByCompany(String companyId) =>
    Future.delayed(_serviceDelay,
      () => _events.where((e) => e.companyId == companyId).toList());

  /// Retorna eventos por criança
  Future<List<CheckEvent>> getEventsByChild(String childId) =>
    Future.delayed(_serviceDelay,
      () => _events.where((e) => e.child.id == childId).toList());

  /// Retorna eventos por colaborador
  Future<List<CheckEvent>> getEventsByCollaborator(String collaboratorId) =>
    Future.delayed(_serviceDelay,
      () => _events.where((e) => e.collaborator.id == collaboratorId).toList());

  /// Retorna o último check-in e check-out da empresa
  Future<Map<CheckType, CheckEvent?>> getLastCheckinAndCheckout(
      String companyId) async {
    // Reuse getEventsByCompany which already has a simulated delay
    final events = await getEventsByCompany(companyId);
    CheckEvent? lastCheckIn = events
        .where((e) => e.checkType == CheckType.checkIn)
        .toList()
        .fold<CheckEvent?>(
            null, (prev, e) => prev == null || e.timestamp.isAfter(prev.timestamp) ? e : prev);
    CheckEvent? lastCheckOut = events
        .where((e) => e.checkType == CheckType.checkOut)
        .toList()
        .fold<CheckEvent?>(
            null, (prev, e) => prev == null || e.timestamp.isAfter(prev.timestamp) ? e : prev);
    return {
      CheckType.checkIn: lastCheckIn,
      CheckType.checkOut: lastCheckOut,
    };
  }

  /// Retorna os últimos eventos (check-in e check-out) da empresa, ordenados do mais recente para o mais antigo
  Future<List<CheckEvent>> getLastEventsByCompany(String companyId,
      {int limit = 30}) async {
    final events = await getEventsByCompany(companyId);
    events.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return events.take(limit).toList();
  }

}
