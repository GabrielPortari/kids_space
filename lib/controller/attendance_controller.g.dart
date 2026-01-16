// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_controller.dart';

// **************************************************************************
// StoreGenerator
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, unnecessary_brace_in_string_interps, unnecessary_lambdas, prefer_expression_function_bodies, lines_longer_than_80_chars, avoid_as, avoid_annotating_with_dynamic, no_leading_underscores_for_local_identifiers

mixin _$AttendanceController on _AttendanceController, Store {
  late final _$isLoadingEventsAtom = Atom(
    name: '_AttendanceController.isLoadingEvents',
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

  late final _$eventsAtom = Atom(
    name: '_AttendanceController.events',
    context: context,
  );

  @override
  List<Attendance>? get events {
    _$eventsAtom.reportRead();
    return super.events;
  }

  @override
  set events(List<Attendance>? value) {
    _$eventsAtom.reportWrite(value, super.events, () {
      super.events = value;
    });
  }

  late final _$isLoadingActiveCheckinsAtom = Atom(
    name: '_AttendanceController.isLoadingActiveCheckins',
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

  late final _$activeCheckinsAtom = Atom(
    name: '_AttendanceController.activeCheckins',
    context: context,
  );

  @override
  List<Attendance>? get activeCheckins {
    _$activeCheckinsAtom.reportRead();
    return super.activeCheckins;
  }

  @override
  set activeCheckins(List<Attendance>? value) {
    _$activeCheckinsAtom.reportWrite(value, super.activeCheckins, () {
      super.activeCheckins = value;
    });
  }

  late final _$isLoadingLogsAtom = Atom(
    name: '_AttendanceController.isLoadingLogs',
    context: context,
  );

  @override
  bool get isLoadingLogs {
    _$isLoadingLogsAtom.reportRead();
    return super.isLoadingLogs;
  }

  @override
  set isLoadingLogs(bool value) {
    _$isLoadingLogsAtom.reportWrite(value, super.isLoadingLogs, () {
      super.isLoadingLogs = value;
    });
  }

  late final _$logEventsAtom = Atom(
    name: '_AttendanceController.logEvents',
    context: context,
  );

  @override
  List<Attendance> get logEvents {
    _$logEventsAtom.reportRead();
    return super.logEvents;
  }

  @override
  set logEvents(List<Attendance> value) {
    _$logEventsAtom.reportWrite(value, super.logEvents, () {
      super.logEvents = value;
    });
  }

  late final _$lastCheckInAtom = Atom(
    name: '_AttendanceController.lastCheckIn',
    context: context,
  );

  @override
  Attendance? get lastCheckIn {
    _$lastCheckInAtom.reportRead();
    return super.lastCheckIn;
  }

  @override
  set lastCheckIn(Attendance? value) {
    _$lastCheckInAtom.reportWrite(value, super.lastCheckIn, () {
      super.lastCheckIn = value;
    });
  }

  late final _$lastCheckOutAtom = Atom(
    name: '_AttendanceController.lastCheckOut',
    context: context,
  );

  @override
  Attendance? get lastCheckOut {
    _$lastCheckOutAtom.reportRead();
    return super.lastCheckOut;
  }

  @override
  set lastCheckOut(Attendance? value) {
    _$lastCheckOutAtom.reportWrite(value, super.lastCheckOut, () {
      super.lastCheckOut = value;
    });
  }

  late final _$isLoadingLastCheckAtom = Atom(
    name: '_AttendanceController.isLoadingLastCheck',
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

  late final _$loadActiveCheckinsForCompanyAsyncAction = AsyncAction(
    '_AttendanceController.loadActiveCheckinsForCompany',
    context: context,
  );

  @override
  Future<void> loadActiveCheckinsForCompany(String companyId) {
    return _$loadActiveCheckinsForCompanyAsyncAction.run(
      () => super.loadActiveCheckinsForCompany(companyId),
    );
  }

  late final _$loadLast10AttendancesForCompanyAsyncAction = AsyncAction(
    '_AttendanceController.loadLast10AttendancesForCompany',
    context: context,
  );

  @override
  Future<void> loadLast10AttendancesForCompany(
    String companyId, {
    int limit = 10,
  }) {
    return _$loadLast10AttendancesForCompanyAsyncAction.run(
      () => super.loadLast10AttendancesForCompany(companyId, limit: limit),
    );
  }

  late final _$loadLastCheckinAndCheckoutForCompanyAsyncAction = AsyncAction(
    '_AttendanceController.loadLastCheckinAndCheckoutForCompany',
    context: context,
  );

  @override
  Future<void> loadLastCheckinAndCheckoutForCompany(String companyId) {
    return _$loadLastCheckinAndCheckoutForCompanyAsyncAction.run(
      () => super.loadLastCheckinAndCheckoutForCompany(companyId),
    );
  }

  @override
  String toString() {
    return '''
isLoadingEvents: ${isLoadingEvents},
events: ${events},
isLoadingActiveCheckins: ${isLoadingActiveCheckins},
activeCheckins: ${activeCheckins},
isLoadingLogs: ${isLoadingLogs},
logEvents: ${logEvents},
lastCheckIn: ${lastCheckIn},
lastCheckOut: ${lastCheckOut},
isLoadingLastCheck: ${isLoadingLastCheck}
    ''';
  }
}
