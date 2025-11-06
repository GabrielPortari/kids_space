import 'package:kids_space/model/check_event.dart';
import 'package:kids_space/model/child.dart';
import 'package:kids_space/model/collaborator.dart';
import 'package:kids_space/service/check_event_service.dart';
import 'package:mobx/mobx.dart';

class CheckEventController {
  final CheckEventService _service = CheckEventService();

  /// Lista de eventos carregados
  @observable
  List<CheckEvent> events = [];

  @observable
  List<CheckEvent>? activeCheckins;

  @observable
  CheckEvent? lastCheckIn;

  @observable
  CheckEvent? lastCheckOut;

  @observable
  List<CheckEvent> logEvents = [];

  List<CheckEvent> get loadedEvents => events;
  CheckEvent? get loadedLastCheckIn => lastCheckIn;
  CheckEvent? get loadedLastCheckOut => lastCheckOut;
  List<CheckEvent>? get loadedActiveCheckins => activeCheckins;
  List<CheckEvent> get loadedLogEvents => logEvents;
  
  void loadEvents(String companyId){
    events = _service.getEventsByCompany(companyId);
  }
  
  void loadLastCheckinAndOut(String companyId){
    final lastMap = _service.getLastCheckinAndCheckout(companyId);
    lastCheckIn = lastMap[CheckType.checkIn];
    lastCheckOut = lastMap[CheckType.checkOut];
  }

  void loadActiveCheckins(String companyId) {
    activeCheckins = getActiveCheckins(companyId);
  }

  void loadLog(String companyId, {int limit = 30}){
    logEvents = _service.getLastEventsByCompany(companyId, limit: limit);
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