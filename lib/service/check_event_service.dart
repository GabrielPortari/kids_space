import 'package:kids_space/model/check_event.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/model/mock/model_mock.dart';
import 'dart:developer' as developer;
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
    developer.log('registerEvent called: companyId=$companyId childId=${child.id} collaboratorId=${collaborator.id} checkType=$checkType', name: 'CheckEventService');
    return Future.delayed(_serviceDelay, () {
      final now = timestamp ?? DateTime.now();
      final event = CheckEvent(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        companyId: companyId,
        childId: child.id,
        collaboratorId: collaborator.id,
        checkinTime: checkType == CheckType.checkIn ? now : null,
        checkoutTime: checkType == CheckType.checkOut ? now : null,
        checkType: checkType,
        createdAt: now,
        updatedAt: now,
      );
      _events.add(event);
      developer.log('registerEvent created id=${event.id}', name: 'CheckEventService');
      return event;
    });
  }

  /// Retorna todos os eventos registrados
  Future<List<CheckEvent>> getAllEvents() =>
      Future.delayed(_serviceDelay, () {
        developer.log('getAllEvents returning ${_events.length} events', name: 'CheckEventService');
        return List.unmodifiable(_events);
      });

  /// Retorna eventos por empresa
  Future<List<CheckEvent>> getEventsByCompany(String companyId) =>
    Future.delayed(_serviceDelay, () {
      final result = _events.where((e) => e.companyId == companyId).toList();
      developer.log('getEventsByCompany companyId=$companyId returning ${result.length} events', name: 'CheckEventService');
      return result;
    });

  /// Retorna eventos por criança
  Future<List<CheckEvent>> getEventsByChild(String childId) =>
    Future.delayed(_serviceDelay, () {
      final result = _events.where((e) => e.childId == childId).toList();
      developer.log('getEventsByChild childId=$childId returning ${result.length} events', name: 'CheckEventService');
      return result;
    });

  /// Retorna eventos por colaborador
  Future<List<CheckEvent>> getEventsByCollaborator(String collaboratorId) =>
    Future.delayed(_serviceDelay, () {
      final result = _events.where((e) => e.collaboratorId == collaboratorId).toList();
      developer.log('getEventsByCollaborator collaboratorId=$collaboratorId returning ${result.length} events', name: 'CheckEventService');
      return result;
    });

  /// Retorna o último check-in e check-out da empresa
  Future<Map<CheckType, CheckEvent?>> getLastCheckinAndCheckout(
      String companyId) async {
    // Reuse getEventsByCompany which already has a simulated delay
    final events = await getEventsByCompany(companyId);
    DateTime? _eventTime(CheckEvent e) => e.checkinTime ?? e.checkoutTime;
    CheckEvent? lastCheckIn = events
        .where((e) => e.checkType == CheckType.checkIn)
        .toList()
        .fold<CheckEvent?>(null, (prev, e) {
      final et = _eventTime(e);
      final prevt = prev == null ? null : _eventTime(prev);
      if (prevt == null) return e;
      if (et == null) return prev;
      return et.isAfter(prevt) ? e : prev;
    });

    CheckEvent? lastCheckOut = events
        .where((e) => e.checkType == CheckType.checkOut)
        .toList()
        .fold<CheckEvent?>(null, (prev, e) {
      final et = _eventTime(e);
      final prevt = prev == null ? null : _eventTime(prev);
      if (prevt == null) return e;
      if (et == null) return prev;
      return et.isAfter(prevt) ? e : prev;
    });
    return {
      CheckType.checkIn: lastCheckIn,
      CheckType.checkOut: lastCheckOut,
    };
  }

  /// Retorna os últimos eventos (check-in e check-out) da empresa, ordenados do mais recente para o mais antigo
  Future<List<CheckEvent>> getLastEventsByCompany(String companyId, {int limit = 30}) async {
    final events = await getEventsByCompany(companyId);
    DateTime? _eventTime(CheckEvent e) => e.checkinTime ?? e.checkoutTime;
    events.sort((a, b) {
      final at = _eventTime(a);
      final bt = _eventTime(b);
      if (at == null && bt == null) return 0;
      if (at == null) return 1;
      if (bt == null) return -1;
      return bt.compareTo(at);
    });
    return events.take(limit).toList();
  }

}
