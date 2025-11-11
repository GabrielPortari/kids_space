import 'package:kids_space/model/check_event.dart';
import 'package:kids_space/service/check_event_service.dart';
import 'package:flutter/foundation.dart';
import 'package:mobx/mobx.dart';

part 'check_event_controller.g.dart';

/// MobX Store for CheckEventController (uses codegen)
class CheckEventController = _CheckEventController with _$CheckEventController;

abstract class _CheckEventController with Store {
  final CheckEventService _service = CheckEventService();

  // Loading states
  @observable
  bool isLoadingEvents = false;

  @observable
  bool isLoadingActiveCheckins = false;

  @observable
  bool isLoadingLastCheck = false;

  @observable
  bool isLoadingLog = false;

  @observable
  bool allLoaded = false;
  
  // Data
  @observable
  List<CheckEvent>? events = [];

  @observable
  List<CheckEvent>? activeCheckins = [];

  @observable
  CheckEvent? lastCheckIn;

  @observable
  CheckEvent? lastCheckOut;

  @observable
  List<CheckEvent> logEvents = [];

  @action
  Future<void> loadEvents(String companyId) async {
    isLoadingEvents = true;
    debugPrint('CheckEventController.loadEvents START for $companyId');
    try {
      final res = await _service.getEventsByCompany(companyId);
      events = res;
      debugPrint('CheckEventController.loadEvents DONE (${events?.length})');
    } catch (e, st) {
      debugPrint('CheckEventController.loadEvents ERROR: $e\n$st');
      rethrow;
    } finally {
      isLoadingEvents = false;
    }
  }

  @action
  Future<void> loadLastCheckinAndOut(String companyId) async {
    isLoadingLastCheck = true;
    debugPrint('CheckEventController.loadLastCheckinAndOut START for $companyId');
    try {
      lastCheckIn = null;
      lastCheckOut = null;
      final lastMap = await _service.getLastCheckinAndCheckout(companyId);
      lastCheckIn = lastMap[CheckType.checkIn];
      lastCheckOut = lastMap[CheckType.checkOut];
      debugPrint('CheckEventController.loadLastCheckinAndOut DONE');
    } catch (e, st) {
      debugPrint('CheckEventController.loadLastCheckinAndOut ERROR: $e\n$st');
      rethrow;
    } finally {
      isLoadingLastCheck = false;
    }
  }

  @action
  Future<void> loadActiveCheckins(String companyId) async {
    isLoadingActiveCheckins = true;
    debugPrint('CheckEventController.loadActiveCheckins START for $companyId');
    try {
      final list = await getActiveCheckins(companyId);
      activeCheckins = list;
      debugPrint('CheckEventController.loadActiveCheckins DONE (${activeCheckins?.length})');
    } catch (e, st) {
      debugPrint('CheckEventController.loadActiveCheckins ERROR: $e\n$st');
      rethrow;
    } finally {
      isLoadingActiveCheckins = false;
    }
  }

  @action
  Future<void> loadLog(String companyId, {int limit = 30}) async {
    isLoadingLog = true;
    debugPrint('CheckEventController.loadLog START for $companyId');
    try {
      final res = await _service.getLastEventsByCompany(companyId, limit: limit);
      logEvents = res;
      debugPrint('CheckEventController.loadLog DONE (${logEvents.length})');
    } catch (e, st) {
      debugPrint('CheckEventController.loadLog ERROR: $e\n$st');
      rethrow;
    } finally {
      isLoadingLog = false;
    }
  }

  /// Delegates to service
  Future<List<CheckEvent>> getAllEvents() => _service.getAllEvents();
  Future<List<CheckEvent>> getEventsByCompany(String companyId) => _service.getEventsByCompany(companyId);
  Future<List<CheckEvent>> getEventsByChild(String childId) => _service.getEventsByChild(childId);
  Future<List<CheckEvent>> getEventsByCollaborator(String collaboratorId) => _service.getEventsByCollaborator(collaboratorId);
  Future<Map<CheckType, CheckEvent?>> getLastCheckinAndCheckout(String companyId) => _service.getLastCheckinAndCheckout(companyId);
  Future<List<CheckEvent>> getLastEventsByCompany(String companyId, {int limit = 30}) => _service.getLastEventsByCompany(companyId, limit: limit);

  /// Recupera os check-ins ativos (crianças presentes) para uma empresa
  Future<List<CheckEvent>> getActiveCheckins(String companyId) async {
    final events = await getEventsByCompany(companyId);
    final Map<String, CheckEvent> lastEventByChild = {};
    for (final event in events) {
      final childId = event.child.id;
      if (!lastEventByChild.containsKey(childId) || event.timestamp.isAfter(lastEventByChild[childId]!.timestamp)) {
        lastEventByChild[childId] = event;
      }
    }
    return lastEventByChild.values.where((e) => e.checkType == CheckType.checkIn).toList();
  }
}
