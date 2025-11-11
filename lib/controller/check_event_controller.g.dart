// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_event_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$CheckEventController on _CheckEventController, Store {
  late final _$isLoadingEventsAtom = Atom(
    name: '_CheckEventController.isLoadingEvents',
    context: context,
  );

  @override
  bool get isLoadingEvents {
    _$isLoadingEventsAtom.reportRead();
    return super.isLoadingEvents;
  }

  @override
  set isLoadingEvents(bool value) {
    _$isLoadingEventsAtom.reportWrite(value, super.isLoadingEvents, () {
      super.isLoadingEvents = value;
    });
  }

  late final _$isLoadingActiveCheckinsAtom = Atom(
    name: '_CheckEventController.isLoadingActiveCheckins',
    context: context,
  );

  @override
  bool get isLoadingActiveCheckins {
    _$isLoadingActiveCheckinsAtom.reportRead();
    return super.isLoadingActiveCheckins;
  }

  @override
  set isLoadingActiveCheckins(bool value) {
    _$isLoadingActiveCheckinsAtom.reportWrite(
      value,
      super.isLoadingActiveCheckins,
      () {
        super.isLoadingActiveCheckins = value;
      },
    );
  }

  late final _$isLoadingLastCheckAtom = Atom(
    name: '_CheckEventController.isLoadingLastCheck',
    context: context,
  );

  @override
  bool get isLoadingLastCheck {
    _$isLoadingLastCheckAtom.reportRead();
    return super.isLoadingLastCheck;
  }

  @override
  set isLoadingLastCheck(bool value) {
    _$isLoadingLastCheckAtom.reportWrite(value, super.isLoadingLastCheck, () {
      super.isLoadingLastCheck = value;
    });
  }

  late final _$isLoadingLogAtom = Atom(
    name: '_CheckEventController.isLoadingLog',
    context: context,
  );

  @override
  bool get isLoadingLog {
    _$isLoadingLogAtom.reportRead();
    return super.isLoadingLog;
  }

  @override
  set isLoadingLog(bool value) {
    _$isLoadingLogAtom.reportWrite(value, super.isLoadingLog, () {
      super.isLoadingLog = value;
    });
  }

  late final _$allLoadedAtom = Atom(
    name: '_CheckEventController.allLoaded',
    context: context,
  );

  @override
  bool get allLoaded {
    _$allLoadedAtom.reportRead();
    return super.allLoaded;
  }

  @override
  set allLoaded(bool value) {
    _$allLoadedAtom.reportWrite(value, super.allLoaded, () {
      super.allLoaded = value;
    });
  }

  late final _$eventsAtom = Atom(
    name: '_CheckEventController.events',
    context: context,
  );

  @override
  List<CheckEvent>? get events {
    _$eventsAtom.reportRead();
    return super.events;
  }

  @override
  set events(List<CheckEvent>? value) {
    _$eventsAtom.reportWrite(value, super.events, () {
      super.events = value;
    });
  }

  late final _$activeCheckinsAtom = Atom(
    name: '_CheckEventController.activeCheckins',
    context: context,
  );

  @override
  List<CheckEvent>? get activeCheckins {
    _$activeCheckinsAtom.reportRead();
    return super.activeCheckins;
  }

  @override
  set activeCheckins(List<CheckEvent>? value) {
    _$activeCheckinsAtom.reportWrite(value, super.activeCheckins, () {
      super.activeCheckins = value;
    });
  }

  late final _$lastCheckInAtom = Atom(
    name: '_CheckEventController.lastCheckIn',
    context: context,
  );

  @override
  CheckEvent? get lastCheckIn {
    _$lastCheckInAtom.reportRead();
    return super.lastCheckIn;
  }

  @override
  set lastCheckIn(CheckEvent? value) {
    _$lastCheckInAtom.reportWrite(value, super.lastCheckIn, () {
      super.lastCheckIn = value;
    });
  }

  late final _$lastCheckOutAtom = Atom(
    name: '_CheckEventController.lastCheckOut',
    context: context,
  );

  @override
  CheckEvent? get lastCheckOut {
    _$lastCheckOutAtom.reportRead();
    return super.lastCheckOut;
  }

  @override
  set lastCheckOut(CheckEvent? value) {
    _$lastCheckOutAtom.reportWrite(value, super.lastCheckOut, () {
      super.lastCheckOut = value;
    });
  }

  late final _$logEventsAtom = Atom(
    name: '_CheckEventController.logEvents',
    context: context,
  );

  @override
  List<CheckEvent> get logEvents {
    _$logEventsAtom.reportRead();
    return super.logEvents;
  }

  @override
  set logEvents(List<CheckEvent> value) {
    _$logEventsAtom.reportWrite(value, super.logEvents, () {
      super.logEvents = value;
    });
  }

  late final _$loadEventsAsyncAction = AsyncAction(
    '_CheckEventController.loadEvents',
    context: context,
  );

  @override
  Future<void> loadEvents(String companyId) {
    return _$loadEventsAsyncAction.run(() => super.loadEvents(companyId));
  }

  late final _$loadLastCheckinAndOutAsyncAction = AsyncAction(
    '_CheckEventController.loadLastCheckinAndOut',
    context: context,
  );

  @override
  Future<void> loadLastCheckinAndOut(String companyId) {
    return _$loadLastCheckinAndOutAsyncAction.run(
      () => super.loadLastCheckinAndOut(companyId),
    );
  }

  late final _$loadActiveCheckinsAsyncAction = AsyncAction(
    '_CheckEventController.loadActiveCheckins',
    context: context,
  );

  @override
  Future<void> loadActiveCheckins(String companyId) {
    return _$loadActiveCheckinsAsyncAction.run(
      () => super.loadActiveCheckins(companyId),
    );
  }

  late final _$loadLogAsyncAction = AsyncAction(
    '_CheckEventController.loadLog',
    context: context,
  );

  @override
  Future<void> loadLog(String companyId, {int limit = 30}) {
    return _$loadLogAsyncAction.run(
      () => super.loadLog(companyId, limit: limit),
    );
  }

  @override
  String toString() {
    return '''
isLoadingEvents: ${isLoadingEvents},
isLoadingActiveCheckins: ${isLoadingActiveCheckins},
isLoadingLastCheck: ${isLoadingLastCheck},
isLoadingLog: ${isLoadingLog},
allLoaded: ${allLoaded},
events: ${events},
activeCheckins: ${activeCheckins},
lastCheckIn: ${lastCheckIn},
lastCheckOut: ${lastCheckOut},
logEvents: ${logEvents}
    ''';
  }
}
