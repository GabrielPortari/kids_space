import 'package:kids_space/model/check_event.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/service/check_event_service.dart';

class CheckEventController {
  final CheckEventService _service = CheckEventService();

  /// Lista de eventos carregados
  List<CheckEvent> events = [];
  CheckEvent? lastCheckIn;
  CheckEvent? lastCheckOut;
  List<CheckEvent> get loadedEvents => events;
  CheckEvent? get loadedLastCheckIn => lastCheckIn;
  CheckEvent? get loadedLastCheckOut => lastCheckOut;

  /// Atualiza a lista de eventos e os últimos check-in/check-out para uma empresa
  void loadEventsForCompany(String companyId, {int limit = 30}) {
    events = _service.getLastEventsByCompany(companyId, limit: limit);
    final lastMap = _service.getLastCheckinAndCheckout(companyId);
    lastCheckIn = lastMap[CheckType.checkIn];
    lastCheckOut = lastMap[CheckType.checkOut];
  }

  /// Registra um novo evento de check-in/check-out
  CheckEvent registerEvent({
    required String companyId,
    required Child child,
    required Collaborator collaborator,
    required CheckType checkType,
    DateTime? timestamp,
  }) {
    final event = _service.registerEvent(
      companyId: companyId,
      child: child,
      collaborator: collaborator,
      checkType: checkType,
      timestamp: timestamp,
    );
    // Atualiza lista e últimos eventos após registrar
    loadEventsForCompany(companyId);
    return event;
  }

  /// Lista todos os eventos
  List<CheckEvent> getAllEvents() => _service.getAllEvents();

  /// Lista eventos por empresa
  List<CheckEvent> getEventsByCompany(String companyId) => _service.getEventsByCompany(companyId);

  /// Lista eventos por criança
  List<CheckEvent> getEventsByChild(String childId) => _service.getEventsByChild(childId);

  /// Lista eventos por colaborador
  List<CheckEvent> getEventsByCollaborator(String collaboratorId) => _service.getEventsByCollaborator(collaboratorId);

  /// Retorna o último check-in e check-out da empresa
  Map<CheckType, CheckEvent?> getLastCheckinAndCheckout(String companyId) =>
      _service.getLastCheckinAndCheckout(companyId);

  /// Retorna os últimos eventos (check-in e check-out) da empresa, ordenados do mais recente para o mais antigo
  List<CheckEvent> getLastEventsByCompany(String companyId, {int limit = 30}) =>
      _service.getLastEventsByCompany(companyId, limit: limit);

  /// Recupera os check-ins ativos (crianças presentes) para uma empresa
  List<CheckEvent> getActiveCheckins(String companyId) {
    // Para cada criança, pega o último evento dela na empresa
    final events = getEventsByCompany(companyId);
    final Map<String, CheckEvent> lastEventByChild = {};
    for (final event in events) {
      final childId = event.child.id;
      if (!lastEventByChild.containsKey(childId) || event.timestamp.isAfter(lastEventByChild[childId]!.timestamp)) {
        lastEventByChild[childId] = event;
      }
    }
    // Retorna apenas os eventos cujo último status foi checkIn
    return lastEventByChild.values.where((e) => e.checkType == CheckType.checkIn).toList();
  }
}